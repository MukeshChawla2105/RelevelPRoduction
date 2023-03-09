public Without Sharing class Callout_Interview_Response {
    

    @future(callout=true)
    public static void sendInterviewStatusUpdate(Set<String> interviewIdSet){
        system.debug('interviewIdSet::'+interviewIdSet);
        Relevel_BackEnd_API__mdt backendAuthDet = [select id,Auth_Header__c,Auth_Key__c,End_Point_URL__c,Method__c,Content_Type__c,Accept__c from Relevel_BackEnd_API__mdt limit 1];
        List<Interview__c> interviewList = [select id,Relevel_Interview_Id__c,Status__c from Interview__c where id in: interviewIdSet];
        system.debug('interviewList::'+interviewList);
        if(!interviewList.isEmpty()){
            for(Interview__c intDet : interviewList){
                String jsonReq = generateJSON(intDet);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(backendAuthDet.End_Point_URL__c);
                req.setMethod(backendAuthDet.Method__c);
                req.setHeader('Content-Type',backendAuthDet.Content_Type__c);
                req.setHeader('Accept',backendAuthDet.Accept__c);
                req.setHeader('salesforce-auth-token', backendAuthDet.Auth_Key__c);
                req.setBody(jsonReq);
        
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('res.getBody()::'+res.getBody());
            }
        }
        
        
    }


    public static String generateJSON(Interview__c interviewDet){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('relevel_interview_id',interviewDet.Relevel_Interview_Id__c);
        gen.writeStringField('status', interviewDet.Status__c);
        gen.writeEndObject();

        return gen.getAsString();
    }
}