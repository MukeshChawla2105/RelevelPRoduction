public with sharing class GMeetAPIHandler {

    //static string api_key = 'AIzaSyC67Vggk9U4UMYdJw6jx4XlTJ51gN9dPE0'; // For UAT
    static String bApi_Key = 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
    static string api_key = 'AIzaSyB4axY3ZOWy2ivrgdbiL752PJHZza5yrrU';   // For Production
    private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    private static final String REPORTENDPOINT = 'https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/meet';


    public static APIWrapper generateMeetLink_V2(string StartDatetime, string EndDateTime, String Title, String Description, List<String> attendeeList, String Organiser){

        Map<String, String> responseMap = new Map<String, String>();
        List<Map<String,String>> emailMapList = new List<Map<String,String>>();

        APIWrapper APILogWrap = new APIWrapper();
        
        for(String s : attendeeList){
            Map<String,String> emailMap = new Map<String,String>();
            emailMap.put('email',s);
            emailMapList.add(emailMap);
        }
        system.debug('emailMapList :: ' + emailMapList);
        system.debug('emailMapList :: ' + JSON.serialize(emailMapList));

        String bdEmail = 'harmanpreet.singh@relevel.com';
        String endPoint = '/calendars/'+Organiser+'/events?conferenceDataVersion=1&maxAttendees=5&sendNotifications=true&sendUpdates=all&supportsAttachments=true';
        String accessToken = GMeetAuthHandler.getAccessToken(Organiser);
         system.debug('accessToken :: ' + accessToken);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        
        req.setEndpoint(GOOGLECALENDARENDPOINT+endPoint);
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        string updatedBody = '{"summary":' + Title + ',"end": {"dateTime": ' + EndDateTime + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + StartDatetime + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":'+JSON.serialize(emailMapList)+'}';
        //String body = '{"summary":"MT New Meeting","end": {"dateTime": "2022-08-28T09:30:00-08:00","timeZone": "America/Los_Angeles"},"start": {"dateTime": "2022-08-28T10:30:00-07:00","timeZone": "America/Los_Angeles"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":[{"email":"aakash.util@gmail.com"},{"email":"baskijha514@gmail.com"}]}';
        //req.setBody(body);

        system.debug('updatedBody :: ' + updatedBody);
        req.setBody(updatedBody);
        req.setHeader('Content-length', String.valueOf(updatedBody.length()));
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        System.debug('Response-----' + resp.getBody());
        if(resp.getStatusCode()==200||resp.getStatusCode()==201){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            responseMap.put('event_url', m.get('hangoutLink').toString());
            responseMap.put('event_id', m.get('id').toString());
            //return responseMap;
        }

        APILogWrap.body = updatedBody;
        APILogWrap.EndPoint = GOOGLECALENDARENDPOINT+endPoint;
        APILogWrap.ResponseMap = responseMap;
        APILogWrap.StatusCode = resp.getStatusCode();
        APILogWrap.ResponseString = resp.getBody();
        return APILogWrap;

        //return responseMap;
    }
    
    public static APIWrapperForUpdationOrDeletion updateMeeting_V2(List<String> attendeesEmaillist, String bdEmail, String starttime, string enddatetime, string subject,  string eventId){
        Map<String, String> responseMap = new Map<String, String>();
        List<Map<String,String>> emailMapList = new List<Map<String,String>>();

        APIWrapperForUpdationOrDeletion APIWrapForReschedule = new APIWrapperForUpdationOrDeletion();
        
        for(String s : attendeesEmaillist){
            Map<String,String> emailMap = new Map<String,String>();
            emailMap.put('email',s);
            emailMapList.add(emailMap);
        }

        //String bdEmail = 'harmanpreet.singh@relevel.com';
        //String eventId = '0oueua451uc2g4asr4e1t5ei5g'; //google_meet_event_id
        String endPoint = GOOGLECALENDARENDPOINT+'/calendars/'+bdEmail+'/events/'+eventId+'?sendNotifications=true&sendUpdates=all';
        String accessToken = GMeetAuthHandler.getAccessToken(bdEmail);
        
        System.debug('endPoint'+endPoint);
         
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        
        req.setEndpoint(endPoint);
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        string updatedBody = '{"summary":' + subject + ',"end": {"dateTime": ' + enddatetime + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + starttime + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":'+JSON.serialize(emailMapList)+'}';
        //String body = '{"summary": ' + subject + ',"end": {"dateTime": ' + enddatetime + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + starttime + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}}}';
        //String body = '{"summary":"MT Meeting3","end": {"dateTime": "2022-10-28T09:00:00-08:00","timeZone": "America/Los_Angeles"},"start": {"dateTime": "2022-10-28T09:00:00-07:00","timeZone": "America/Los_Angeles"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}}}';
        req.setBody(updatedBody);
        req.setHeader('Content-length', String.valueOf(updatedBody.length()));
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        System.debug('Response-----' + resp.getBody());
        if(resp.getStatusCode()==200){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            string status=  m.get('status').toString();
            system.debug('status :: ' + status);
            //responseMap.put('Status', m.get('status').toString());
            if(status == 'confirmed'){
                //return 'Success';
                APIWrapForReschedule.SuccessORNot = 'Success';
            }
            
            
        }else{
            APIWrapForReschedule.SuccessORNot = 'Event not found!';
        }
            APIWrapForReschedule.body = updatedBody;
            APIWrapForReschedule.EndPoint = endPoint;
            APIWrapForReschedule.ResponseString = resp.getBody();
            APIWrapForReschedule.StatusCode = resp.getStatusCode();
        

            return  APIWrapForReschedule;
        //return 'Event not found!';
    }
    
    public static APIWrapperForUpdationOrDeletion deleteMeeting_V2(Event EventRec){

        APIWrapperForUpdationOrDeletion APIWrapForDeletion = new APIWrapperForUpdationOrDeletion();

        string bdEmail = [Select Id, Owner_Email__c From lead Where Id =:  EventRec.whoId].Owner_Email__c;
        String eventId = EventRec.GMeet_Event_Id__c;
        //String bdEmail = 'harmanpreet.singh@relevel.com';
        //String eventId = '0oueua451uc2g4asr4e1t5ei5g'; //google_meet_event_id
        String endPoint = GOOGLECALENDARENDPOINT+'/calendars/'+bdEmail+'/events/'+eventId+'?sendNotifications=true&sendUpdates=all';
        String accessToken = GMeetAuthHandler.getAccessToken(bdEmail);
        
        System.debug('endPoint'+endPoint);
         
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        
        req.setEndpoint(endPoint);
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        
        if(resp.getStatusCode()==204){
            //return 'Success';
            APIWrapForDeletion.SuccessORNot = 'Success';
        }
        else{
            APIWrapForDeletion.SuccessORNot = 'Event not found!';

        }
        System.debug('Response-----' + resp.getBody());
        APIWrapForDeletion.body = 'Body Do not required in this API';
        APIWrapForDeletion.EndPoint = endPoint;
        APIWrapForDeletion.ResponseString = resp.getBody();
        APIWrapForDeletion.StatusCode = resp.getStatusCode();
        return APIWrapForDeletion;
        //return 'Event not found!';
    }
    
    public static APIWrapperForEventDetailsAndReports getEventDetail_V2(String bdEmail, String eventId){
        //38jb9c8vud7fjjrtbl587it2b4 recording av;
        //rnbnl5vul0iu7b9bauqul5dpko //to be test
        //working event id = '38jb9c8vud7fjjrtbl587it2b4'
        
        //String bdEmail = 'harmanpreet.singh@relevel.com';
        //String bdEmail = 'testapi_1@relevel.com';
        //String eventId = 'rnbnl5vul0iu7b9bauqul5dpko'; //google_meet_event_id

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
        
        /*if(resp.getStatusCode()==204){
            //return resp.getBody();
            APILogWrap.ResponseString = resp.getBody();
            APILogWrap.StatusCode = resp.getStatusCode();
        }*/
        //APILogWrap.body = 'No body required In this API!';
        APILogWrap.ResponseString = resp.getBody();
        APILogWrap.StatusCode = resp.getStatusCode();
        APILogWrap.EndPoint = endPoint;
        
        System.debug('Response-----' + resp.getBody());
        return APILogWrap;
    }
    
    public static APIWrapperForEventDetailsAndReports getEventReportDetail_V2(String bdEmail, String meetingcode){                                         //String bdEmail, String meetingcode
        //String bdEmail = 'harmanpreet.singh@relevel.com';

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
        /*if(resp.getStatusCode()==204){
            //return resp.getBody();
            APILogWrap.ResponseString = resp.getBody();
            APILogWrap.StatusCode = resp.getStatusCode();
        }*/
        System.debug('Response-----' + resp.getBody());
        return APILogWrap;
        //return resp.getBody();
    }
    
    public static String getCalAvaibility_V2(DateTime StartTime, Datetime EndTime, String bdEmail){
        //working event id = '0oueua451uc2g4asr4e1t5ei5g'
        //meeting_code = 'https://meet.google.com/mtm-vunn-bcs'
        
        //String bdEmail = 'harmanpreet.singh@relevel.com';
        DateTime StartTimeForAPI = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day() , 3, 30, 0); 
        DateTime EndTimeForAPI = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day(), 20, 0, 0);

        string enddatetimeforAPI = (String.valueOf(EndTimeForAPI.date()) +'T'+String.valueOf(EndTimeForAPI.time()) +'+5:30').replace('.000Z', '');
        string StartdatetimeforAPI = (String.valueOf(StartTimeForAPI.date()) +'T'+String.valueOf(StartTimeForAPI.time()) +'+5:30').replace('.000Z', '');

        System.debug('StartTime For API :: ' + StartdatetimeforAPI);
        System.debug('EndTime for API :: ' + enddatetimeforAPI);
        //2022-08-31T20:00:00+05:30
        //string endpointString = GOOGLECALENDARENDPOINT+'/calendars/' + bdEmail +'/events?timeMax='+enddatetimeforAPI+'&timeMin='+StartdatetimeforAPI;

        string endpointString = GOOGLECALENDARENDPOINT+'/calendars/' + bdEmail +'/events?timeZone=Asia/Kolkata&timeMin='+String.valueOf(StartTimeForAPI.date())+'T'+String.valueOf(StartTimeForAPI.time())+'&timeMax='+String.valueOf(EndTimeForAPI.date())+'T'+String.valueOf(EndTimeForAPI.time());
        //String endPoint = GOOGLECALENDARENDPOINT+'/calendars/'+bdEmail+'/events?timeMax=2022-08-31T10:00:00-07:00&timeMin=2022-08-01T10:00:00-07:00';
        //events?timeMax=2022-08-31T20:00:00+5:30&timeMin=2022-08-31T08:00:00+5:30
        String accessToken = GMeetAuthHandler.getAccessToken(bdEmail);
        
        System.debug('endPoint String'+endpointString);
         
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        
        req.setEndpoint(endpointString);
        req.setHeader('content-type', 'application/json');
        System.debug('Token----'+accessToken);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        
        if(resp.getStatusCode()==204){
            return resp.getBody();
        }
        System.debug('Response-----' + resp.getBody());
        return resp.getBody();
    }

    public class APIWrapper{
        @AuraEnabled
        public String EndPoint{ get; set;}
        @AuraEnabled
        public String body{ get; set;}
        @AuraEnabled
        public integer StatusCode { get; set;}
        @AuraEnabled
        public Map<String, String> ResponseMap{ get; set;}
        @AuraEnabled
        public String ResponseString{ get; set;}
        
    }

    public class APIWrapperForUpdationOrDeletion{
        @AuraEnabled
        public String EndPoint{ get; set;}
        @AuraEnabled
        public String body{ get; set;}
        @AuraEnabled
        public integer StatusCode { get; set;}
        @AuraEnabled
        public String SuccessORNot{ get; set;}
        @AuraEnabled
        public String ResponseString{ get; set;}
        
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