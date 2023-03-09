public class HelperForIVRAsync {
    
    @future(callout=true)
    public static void ExotelCallout(String leadId){
        //string apiReturn = '';
        Lead leadRec = [Select Id,Phone From Lead where id =: leadId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exotel.com/v1/Accounts/relevel2/Calls/connect');
        request.setMethod('POST');
        string payLoad = 'From='+EncodingUtil.urlEncode(leadRec.Phone,'UTF-8')+'&CallerId='+EncodingUtil.urlEncode('08047091340','UTF-8')+'&Url='+EncodingUtil.urlEncode('http://my.exotel.com/relevel2/exoml/start_voice/531460','UTF-8');
        request.setHeader( 'Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', '*/*'); 
        request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
        request.setBody(payLoad);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        }
        if(response.getStatusCode() == 200){
           
            leadRec.IVR_Called__c = true;
            update leadRec;
        }
        
    }

}