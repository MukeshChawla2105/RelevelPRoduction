public without sharing class GMeetHandler{
    //static string api_key = 'AIzaSyC67Vggk9U4UMYdJw6jx4XlTJ51gN9dPE0'; // For UAT
    static String bApi_Key = 'AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
    static string api_key = 'AIzaSyB4axY3ZOWy2ivrgdbiL752PJHZza5yrrU';   // For Production
    private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    private static final String REPORTENDPOINT = 'https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/meet';
    @AuraEnabled
    public static String AddEvent(String eventrecord, String whoId, List<String> attendeesEmailList, String SManagerEmail, string SSManagerEmail){

        //System.debug('')
        string message = '';
        if ( eventrecord != null ){
            try{

                string str = '';
                System.debug('attendeesEmailList :: ' + attendeesEmailList);
                List<String> managerEmailList = new List<String>();
                if ( !attendeesEmailList.isEmpty() ){
                    str = String.join(attendeesEmailList, ',');
                }

                if ( SManagerEmail != null ){
                    attendeesEmailList.add(SManagerEmail);
                    managerEmailList.add(SManagerEmail);
                    //str = str+','+SManagerEmail;
                }
                if ( SSManagerEmail != null ){
                    attendeesEmailList.add(SSManagerEmail);
                    managerEmailList.add(SSManagerEmail);
                    //str = str+','+SSManagerEmail;
                }

                system.debug('eventrecord :: ' + eventrecord);
                List<String> attendeeList = new List<String>();
                Event eventrec = ( Event )JSON.deserialize(eventrecord, Event.class);
                system.debug('eventrec :: ' + eventrec);
                system.debug('eventrec :: ' + eventrec.StartDateTime);
                system.debug('eventrec :: ' + eventrec.EndDateTime);
                system.debug('eventrec start time in string format :: ' + JSON.serialize(eventrec.StartDateTime));
                system.debug('eventrec start time in string format :: ' + JSON.serialize(eventrec.EndDateTime));
                Lead leadRec = [Select Id, Email, Owner_Email__c
                                from Lead
                                Where id = :whoId];
                attendeeList.add(leadRec.Email);
                attendeeList.addAll(attendeesEmailList);
                system.debug('attendeeList :: ' + attendeeList);
                //str = str+','+leadRec.Email;
                //str = str.removeStart(',');

                string BDEMAIL = leadRec.Owner_Email__c;
                //Map<String, String> responseMap = GMeetHandler.createMeetLink(JSON.serialize(eventrec.StartDateTime), JSON.serialize(eventrec.EndDateTime), JSON.serialize(eventrec.Subject), JSON.serialize(eventrec.Description), attendeeList, leadRec.Owner_Email__c);

                GMeetAPIHandler.APIWrapper APILogWrap = GMeetAPIHandler.generateMeetLink_V2(JSON.serialize(eventrec.StartDateTime), JSON.serialize(eventrec.EndDateTime), JSON.serialize(eventrec.Subject), JSON.serialize(eventrec.Event_Description__c), attendeeList, leadRec.Owner_Email__c);
                //Map<String, String> responseMap = GMeetAPIHandler.generateMeetLink_V2(JSON.serialize(eventrec.StartDateTime), JSON.serialize(eventrec.EndDateTime), JSON.serialize(eventrec.Subject), JSON.serialize(eventrec.Event_Description__c), attendeeList, leadRec.Owner_Email__c);
                Map<String, String> responseMap = APILogWrap.ResponseMap;
                system.debug('responseMap ::' + responseMap);
                message = 'API Error, Please Try Again!';
                if ( responseMap.get('event_url') != null && responseMap.get('event_id') != null ){
                    System.debug('responseMap.get(event_url) =========>' + responseMap.get('event_url'));
                    System.debug('responseMap.get(event_id) =========>' + responseMap.get('event_id'));
                    eventrec.Meeting_URL__c = responseMap.get('event_url');
                    eventrec.GMeet_Event_Id__c = responseMap.get('event_id');
                    eventrec.Attendees_Except_BDE__c = String.join(attendeeList, ',');
                    eventrec.WhoId = whoId;
                    eventrec.Event_Status__c = 'Open';
                    eventrec.Type = 'Google Meet';
                    eventrec.Attendees_list__c = str;               //+','+SManagerEmail+','+SSManagerEmail;
                    if ( SManagerEmail != null ){
                        eventrec.IsSMInvited__c = true;
                    }
                    if ( SSManagerEmail != null ){
                        eventrec.IsSSMInvited__c = true;
                    }
                    string managerEmailString = String.join(managerEmailList, ',');
                    eventrec.Managers_Invited__c = managerEmailString;
                    eventrec.IsReminderSet = true;
                    eventrec.ReminderDateTime = eventrec.StartDateTime.addhours(-1);
                    system.debug('eventrec :: ' + eventrec);
                    if ( eventrec.Meeting_URL__c != null && eventrec.GMeet_Event_Id__c != null ){
                        System.debug('eventrec ========> ' + eventrec);
                        insert eventrec;
                        message = 'Event Created Successfully';
                    }
                }
                if ( eventrec.id != null && !String.isEmpty(eventrec.id) ){
                    System.debug('let me send Email and Create API Log');
                    
                    if ( APILogWrap.EndPoint != null && APILogWrap.body != null && APILogWrap.ResponseString != null && APILogWrap.StatusCode != null ){
                        APILOGSCapture.captureLogs(APILogWrap.EndPoint, APILogWrap.body, APILogWrap.StatusCode, APILogWrap.ResponseString, String.valueof(APILogWrap.ResponseMap), eventrec.id);
                    }
                    //GMeetHandler.SendEmailTolearner(eventrec);
                }
                else{
                    System.debug('let me Create API Log only');
                    if ( APILogWrap.EndPoint != null && APILogWrap.body != null && APILogWrap.ResponseString != null && APILogWrap.StatusCode != null ){
                        APILOGSCapture.captureLogs(APILogWrap.EndPoint, APILogWrap.body, APILogWrap.StatusCode, APILogWrap.ResponseString, String.valueof(APILogWrap.ResponseMap), 'Event is not Created');
                    }
                }
            }
            catch ( Exception e ){
                Gmeet_Exception__c GMExcep = new Gmeet_Exception__c();
                GMExcep.Error_Message__c = e.getMessage();
                GMExcep.At_line_Number__c = e.getLineNumber();
                GMExcep.Cause__c = String.valueof(e.getCause());
                GMExcep.Type__c = e.getTypeName();
                insert GMExcep;
                return 'Exception Occurred : ' + e.getMessage() + ' AT Line Number ::  ' + e.getLineNumber();
            }

        }
        else{
            return 'Please Provide Event Subject';
        }
        return message;
    }

    @AuraEnabled
    Public static string EventVanished(Event EventRec){

        system.debug('EventRec ::' + EventRec);
        string message = '';
        try{
            GMeetAPIHandler.APIWrapperForUpdationOrDeletion APIWrapForDeletion = GMeetAPIHandler.deleteMeeting_V2(EventRec);
            string responseString = APIWrapForDeletion.SuccessORNot;
            //string responseString = GMeetAPIHandler.deleteMeeting_V2(EventRec);
            //string responseString = GMeetHandler.deleteEvent(EventRec);
            if ( responseString == 'Success' ){
                EventRec.Event_Status__c = 'Cancelled';
                EventRec.IsReminderSet = true;
                update EventRec;
                APILOGSCapture.captureLogs(APIWrapForDeletion.EndPoint, APIWrapForDeletion.body, APIWrapForDeletion.StatusCode, APIWrapForDeletion.ResponseString, null, EventRec.id);
                message = 'Success';
            }

        }
        catch ( Exception e ){
            System.debug('the Error occurred due to ======> ' + e.getMessage());
            System.debug('the Error occurred at line number ======> ' + e.getLineNumber());
            Gmeet_Exception__c GMExcep = new Gmeet_Exception__c();
            GMExcep.Error_Message__c = e.getMessage();
            GMExcep.At_line_Number__c = e.getLineNumber();
            GMExcep.Cause__c = String.valueof(e.getCause());
            GMExcep.Type__c = e.getTypeName();
            insert GMExcep;

            message = e.getMessage();
        }
        return message;
    }

    @AuraEnabled
    public static String RescheduleGmeet(Event UpdatedEventRec){

        System.debug('UpdatedEventRec ::' + UpdatedEventRec);
        if ( UpdatedEventRec != null ){
            try{
                String OwnerEmail = [Select id, Owner_Email__c
                                     From lead
                                     where id = :UpdatedEventRec.whoId].Owner_Email__c;
                //String AllAttendeesExceptBDE = [Select id,Owner_Email__c, Attendees_Except_BDE__c From lead where id =: UpdatedEventRec.whoId].Attendees_Except_BDE__c;
                List<String> AllAttendees = UpdatedEventRec.Attendees_Except_BDE__c.split(',');
                system.debug('eventrec start time in string format :: ' + JSON.serialize(UpdatedEventRec.StartDateTime));
                system.debug('eventrec start time in string format :: ' + JSON.serialize(UpdatedEventRec.EndDateTime));
                GMeetAPIHandler.APIWrapperForUpdationOrDeletion APIWrapForReschedule = GMeetAPIHandler.updateMeeting_V2(AllAttendees, OwnerEmail, JSON.serialize(UpdatedEventRec.StartDateTime), JSON.serialize(UpdatedEventRec.EndDateTime), JSON.serialize(UpdatedEventRec.Subject), UpdatedEventRec.GMeet_Event_Id__c);
                String responseString = APIWrapForReschedule.SuccessORNot;
                //String responseString = GMeetAPIHandler.updateMeeting_V2(AllAttendees, OwnerEmail, JSON.serialize(UpdatedEventRec.StartDateTime), JSON.serialize(UpdatedEventRec.EndDateTime), JSON.serialize(UpdatedEventRec.Subject), UpdatedEventRec.GMeet_Event_Id__c);
                //String responseString = GMeetHandler.updateEvent(JSON.serialize(UpdatedEventRec.StartDateTime), JSON.serialize(UpdatedEventRec.EndDateTime), JSON.serialize(UpdatedEventRec.Subject), UpdatedEventRec.GMeet_Event_Id__c);
                System.debug('responseString :: ' + responseString);
                if ( responseString == 'Success' ){
                    UpdatedEventRec.Event_Status__c = 'Rescheduled';
                    update UpdatedEventRec;
                    APILOGSCapture.captureLogs(APIWrapForReschedule.EndPoint, APIWrapForReschedule.body, APIWrapForReschedule.StatusCode, APIWrapForReschedule.ResponseString, null, UpdatedEventRec.id);

                }
            }
            catch ( Exception e ){
                Gmeet_Exception__c GMExcep = new Gmeet_Exception__c();
                GMExcep.Error_Message__c = e.getMessage();
                GMExcep.At_line_Number__c = e.getLineNumber();
                GMExcep.Cause__c = String.valueof(e.getCause());
                GMExcep.Type__c = e.getTypeName();
                insert GMExcep;
                return 'Exception Occurred : ' + e.getMessage() + ' AT ' + e.getLineNumber();
            }
        }
        return 'SUCCESS';
    }

    @AuraEnabled
    public static String queryEventRec(string eventId){
        Event eventRec = [Select Id, Description, Event_Description__c, GMeet_Event_Id__c, Attendees__c, Recording_URL__c, whoId, meeting_Url_Charcter__c
                          From Event
                          Where Id = :eventId];
        string reespo = GetAndUpdateEventDetails(eventRec);
        return reespo;
    }

    @AuraEnabled
    public static String GetAndUpdateEventDetails(Event eventRec){
        String respMsg = '';
        system.debug('eventId-->' + eventRec);
        try{
            List<Object> attachmentList = new List<Object>();
            //Event eventRec = [Select Id, Description, Event_Description__c, GMeet_Event_Id__c, Attendees__c, Recording_URL__c, whoId, meeting_Url_Charcter__c
            //           From Event
            //           Where Id = :eventId];

            string meetingcode = ( eventRec.meeting_Url_Charcter__c ).replace('-', '');
            //system.debug('meetingcode :: ' + meetingcode);
            String BDEmail =  '';
            Lead ld = [Select id, Audit_Officer__c, Audit_Officer_Email__c, Owner_Email__c, Lead_Version__c 
                        From Lead 
                        Where id = :eventRec.whoId];
            if (ld.Lead_Version__c == 'V1') {
                BDEmail = ld.Audit_Officer_Email__c;
            }else{
                BDEmail = ld.Owner_Email__c;
            }

            // String BDEmail = [Select Id, Owner_Email__c
            //                   From Lead
            //                   Where id = :eventRec.whoId].Owner_Email__c;

            GMeetAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventdetails = GMeetAPIHandler.getEventDetail_V2(BDEmail, eventRec.GMeet_Event_Id__c);
            System.debug('APIWrapforEventdetails =======> ' + APIWrapforEventdetails);

            string ResponseString = APIWrapforEventdetails.ResponseString;

            GMeetAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventReport = GMeetAPIHandler.getEventReportDetail_V2(BDEmail, meetingcode);

            System.debug('APIWrapforEventReport =======> ' + APIWrapforEventReport);

            string ResponseStringForTimeCalculation = APIWrapforEventReport.ResponseString;
            System.debug('ResponseStringForTimeCalculation :: ' + ResponseStringForTimeCalculation);
            if ( APIWrapforEventReport.ResponseString != null ){
                APILOGSCapture.captureLogs(APIWrapforEventReport.EndPoint, 'Body Not required', APIWrapforEventReport.StatusCode, APIWrapforEventReport.ResponseString, null, eventRec.id);
            }
            if ( APIWrapforEventdetails.ResponseString != null ){
                APILOGSCapture.captureLogs(APIWrapforEventdetails.EndPoint, 'Body Not required', APIWrapforEventdetails.StatusCode, APIWrapforEventdetails.ResponseString, null, eventRec.id);
            }

            //string ResponseStringForTimeCalculation = GMeetAPIHandler.getEventReportDetail_V2(BDEmail, meetingcode);
            //system.debug('Response String For Time Calculation :: ' + ResponseStringForTimeCalculation);
            MeetingDetailsWrap MeetWrapToUpdateEventDetails = GMeetHandler.CalculateMeetingTimes(ResponseStringForTimeCalculation, eventRec.whoId);
            system.debug('MeetWrapToUpdateEventDetails :: ' + MeetWrapToUpdateEventDetails);

            system.debug('ResponseString :: ' + ResponseString);
            Event updatedEventRec = new Event();
            updatedEventRec.id = eventRec.id;
            updatedEventRec.Attendees__c = '';
            Map<String, Object> m = ( Map<String, Object> )JSON.deserializeUntyped(ResponseString);

            if ( m.containsKey('attendees') ){
                List<Object> attendees = ( List<Object> )m.get('attendees');
                if ( ( List<Object> )m.get('attachments') != null ){
                    attachmentList = ( List<Object> )m.get('attachments');
                }
                else{

                }
                System.debug('attendees :: ' + attendees);
                System.debug('attachmentList :: ' + attachmentList);
                if ( !attendees.isEmpty() ){
                    //e.Attendees__c = e.Attendees__c == null ? '' : e.Attendees__c;
                    for ( Object attObj : attendees ){
                        Map<String, Object> attMap = ( Map<String, Object> )attObj;
                        updatedEventRec.Attendees__c += attMap.get('email') + ' ,';
                    }
                    updatedEventRec.Attendees__c = updatedEventRec.Attendees__c.removeEnd(',');
                }
                else{
                    respMsg = 'Attendees,';
                }
            }
            else{
                respMsg = 'Event Record not found!';
            }
            System.debug('updatedEventRec.Attendees__c :: ' + updatedEventRec.Attendees__c);

            if ( !respMsg.contains('Event Record not found!') ){
                if ( MeetWrapToUpdateEventDetails.AttendeeEmailList != null || MeetWrapToUpdateEventDetails.AttendeesMapwithDuration != null || MeetWrapToUpdateEventDetails.CallDuration != null ){
                    if ( MeetWrapToUpdateEventDetails.AttendeeEmailList != null ){
                        string emaillistString = String.join(MeetWrapToUpdateEventDetails.AttendeeEmailList, ',');
                        //updatedEventRec.Actual_Attendees_Email_List__c = emaillistString;
                    }
                    if ( MeetWrapToUpdateEventDetails.AttendeesMapwithDuration != null ){
                        updatedEventRec.Description = 'Attendees List With Duration(in seconds) ' + '\n' + MeetWrapToUpdateEventDetails.AttendeesMapwithDuration;
                        updatedEventRec.Event_Status__c = 'Completed';
                    }
                    if ( MeetWrapToUpdateEventDetails.CallDuration != null ){
                        updatedEventRec.Gmeet_call_Duration__c = MeetWrapToUpdateEventDetails.CallDuration;
                    }
                    updatedEventRec.Event_Actual_Start_Time__c = MeetWrapToUpdateEventDetails.ActualStartDateTime;
                    updatedEventRec.Event_Actual_End_Time__c = MeetWrapToUpdateEventDetails.ActualEndDateTime;
                }
                else{
                    respMsg += 'Events Details processing is in Progress!' + ' ';
                }
                integer i = 0;
                updatedEventRec.Recording_URL__c = '';
                if ( !attachmentList.isEmpty() ){
                    if(attachmentList.size() > 1){
                        for ( Object attachObj : attachmentList ){
                            i++;
                            Map<String, Object> attachmentMap = ( Map<String, Object> )attachObj;
                            updatedEventRec.Recording_URL__c +=  i + '. ' + attachmentMap.get('fileUrl').toString() +  '\n';
                        }

                    }
                    else{
                        Map<String, Object> attachmentMap = ( Map<String, Object> )attachmentList[0];
                        updatedEventRec.Recording_URL__c +=  attachmentMap.get('fileUrl').toString();

                    }
                    

                    //updatedEventRec.Recording_URL__c = updatedEventRec.Recording_URL__c.removeEnd(',');
                    System.debug('Recording_URL__c =======> '  + updatedEventRec.Recording_URL__c );
                    

                    // Map<String, Object> attachmentMap = ( Map<String, Object> )attachmentList[0];
                    // updatedEventRec.Recording_URL__c = attachmentMap.get('fileUrl').toString();
                    updatedEventRec.IsGmeetRecordingAvailable__c = true;
                    respMsg = respMsg.contains('Attendees') ? respMsg.removeEnd(',') + ' not found' : 'Success';
                }
                else{
                    if ( respMsg.contains('Events Details processing is in Progress') ){
                        respMsg += 'Recording Processing is also In progress!';
                        updatedEventRec.Recording_URL__c = 'Recording Url Processing is in Progress!';
                    }
                    else{
                        updatedEventRec.Recording_URL__c = 'Recording Was not Initiated!';
                        // updatedEventRec.Event_Status__c = 'Completed';
                        respMsg = 'Recording link not found';
                    }
                }

            }
            else{

            }

            update updatedEventRec;
            return respMsg;
        }
        catch ( Exception e ){
            System.debug('Exception----' + e.getMessage());
            system.debug('error-->' + e.getLineNumber());
            Gmeet_Exception__c GMExcep = new Gmeet_Exception__c();
            GMExcep.Error_Message__c = e.getMessage();
            GMExcep.At_line_Number__c = e.getLineNumber();
            GMExcep.Cause__c = String.valueof(e.getCause());
            GMExcep.Type__c = e.getTypeName();
            insert GMExcep;
            return e.getMessage();
        }
        //return respMsg;
    }

    public Static MeetingDetailsWrap CalculateMeetingTimes(String ResponseString, string leadId){
        MeetingDetailsWrap MeetWrap = new MeetingDetailsWrap();

        List<datetime> StartDatetimeList = new List<datetime>();
        List<datetime> EndDatetimeList = new List<datetime>();
        List<String> AttendeeesNameList = new List<String>();
        List<String> AttendeeesEmailList = new List<String>();
        map<String, String> AttendeesMapWithDuration = new Map<String, String>();
        map<String, Integer> AttendeesMapWithSmmedMultipleDuration = new map<String, Integer>();
        map<String, List<String>> AttendeesMapWithMultipleDuration = new map<String, List<String>>();
        datetime LastDateTime;
        datetime FirstDateTime;
        string attendeesEmail;
        string attendeescallDuration;

        //system.debug('Response String For Time Calculation :: ' + ResponseString);

        Map<String, Object> m = ( Map<String, Object> )JSON.deserializeUntyped(ResponseString);
        //system.debug('m :: ' + m);

        if ( m.containsKey('items') ){
            system.debug('Items Existed in the Map!!!!');
            list<Object> ItemDetails = ( list<object> )m.get('items');
            for ( Object obj : ItemDetails ){
                //system.debug('obj :: ' + obj);

                Map<String, Object> Objmap = ( Map<String, Object> )JSON.deserializeUntyped(JSON.serialize(obj));
                //system.debug('Objmap :: ' + Objmap);
                Map<String, Object> IdMap = ( Map<String, Object> )Objmap.get('id');

                Map<String, Object> ActorMap = ( Map<String, Object> )Objmap.get('actor');
                string CallerType = String.valueOf(ActorMap.get('callerType'));
                System.debug('CallerType =====> ' +CallerType);

                if (CallerType == 'Key') {
                    System.debug('I am inside callertype == key');
                    attendeesEmail = 'HANGOUTS_EXTERNAL_OR_ANONYMOUS';
                    //string attendeesEmail;
                }
                
                //system.debug('IdMap :: ' + IdMap);
                DateTime date1 = (DateTime) Json.deserialize('"' + IdMap.get('time') + '"', DateTime.class);
                Integer addsecondtodatetime;
                //system.debug('dateTime  :; ' + date1);
                
                StartDatetimeList.add(date1);
                list<Object> EventDetails = ( list<object> )Objmap.get('events');
                //system.debug('EventDetails  :; ' + EventDetails);
                Map<String, Object> ObjectofParamters = ( Map<String, Object> )EventDetails[0];
                //system.debug('mapofParamters  :; ' + ObjectofParamters);
                list<Object> listofobjectofParamters = ( list<object> )ObjectofParamters.get('parameters');
                //system.debug('listofmapofParamters  :; ' + listofobjectofParamters);
                for ( Object tempObj : listofobjectofParamters ){
                    //system.debug('tempObj  :; ' + tempObj);

                    Map<String, Object> parametersMap = ( Map<String, Object> )JSON.deserializeUntyped(JSON.serialize(tempObj));
                    //system.debug('parametersMap  :; ' + parametersMap);
                    string Parametername = String.valueof(parametersMap.get('name'));
                    string Parametervalue = String.valueof(parametersMap.get('value'));
                    string ParameterINTvalue = String.valueof(parametersMap.get('intValue'));
                    if ( !parametersMap.isEmpty() ){
                        if ( parametersMap.get('name') != null && parametersMap.get('name') == 'display_name' ){
                            AttendeeesNameList.add(Parametervalue);
                        }
                        if ( parametersMap.get('name') != null && parametersMap.get('name') == 'identifier' ){
                            System.debug('I am inside callertype == key');
                            AttendeeesEmailList.add(Parametervalue);
                            attendeesEmail = String.valueOf(Parametervalue);
                        }
                        else {
                        }
                        if ( parametersMap.get('name') != null && parametersMap.get('name') == 'duration_seconds' ){
                            addsecondtodatetime = integer.valueof(ParameterINTvalue);
                            attendeescallDuration = string.valueOf(ParameterINTvalue);
                        }
                    }
                }
                if ( AttendeesMapWithMultipleDuration.containsKey(attendeesEmail) ){
                    system.debug('inside If');
                    list<String> AttendessDuration = AttendeesMapWithMultipleDuration.get(attendeesEmail);
                    AttendessDuration.add(attendeescallDuration);
                }
                else{

                    system.debug('inside else');
                    list<String> AttendessDuration = New list<String>();
                    AttendessDuration.add(attendeescallDuration);
                    AttendeesMapWithMultipleDuration.put(attendeesEmail, AttendessDuration);

                }
                if ( AttendeesMapWithSmmedMultipleDuration.containsKey(attendeesEmail) ){
                    system.debug('inside If');
                    integer presentTimeDuration = Integer.valueof(AttendeesMapWithSmmedMultipleDuration.get(attendeesEmail));
                    integer newTimeDuartionvalue = presentTimeDuration + addsecondtodatetime;
                    AttendeesMapWithSmmedMultipleDuration.put(attendeesEmail, newTimeDuartionvalue);
                }
                else{
                    system.debug('inside else');
                    AttendeesMapWithSmmedMultipleDuration.put(attendeesEmail, addsecondtodatetime);
                }

                AttendeesMapWithDuration.put(attendeesEmail, attendeescallDuration);
                datetime datetimeEND = date1.addSeconds(addsecondtodatetime);
                system.debug('datetimeEND :: ' + datetimeEND);
                EndDatetimeList.add(datetimeEND);
            }
            System.debug('AttendeesMapWithMultipleDuration :: ' + AttendeesMapWithMultipleDuration);
            System.debug('AttendeesMapWithSmmedMultipleDuration :: ' + AttendeesMapWithSmmedMultipleDuration);
            system.debug('AttendeesMapWithDuration :: ' + AttendeesMapWithDuration);

            // Method for Updating Lead interview status (Ao) Based on the Event Description Email
            UpdateLeadInterviewStatusBasedOnEvtDesc.GetEventDescriptionDetails(AttendeesMapWithDuration, leadId);

            String mapString = String.valueOf(AttendeesMapWithDuration);
            String mapStringWithCumulativeTime = String.valueOf(AttendeesMapWithSmmedMultipleDuration);
            system.debug('mapString :: ' + mapString);
            system.debug('mapString :: ' + mapStringWithCumulativeTime);
            //system.debug('Attendeees Name List:: ' + AttendeeesNameList);
            //system.debug('Attendeees Email List :: ' + AttendeeesEmailList);
            system.debug('List of Start Date time :: ' + StartDatetimeList);
            system.debug('List of End Date time :: ' + EndDatetimeList);
            if ( !EndDatetimeList.isEmpty() ){
                LastDateTime = sortDatetimeList(EndDatetimeList);
            }

            if ( !StartDatetimeList.isEmpty() ){
                FirstDateTime = calculateStartmostTime(StartDatetimeList);
            }
            Long LastDatetimeInMs = LastDateTime.getTime();
            Long FirstDateTimeInMs = FirstDateTime.getTime();
            Long CallDurationInMs = LastDatetimeInMs - FirstDateTimeInMs;
            Long CallDurationInMin = CallDurationInMs / ( 1000 * 60 );
            MeetWrap.AttendeeEmailList = AttendeeesEmailList;
            MeetWrap.ActualStartDateTime = FirstDateTime;
            MeetWrap.ActualEndDateTime = LastDateTime;
            MeetWrap.AttendeeNameList = AttendeeesNameList;
            MeetWrap.CallDuration = CallDurationInMin;
            MeetWrap.AttendeesMapwithDuration = mapStringWithCumulativeTime;
            return MeetWrap;
        }
        else{
            system.debug('Items not Existed in the Map!!!!');
        }
        return MeetWrap;
    }

    public static datetime sortDatetimeList(List<datetime> dateTimeList){
        datetime largestDate;
        for ( Integer i = 0; i < dateTimeList.size(); i++ ){
            if ( i == 0 ){
                largestDate = dateTimeList[i];
            }
            else if ( largestDate < dateTimeList[i] ){
                largestDate = dateTimeList[i];
            }
        }
        system.debug('largestDate::' + largestDate);
        return largestDate;
    }

    public static datetime calculateStartmostTime(List<datetime> dateTimeList){
        datetime SmallestDate;
        for ( Integer i = 0; i < dateTimeList.size(); i++ ){
            if ( i == 0 ){
                SmallestDate = dateTimeList[i];
            }
            else if ( SmallestDate > dateTimeList[i] ){
                SmallestDate = dateTimeList[i];
            }
        }
        system.debug('SmallestDate :: ' + SmallestDate);
        return SmallestDate;
    }

    public Static void SendEmailTolearner(Event eventrec){

        system.debug('eventrec :: ' + eventrec);
        Lead ld = [Select id, Name, Email
                   From Lead
                   Where Id = :eventrec.WhoId];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTempRec = [SELECT Id, Subject, HtmlValue, Body
                                      FROM EmailTemplate
                                      WHERE Name = 'Google Meet Scheduled'];
        system.debug('emailTempRec subject :: ' + emailTempRec.Subject);
        system.debug('emailTempRec body :: ' + emailTempRec.Body);
        system.debug('emailTempRec ::  ' + emailTempRec);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(  );

        if ( ld.Email != null ){
            String[] toAddresses = new String[]{ ld.Email };
            email.setToAddresses(toAddresses);
        }

        String htmlBody = emailTempRec.HtmlValue;
        if ( htmlBody.contains('{!Lead.Name}') ){
            htmlBody = htmlBody.replace('{!Lead.Name}', ld.Name);
        }
        if ( htmlBody.contains('{!Event.MeetingLink}') ){
            htmlBody = htmlBody.replace('{!Event.MeetingLink}', eventrec.Meeting_URL__c); //MeetingStartTime
        }
        if ( htmlBody.contains('{!Event.StartTime}') ){
            htmlBody = htmlBody.replace('{!Event.StartTime}', String.valueOf(eventrec.StartDateTime));
        }
        email.setHtmlBody(htmlBody);
        email.setSubject(emailTempRec.Subject);
        emails.add(email);
        system.debug('emails :: ' + emails);
        if ( !emails.isEmpty() ){
            Messaging.sendEmail(emails);
        }
    }

    @AuraEnabled
    public static CreatedEventRecWithUserInfo PassEventDetailsOnDoint(String LeadId){

        CreatedEventRecWithUserInfo EventUserInfoWrap = new CreatedEventRecWithUserInfo();

        Lead ld = [Select Id, Name, Email
                   From Lead
                   Where Id = :LeadId];
        if ( ld.email == Null ){
            ld.email = '';
        }
        EventUserInfoWrap.leadDetail = ld;

        user userRec = [SELECT AccountId, ManagerId, manager.isActive, manager.Name, manager.Email, Email, Id, IsActive, manager.managerId, manager.manager.isActive, manager.manager.Name, manager.manager.Email
                        From User
                        Where Id = :UserInfo.getUserId()];
        System.debug('user Record :: ' + userRec);
        System.debug('user Record :: ' + userRec.ManagerId);
        System.debug('user Record :: ' + userRec.manager.Name);
        System.debug('user Record :: ' + userRec.manager.Email);
        System.debug('user Record :: ' + userRec.manager.managerId);
        System.debug('user Record :: ' + userRec.manager.manager.Name);
        System.debug('user Record :: ' + userRec.manager.manager.Email);
        EventUserInfoWrap.UserInfodetails = userRec;

        list<Event> EventRec = [SELECT Attendees_list__c, Attendees__c, Email__c, Subject, Managers_Invited__c, Event_Description__c, Description, EndDateTime, Event_Status__c, Gmeet_call_Duration__c, GMeet_Event_Id__c, Id, IsSMInvited__c, IsSSMInvited__c, Meeting_URL__c, StartDateTime, WhatId, WhoId, Attendees_Except_BDE__c
                                FROM Event
                                Where Whoid = :LeadId AND ( Event_Status__c = 'Open' OR Event_Status__c = 'Rescheduled' )];
        System.debug('EventRec Record :: ' + EventRec);
        if ( !EventRec.isEmpty() ){

            EventUserInfoWrap.EventRecDetail = EventRec[0];
        }
        else{
            event emptyEventRec = new event();
            emptyEventRec.subject = '';
            emptyEventRec.Attendees_list__c = '';
            emptyEventRec.Attendees__c = '';
            emptyEventRec.Email__c = '';
            emptyEventRec.Event_Description__c = '';
            emptyEventRec.GMeet_Event_Id__c = '';
            emptyEventRec.Event_Status__c = '';
            //emptyEventRec.IsSMInvited__c = '';
            //emptyEventRec.IsSSMInvited__c = '';
            //emptyEventRec.WhoId = '';
            EventUserInfoWrap.EventRecDetail = emptyEventRec;
        }
        system.debug('EventUserInfoWrap :: ' + EventUserInfoWrap);
        return EventUserInfoWrap;
    }

    @AuraEnabled
    Public Static Lead FetchLeadDetails(String LeadId){
        Lead ld = [Select Id, Name, Email
                   From Lead
                   Where Id = :LeadId];
        return ld;
    }

    @AuraEnabled
    public Static List<ActualSlotAvailablity> CheckAvailableSlotFromAPI(DateTime StartTime, Datetime EndTime, String Email){
        List<ActualSlotAvailablity> SlotwrapList = new List<ActualSlotAvailablity>();
        try{
            Map<string, Set<string>> meetingTimeByStartOrEnd = new Map<String, Set<string>>();

            String ResponseString = GMeetAPIHandler.getCalAvaibility_V2(StartTime, EndTime, Email);

            Object userProfileDetail = (Object) JSON.deserializeUntyped(ResponseString);
            map<string, object> tempObj = ( map<string, object> )userProfileDetail;
            list<Object> ItemDetails = ( list<object> )tempObj.get('items');
            List<bookedSlotsWrapper> meetingStartTimeAndEndTimeWrap = new List<bookedSlotsWrapper>();

            for ( Object obj : ItemDetails ){
                map<string, object> itemDetailMap = ( map<string, object> )obj;
                Object startDate = itemDetailMap.get('start');
                object endDate = itemDetailMap.get('end');
                map<string, object> startdateMap = ( map<string, object> )startDate;
                map<string, object> enddateMap = ( map<string, object> )endDate;
                bookedSlotsWrapper slotsWrapInstance = new bookedSlotsWrapper();


                //slotsWrapInstance.endTime = String.valueOf(enddateMap.get('dateTime'));
                //slotsWrapInstance.startTime = String.valueOf(startdateMap.get('dateTime'));
                Date StartDateSlot = Date.valueOf(String.valueOf(startdateMap.get('dateTime')).substring(0, 10));
                Time startTimeSlot = Time.newInstance(Integer.valueOf(string.valueOf(startdateMap.get('dateTime')).substring(11, 13)), Integer.valueOf(string.valueOf(startdateMap.get('dateTime')).substring(14, 16)), 0, 0);
                Date endDateSlot = Date.valueOf(String.valueOf(enddateMap.get('dateTime')).substring(0, 10));
                Time endTimeSlot = Time.newInstance(Integer.valueOf(string.valueOf(enddateMap.get('dateTime')).substring(11, 13)), Integer.valueOf(string.valueOf(enddateMap.get('dateTime')).substring(14, 16)), 0, 0);

                slotsWrapInstance.startTime_v1 = DateTime.newInstance(StartDateSlot, startTimeSlot).addMinutes(330);
                slotsWrapInstance.endTime_v1 = DateTime.newInstance(endDateSlot, endTimeSlot).addMinutes(330);
                system.debug('slotsWrapInstance-->' + slotsWrapInstance);

                meetingStartTimeAndEndTimeWrap.add(slotsWrapInstance);

                if ( meetingTimeByStartOrEnd.isEmpty() ){
                    meetingTimeByStartOrEnd.put('start', new Set<String>{ String.valueOf(startdateMap.get('dateTime')) });
                    meetingTimeByStartOrEnd.put('end', new Set<String>{ String.valueOf(enddateMap.get('dateTime')) });
                }
                else{
                    if ( meetingTimeByStartOrEnd.containsKey('start') ){
                        Set<String> startTiming = meetingTimeByStartOrEnd.get('start');
                        startTiming.add(String.valueOf(startdateMap.get('dateTime')));
                        meetingTimeByStartOrEnd.put('start', startTiming);
                    }
                    if ( meetingTimeByStartOrEnd.containsKey('end') ){
                        Set<String> endTiming = meetingTimeByStartOrEnd.get('end');
                        endTiming.add(String.valueOf(enddateMap.get('dateTime')));
                        meetingTimeByStartOrEnd.put('end', endTiming);
                    }
                }
            }
            system.debug('meetingStartTimeAndEndTimeWrap-->' + meetingStartTimeAndEndTimeWrap);

            SlotwrapList = GMeetHandler.CalculateAvailableSlot(StartTime, EndTime, meetingTimeByStartOrEnd, meetingStartTimeAndEndTimeWrap);
        }
        catch ( Exception ex ){
            System.debug('Exception----' + ex.getMessage() + 'at line Number ::  ' + ex.getLineNumber());
        }
        return SlotwrapList;
    }

    //@AuraEnabled
    public static List<ActualSlotAvailablity> CalculateAvailableSlot(DateTime StartTime, Datetime EndTime, Map<string, Set<string>> meetingTimeByStartOrEnd, List<bookedSlotsWrapper> meetingStartTimeAndEndTimeWrap){
        List<ActualSlotAvailablity> SlotwrapList = new List<ActualSlotAvailablity>();
        List<slotsToBeMarkedBooked> slotToBeBookedList = new List<slotsToBeMarkedBooked>();

        dateTime TodayDateTime = system.now();
        DateTime SlotstartTimeOfTheDay = DateTime.newInstance(TodayDateTime.year(), TodayDateTime.month(), TodayDateTime.day(), 15, 30, 0);
        DateTime SlotEndTimeOfTheDay = DateTime.newInstance(TodayDateTime.year(), TodayDateTime.month(), TodayDateTime.day(), 25, 30, 0);
        Long minutesbetweenStartTimeAndEndTIme = ( SlotEndTimeOfTheDay.getTime() - SlotstartTimeOfTheDay.getTime() ) / ( 1000 * 60 );
        Long iterationLength = ( minutesbetweenStartTimeAndEndTIme ) / 10;
        if ( !meetingStartTimeAndEndTimeWrap.isEmpty() ){
            for ( integer i = 0; i < iterationLength; i++ ){
                // AllBookedAndUnbookedSlots Slotwrap = new AllBookedAndUnbookedSlots();
                DateTime startTimeSlot = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day(), 15, 10 * ( i + 3 ), 0);
                DateTime EndTimeSlot = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day(), 15, 10 * ( i + 4 ), 0);

                for ( bookedSlotsWrapper slotWrapRec : meetingStartTimeAndEndTimeWrap ){
                    slotsToBeMarkedBooked slotToBeMarkedRec = new slotsToBeMarkedBooked();
                    //slotWrapRec.startTime_v1    -> actualstarttime
                    //startTimeSlot                -> fieldStartTime
                    //slotWrapRec.endTime_v1    -> actualEndTime
                    //EndTimeSlot                -> fieldEndTIme
                    if ( slotWrapRec.startTime_v1 >= startTimeSlot && slotWrapRec.startTime_v1 < EndTimeSlot ){
                        slotToBeMarkedRec.startTime = startTimeSlot;
                        slotToBeMarkedRec.endTime = EndTimeSlot;

                    }
                    else if ( slotWrapRec.startTime_v1 <= startTimeSlot && slotWrapRec.endTime_v1 <= EndTimeSlot && slotWrapRec.endTime_v1 > startTimeSlot ){
                        slotToBeMarkedRec.startTime = startTimeSlot;
                        slotToBeMarkedRec.endTime = EndTimeSlot;
                    }
                    else if ( slotWrapRec.startTime_v1 < startTimeSlot && slotWrapRec.endTime_v1 > EndTimeSlot ){
                        slotToBeMarkedRec.startTime = startTimeSlot;
                        slotToBeMarkedRec.endTime = EndTimeSlot;
                    }
                    if ( slotToBeMarkedRec.startTime != null && slotToBeMarkedRec.endTime != null )
                        slotToBeBookedList.add(slotToBeMarkedRec);
                }
            }
            system.debug('slotToBeBookedList-->' + slotToBeBookedList);
            Map<DateTime, DateTime> endTimeByStartTimeMap = new Map<DateTime, DateTime>();
            if ( !slotToBeBookedList.isEmpty() ){
                for ( slotsToBeMarkedBooked slotRec : slotToBeBookedList ){
                    endTimeByStartTimeMap.put(slotRec.startTime, slotRec.endTime);
                }
                if ( !endTimeByStartTimeMap.isEmpty() ){
                    for ( integer i = 0; i < iterationLength; i++ ){

                        DateTime startTimeSlot = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day(), 15, 10 * ( i + 3 ), 0);
                        DateTime EndTimeSlot = DateTime.newInstance(StartTime.year(), StartTime.month(), StartTime.day(), 15, 10 * ( i + 4 ), 0);


                        ActualSlotAvailablity actualSlotBookedRec = new ActualSlotAvailablity();
                        if ( endTimeByStartTimeMap.containsKey(startTimeSlot) && endTimeByStartTimeMap.get(startTimeSlot) == EndTimeSlot ){
                            actualSlotBookedRec.SlotBookedOrNot = 'Booked';
                            actualSlotBookedRec.SlotStartTime = startTimeSlot;
                            actualSlotBookedRec.SlotEndTime = EndTimeSlot;
                        }
                        else{
                            actualSlotBookedRec.SlotBookedOrNot = 'Available';
                            actualSlotBookedRec.SlotStartTime = startTimeSlot;
                            actualSlotBookedRec.SlotEndTime = EndTimeSlot;

                        }

                        SlotwrapList.add(actualSlotBookedRec);
                    }
                }
            }
        }
        system.debug('SlotwrapList-->' + SlotwrapList);
        return SlotwrapList;
    }

    public class CreatedEventRecWithUserInfo{
        @AuraEnabled
        public user UserInfodetails{ get; set; }

        @AuraEnabled
        public Event EventRecDetail{ get; set; }

        @AuraEnabled
        public Lead leadDetail{ get; set; }

    }

    public class AllBookedAndUnbookedSlots{
        @AuraEnabled
        public String SlotBookedOrNot{ get; set; }

        @AuraEnabled
        public datetime SlotStartTime{ get; set; }

        @AuraEnabled
        public datetime SlotEndTime{ get; set; }

    }

    public class MeetingDetailsWrap{
        @AuraEnabled
        public list<String> AttendeeEmailList{ get; set; }

        @AuraEnabled
        public list<String> AttendeeNameList{ get; set; }

        @AuraEnabled
        public Long CallDuration{ get; set; }

        @AuraEnabled
        public String AttendeesMapwithDuration{ get; set; }

        @AuraEnabled
        public Datetime ActualStartDateTime{ get; set; }

        @AuraEnabled
        public Datetime ActualEndDateTime{ get; set; }

    }

    public class bookedSlotsWrapper{
        public DateTime startTime_v1{ get; set; }

        @AuraEnabled
        public DateTime endTime_v1{ get; set; }

    }

    public class slotsToBeMarkedBooked{
        @AuraEnabled
        public DateTime startTime{ get; set; }

        @AuraEnabled
        public DateTime endTime{ get; set; }

    }

    public class ActualSlotAvailablity{
        @AuraEnabled
        public String SlotBookedOrNot{ get; set; }

        @AuraEnabled
        public datetime SlotStartTime{ get; set; }

        @AuraEnabled
        public datetime SlotEndTime{ get; set; }

    }

}