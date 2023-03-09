public class HelperForSIDAsync {
    
    @future(callout=true)
    public Static void ExotelCalloutSID(String taskId){
        Task taskRec = [Select Id,wk_exo__call_sid__c From Task Where Id =: taskId];
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint('https://8cf47d160c162af8050e7961f3bf92939511de56f5f7d112:4f67d50f93b01c505019335fb12b5892d23c2b8f880fdc2e@api.exotel.com/v1/Accounts/relevel2/Calls/'+taskRec.wk_exo__call_sid__c+'.json');
        request.setMethod('GET');
        
        request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        }
        if(response.getStatusCode() == 200){
            
            System.debug('Response Body 1 ::'+response.getBody());
            string ResponseString = string.valueOf(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(ResponseString);
            system.debug('m-->'+m);
            Map<String,Object> callDetails = (Map<String,Object>)m.get('Call');
            String status  = (String) callDetails.get('Status');
            if(status != 'in-progress'){
                taskRec.wk_exo__exotel_dial_status__c = status;
                taskRec.status = 'Completed';
                update taskRec;
            }
        }
    }
}