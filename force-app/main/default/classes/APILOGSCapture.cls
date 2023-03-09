public with sharing class APILOGSCapture {

    public static void captureLogs(String EndPoint, String body, integer statuscode, String Response, String ResponseMap,string Eventid){

        try {
            APILog__c APIL = new APILog__c();
            if(Eventid != null && statuscode != null && Response != null){
                APIL.Body__c = body;
                APIL.Endpoint__c = EndPoint;
                APIL.Event_Record_ID__c = Eventid;
                APIL.Response__c = Response;
                APIL.StatusCode__c = statuscode;
                APIL.User__c = UserInfo.getUserId();

                if(ResponseMap != null){
                    APIL.ResponseMap__c = ResponseMap;
                }
                else{
                    APIL.ResponseMap__c= '';
                }
                System.debug(' APIL  =======> ' + APIL);
                insert APIL;
            }
            
        } catch (Exception e) {
            System.debug('The Error occured due to ======> ' + e.getMessage());
            System.debug('The Error occured at line number ======> ' + e.getLineNumber());
            
        }
    }
}