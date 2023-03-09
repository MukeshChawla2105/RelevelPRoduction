global class Callout_ExotelAutoCall_V1 {
    public static Lead leadRec = new Lead();
    @future(callout=true)
    public static void triggerExotelAutoCall(string leadId){
        string apiReturn = '';
        leadRec = [SELECT id,Name,Phone,Email,SID__c,Interview_Date_Time_AC__c,IVR_Called__c,OwnerId,Interview_Slot_Date_Time__c FROM Lead WHERE Id =: leadId AND Phone != null];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exotel.com/v1/Accounts/relevel2/Calls/connect.json');
        request.setMethod('POST');
        string payLoad = 'From='+EncodingUtil.urlEncode(leadRec.Phone,'UTF-8')+'&CallerId='+EncodingUtil.urlEncode('08047091340','UTF-8')+'&Url='+EncodingUtil.urlEncode('http://my.exotel.com/relevel2/exoml/start_voice/531460','UTF-8');
        request.setHeader( 'Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', '*/*'); 
        request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
        request.setBody(payLoad);
        HttpResponse response = http.send(request);
        system.debug('response.getStatusCode()-->'+response.getStatusCode());
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        }
        if(response.getStatusCode() == 200){
            System.debug('Response Body 1 ::'+response.getBody());
            string ResponseString = string.valueOf(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(ResponseString);
            system.debug('m-->'+m);
            Map<String,Object> callDetails = (Map<String,Object>)m.get('Call');
            String callSID  = (String) callDetails.get('Sid');
            lead ld = new lead();
            ld.Id = leadRec.Id;
            ld.SID__c = callSID;
            ld.IVR_Called__c = true;
            update ld;
        }
    }
}