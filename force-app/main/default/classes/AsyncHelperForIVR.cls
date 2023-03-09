public class AsyncHelperForIVR implements Queueable,Database.AllowsCallOuts{
    List<Lead> leadIdList = New List<Lead>();
    List<Lead> leadListTobeUpdate = new List<Lead>();
    integer startIndex;
    integer endIndex;
    public AsyncHelperForIVR(List<Lead> leadIdList,integer startIndex,integer endIndex){
        this.leadIdList = leadIdList;
        this.startIndex = startIndex;
        this.endIndex = endIndex;
    }
    
    public void execute(QueueableContext context){
        system.debug('leadIdList-->'+leadIdList);
        system.debug('LeadList-->'+leadIdList.size());
        system.debug('startIndex-->'+startIndex);
        system.debug('endIndex-->'+endIndex);
        //Lead leadRec = [Select Id,Phone From Lead where id =: leadId];
        for(integer i = startIndex;i< endIndex;i++){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.exotel.com/v1/Accounts/relevel2/Calls/connect.json');
            request.setMethod('POST');
            string payLoad = 'From='+EncodingUtil.urlEncode(leadIdList[i].phone,'UTF-8')+'&CallerId='+EncodingUtil.urlEncode('08047091340','UTF-8')+'&Url='+EncodingUtil.urlEncode('http://my.exotel.com/relevel2/exoml/start_voice/531460','UTF-8');
            request.setHeader( 'Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Accept', '*/*'); 
            request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
            request.setBody(payLoad);
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body IVERA::'+response.getBody());
            }
            if(response.getStatusCode() == 200){
                System.debug('Response Body 1 ::'+response.getBody());
                string ResponseString = string.valueOf(response.getBody());
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(ResponseString);
                system.debug('m-->'+m);
                Map<String,Object> callDetails = (Map<String,Object>)m.get('Call');
                String callSID  = (String) callDetails.get('Sid');
                lead ld = new lead();
                ld.Id = leadIdList[i].Id;
                ld.SID__c = callSID;
                ld.IVR_Called__c = true;
                leadListTobeUpdate.add(ld);
                update leadListTobeUpdate;
            }
        }
        startIndex = endIndex;
        endIndex = endIndex + 1;
        system.debug('leadListTobeUpdate-->'+leadListTobeUpdate);

        if(startIndex < leadIdList.size()){
            system.debug('Enqueue Job');
            System.enqueueJob(new AsyncHelperForIVR(leadIdList,startIndex,endIndex));
        }
    } 
}