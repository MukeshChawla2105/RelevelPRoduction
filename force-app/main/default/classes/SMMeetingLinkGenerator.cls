public with sharing class SMMeetingLinkGenerator{
    
    Public Static String MeetingUrlGenerator(String UserId,User_Tracking__c userTrackRec){
        AO_Availability__c AO_avail = new AO_Availability__c();
        String message = '';
        try{
            User u = [SELECT Email,FirstName,Id,LastName,MobilePhone,Name,Username,UserRoleId 
                      FROM User 
                      where Id =: UserId];
            datetime presentTime = System.now();
            string Title = 'Title Sample';
            Date TodayDate = System.today();
            Datetime StartTimeoftheDay = Datetime.newInstance(presentTime.year(), presentTime.month(), presentTime.day(), presentTime.hour(), presentTime.minute(), presentTime.second());
            Datetime EndTimeoftheDate = Datetime.newInstance(presentTime.year(), presentTime.month(), presentTime.day(), presentTime.hour(), presentTime.minute() + 30, 00);
            
            List<AO_Availability__c> AOAvailableTobeUpdated = [Select Id, Audited_Officer__c,Checkin_DateTime__c, Meeting_Url__c, Status__c
                                                               From AO_Availability__c
                                                               Where Audited_Officer__c =: UserId AND CreatedDate = TODAY];
            
            
            List<Audit_Officer__c> AuditOfficer = [SELECT AO__c,Id,IsActive__c,Name FROM Audit_Officer__c 
                                                   Where AO__c =: userId];
            
            SMMeetingLinkGeneratorAPIHandler.APIWrapper APILogWrap = SMMeetingLinkGeneratorAPIHandler.GeneratorMetingForSM(JSON.serialize(StartTimeoftheDay), JSON.serialize(EndTimeoftheDate), JSON.serialize(Title), u.Email);
            
            Map<String, String> responseMap = APILogWrap.ResponseMap;
            message = 'API Error, Please Try Again!';
            if ( responseMap.get('event_url') != null && responseMap.get('event_id') != null ){
                if (userTrackRec.Member__c != null  && !String.isBlank(userTrackRec.Member__c)) {
                    insert userTrackRec;
                    if (userTrackRec.id != null) {
                        message = 'User Track Record Created Successfully';
                    }
                }
                AO_avail.Audited_Officer__c = UserId;
                AO_avail.Checkin_DateTime__c = presentTime;
                AO_avail.Meeting_Url__c = responseMap.get('event_url');
                AO_avail.Meeting_Unique_Id__c = responseMap.get('event_id');
                AO_avail.Status__c = 'Available';
                //AO_avail.User_Tracking__c = userTrackRec.Id;
                AO_avail.Last_Engagement_Time__c = system.now();
                
                if (!AOAvailableTobeUpdated.isEmpty() ) {
                    AO_avail.Id = AOAvailableTobeUpdated[0].id;
                    
                    update AO_avail;
                }
                else {
                    if (!AuditOfficer.isEmpty()) {
                        AO_avail.Audit_Officer__c = AuditOfficer[0].Id;
                    }
                    insert AO_avail;
                }   
            }
        }
        catch(Exception e) {
            System.debug('This Error has occured due to ======> ' + e.getMessage() + ' at line Number ====>  ' + e.getLineNumber());
        }
        return message;
    }
    
    public static String UpdateAOActivitiesLog(AO_Activity__c AOAct){
        String respMsg = '';
        system.debug('AOAct-->' + AOAct);
        try {
            List<Object> attachmentList = new List<Object>();
            string meetingcode = ( AOAct.meeting_Url_Charcter__c ).replace('-', '');
            
            String AOEmail = [SELECT Email,FirstName,Id,IsActive,LastName,Name 
                              FROM User
                              Where id = : AOAct.AO_Availability__r.Audit_Officer__r.AO__c].Email;
            
            SMMeetingLinkGeneratorAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventdetails = SMMeetingLinkGeneratorAPIHandler.getEventDetail_V2(AOEmail, AOAct.Meeting_Unique_Id__c);
            string ResponseString = APIWrapforEventdetails.ResponseString;
            
            SMMeetingLinkGeneratorAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventReport = SMMeetingLinkGeneratorAPIHandler.getEventReportDetail_V2(AOEmail, meetingcode);
            
            
            string ResponseStringForTimeCalculation = APIWrapforEventReport.ResponseString;
            GMeetHandler.MeetingDetailsWrap MeetWrapToUpdateEventDetails = GMeetHandler.CalculateMeetingTimes(ResponseStringForTimeCalculation, AOAct.Lead__c);
            AO_Activity__c UpdatedAOAct = new AO_Activity__c();
            UpdatedAOAct.id = AOAct.id;
            UpdatedAOAct.Attendees__c = '';
            Map<String, Object> m = ( Map<String, Object> )JSON.deserializeUntyped(ResponseString);
            
            if ( ( List<Object> )m.get('attachments') != null ){
                attachmentList = ( List<Object> )m.get('attachments');
            }
            else{
            }
            if ( MeetWrapToUpdateEventDetails.AttendeeEmailList != null || MeetWrapToUpdateEventDetails.AttendeesMapwithDuration != null || MeetWrapToUpdateEventDetails.CallDuration != null ){
                if ( MeetWrapToUpdateEventDetails.AttendeeEmailList != null ){
                    string emaillistString = String.join(MeetWrapToUpdateEventDetails.AttendeeEmailList, ',');
                }
                if ( MeetWrapToUpdateEventDetails.AttendeesMapwithDuration != null ){
                    UpdatedAOAct.Description__c = 'Attendees List With Duration(in seconds) ' + '\n' + MeetWrapToUpdateEventDetails.AttendeesMapwithDuration;
                    UpdatedAOAct.Event_Status__c = 'Completed';
                }
                if ( MeetWrapToUpdateEventDetails.CallDuration != null ){
                    UpdatedAOAct.Gmeet_call_Duration__c = MeetWrapToUpdateEventDetails.CallDuration;
                }
                UpdatedAOAct.Event_Actual_Start_Time__c = MeetWrapToUpdateEventDetails.ActualStartDateTime;
                UpdatedAOAct.Event_Actual_End_Time__c = MeetWrapToUpdateEventDetails.ActualEndDateTime;
            }
            else{
                respMsg += 'Events Details processing is in Progress!' + ' ';
            }
            integer i = 0;
            UpdatedAOAct.Recording_URL__c = '';
            if ( !attachmentList.isEmpty() ){
                if(attachmentList.size() > 1){
                    for ( Object attachObj : attachmentList ){
                        i++;
                        Map<String, Object> attachmentMap = ( Map<String, Object> )attachObj;
                        UpdatedAOAct.Recording_URL__c +=  i + '. ' + attachmentMap.get('fileUrl').toString() +  '\n';
                    }
                    
                }
                else{
                    Map<String, Object> attachmentMap = ( Map<String, Object> )attachmentList[0];
                    UpdatedAOAct.Recording_URL__c +=  attachmentMap.get('fileUrl').toString();
                    
                }
                UpdatedAOAct.Is_Gmeet_Recording_Available__c = true;
                respMsg = respMsg.contains('Attendees') ? respMsg.removeEnd(',') + ' not found' : 'Success';
            }
            else{
                if ( respMsg.contains('Events Details processing is in Progress') ){
                    respMsg += 'Recording Processing is also In progress!';
                    UpdatedAOAct.Recording_URL__c = 'Recording Url Processing is in Progress!';
                }
                else{
                    UpdatedAOAct.Recording_URL__c = 'Recording Was not Initiated!';
                    respMsg = 'Recording link not found';
                }
            }
            update UpdatedAOAct;
            return respMsg;
            
        } catch (Exception e) {
            System.debug('Exception----' + e.getMessage());
            system.debug('error-->' + e.getLineNumber());
            return e.getMessage();
            
        }
    }
}