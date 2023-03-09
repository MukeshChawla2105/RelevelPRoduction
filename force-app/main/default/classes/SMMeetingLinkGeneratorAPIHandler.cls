public with sharing class SMMeetingLinkGeneratorAPIHandler{
    static String bApi_Key = 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
    static string api_key = 'AIzaSyB4axY3ZOWy2ivrgdbiL752PJHZza5yrrU';   // For Production
    private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    private static final String REPORTENDPOINT = 'https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/meet';
    Public Static APIWrapper GeneratorMetingForSM(string StartDatetime, string EndDateTime, String Title, String Organiser){
        APIWrapper APILogWrap = new APIWrapper();
        try{
            System.debug('StartDatetime =======> ' + StartDatetime);
            Map<String, String> responseMap = new Map<String, String>();
            

            String endPoint = '/calendars/' + Organiser + '/events?conferenceDataVersion=1&maxAttendees=5&sendNotifications=true&sendUpdates=all&supportsAttachments=true';
            String accessToken = GMeetAuthHandler.getAccessToken(Organiser);
            system.debug('accessToken :: ' + accessToken);
            Http http = new Http(  );
            HttpRequest req = new HttpRequest(  );
            req.setMethod('POST');

            req.setEndpoint(GOOGLECALENDARENDPOINT + endPoint);
            req.setHeader('content-type', 'application/json');
            System.debug('Token----' + accessToken);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            //String body = '{"summary":"MT New Meeting","end": {"dateTime": "2022-08-28T09:30:00-08:00","timeZone": "America/Los_Angeles"},"start": {"dateTime": "2022-08-28T10:30:00-07:00","timeZone": "America/Los_Angeles"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":[{"email":"aakash.util@gmail.com"},{"email":"baskijha514@gmail.com"}]}';
            //req.setBody(body);
            string updatedBodyithoutAttendees = '{"summary":' + Title + ',"end": {"dateTime": ' + EndDateTime + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + StartDatetime + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}}}';

            system.debug('updatedBodyithoutAttendees :: ' + updatedBodyithoutAttendees);
            req.setBody(updatedBodyithoutAttendees);
            req.setHeader('Content-length', String.valueOf(updatedBodyithoutAttendees.length()));
            req.setTimeout(60 * 1000);
            HttpResponse resp = http.send(req);
            System.debug('Response-----' + resp.getBody());
            if ( resp.getStatusCode() == 200 || resp.getStatusCode() == 201 ){
                Map<String, Object> m = ( Map<String, Object> )JSON.deserializeUntyped(resp.getBody());
                responseMap.put('event_url', m.get('hangoutLink').toString());
                responseMap.put('event_id', m.get('id').toString());
                //return responseMap;
            }

            APILogWrap.body = updatedBodyithoutAttendees;
            APILogWrap.EndPoint = GOOGLECALENDARENDPOINT + endPoint;
            APILogWrap.ResponseMap = responseMap;
            APILogWrap.StatusCode = resp.getStatusCode();
            APILogWrap.ResponseString = resp.getBody();
            

        }
        catch(Exception e) {
            System.debug('Error Occured due to =======> ' + e.getMessage() + ' at line Number ======> ' + e.getLineNumber());

        }
        return APILogWrap;
    }

    public static APIWrapperForEventDetailsAndReports getEventDetail_V2(String bdEmail, String eventId){
        

        APIWrapperForEventDetailsAndReports APILogWrap = new APIWrapperForEventDetailsAndReports();

        String endPoint = GOOGLECALENDARENDPOINT+'/calendars/'+bdEmail+'/events/'+eventId+'?sendNotifications=true&sendUpdates=all';
        String accessToken = GMeetAuthHandler.getAccessToken(bdEmail);
        
        System.debug('endPoint'+endPoint);
         
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        
        req.setEndpoint(endPoint);
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        System.debug('Response-----' + resp.getBody());

        APILogWrap.ResponseString = resp.getBody();
        APILogWrap.StatusCode = resp.getStatusCode();
        APILogWrap.EndPoint = endPoint;
        
        System.debug('Response-----' + resp.getBody());
        return APILogWrap;
    }
    
    public static APIWrapperForEventDetailsAndReports getEventReportDetail_V2(String bdEmail, String meetingcode){ 

        APIWrapperForEventDetailsAndReports APILogWrap = new APIWrapperForEventDetailsAndReports();

        string SUPER_ADMIN_EMAIL = System.Label.SuperAdminEmail;
        String eventId = '0oueua451uc2g4asr4e1t5ei5g'; //google_meet_event_id
        String accessToken = GMeetAuthHandler.getReportAccessToken(SUPER_ADMIN_EMAIL);
         
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        string endpointstring = REPORTENDPOINT+'?filters='+'meeting_code=='+meetingcode;
        system.debug('endpointstring :; ' + endpointstring);
        req.setEndpoint(REPORTENDPOINT+'?filters='+'meeting_code=='+meetingcode);
        //req.setEndpoint(REPORTENDPOINT+'?filters='+'meeting_code==mtmvunnbcs');
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        APILogWrap.EndPoint = endpointstring;
        APILogWrap.ResponseString = resp.getBody();
        APILogWrap.StatusCode = resp.getStatusCode();
        
        System.debug('Response-----' + resp.getBody());
        return APILogWrap;
        //return resp.getBody();
    }

    public class APIWrapper{
        @AuraEnabled
        public String EndPoint{ get; set; }

        @AuraEnabled
        public String body{ get; set; }

        @AuraEnabled
        public integer StatusCode{ get; set; }

        @AuraEnabled
        public Map<String, String> ResponseMap{ get; set; }

        @AuraEnabled
        public String ResponseString{ get; set; }
    }

    public class APIWrapperForEventDetailsAndReports{
        @AuraEnabled
        public String EndPoint{ get; set;}
        @AuraEnabled
        public integer StatusCode { get; set;}
        @AuraEnabled
        public String ResponseString{ get; set;}
        
    }

}