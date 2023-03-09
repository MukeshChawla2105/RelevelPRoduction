global  class BatchForIVR implements Database.Batchable<sObject> , Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime thirtyMins = System.now().addMinutes(25);
        DateTime thirtyFiveMins = System.now().addMinutes(35);
        
        String query = 'SELECT id,Name,Phone,Email,Interview_Date_Time_AC__c,IVR_Called__c,OwnerId FROM Lead WHERE Interview_Date_Time_AC__c >: thirtyMins AND Interview_Date_Time_AC__c <: thirtyFiveMins AND IVR_Called__c = false AND Phone != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        List<Lead> leadListToBeUpdated = new List<Lead>();
        
        for(Lead leadRec : leadList){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.exotel.com/v1/Accounts/relevel2/Calls/connect');
            // 6362150255 - Learner no
            request.setMethod('POST');
            string payLoad = 'From='+EncodingUtil.urlEncode(leadRec.Phone,'UTF-8')+'&CallerId='+EncodingUtil.urlEncode('08047091340','UTF-8')+'&Url='+EncodingUtil.urlEncode('http://my.exotel.com/relevel2/exoml/start_voice/531460','UTF-8');
            request.setHeader( 'Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Accept', '*/*'); 
            
            request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
            request.setBody(payLoad);
            // field in lead IVR_Called__c , update when response is 200
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                System.debug(response.getBody());
            }
            if(response.getStatusCode() == 200){
                system.debug('response-->'+response);
                system.debug('response.body-->'+response.getBody());
                
                system.debug('leadRec.Id-->'+leadRec.Id);
                leadRec.IVR_Called__c = true;
                leadListToBeUpdated.add(leadRec);
                //update leadRec;
            }
        }
        if(!leadListToBeUpdated.isEmpty()){
            update leadListToBeUpdated;
        }
        /* if(!leadList.isEmpty()){
//for(Lead leadRec : leadList){
Callout_ExotelAutoCall.triggerExotelAutoCall(leadList);
// }
}*/
    }
    public void finish(Database.BatchableContext BC) {
    }  
    
}