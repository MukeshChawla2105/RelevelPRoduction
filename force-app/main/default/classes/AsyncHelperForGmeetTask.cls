public class AsyncHelperForGmeetTask  implements Queueable,Database.AllowsCallOuts{
    List<Event> eventList = New List<Event>();
    List<Event> eventListTobeUpdate = new List<Event>();
    integer startIndex;
    integer endIndex;
    public AsyncHelperForGmeetTask(List<Event> eventList,integer startIndex,integer endIndex){
        this.eventList = eventList;
        this.startIndex = startIndex;
        this.endIndex = endIndex;
    }
    public void execute(QueueableContext context){
        system.debug('eventList.size()-->'+eventList.size());
        for(integer i = startIndex;i< endIndex;i++){
            List<Object> attachmentList = new List<Object>();
            
            string meetingcode = '';
            
            if(eventList[i].meeting_Url_Charcter__c != null){
                meetingcode = (eventList[i].meeting_Url_Charcter__c).replace('-', '');
                
                String BDEmail = [Select Id, Owner_Email__c From Lead Where id=: eventList[i].whoId].Owner_Email__c;

                GMeetAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventdetails = GMeetAPIHandler.getEventDetail_V2(BDEmail, eventList[i].GMeet_Event_Id__c);
                //string ResponseString = GMeetAPIHandler.getEventDetail_V2(BDEmail, eventList[i].GMeet_Event_Id__c);
                string ResponseString = APIWrapforEventdetails.ResponseString;

                GMeetAPIHandler.APIWrapperForEventDetailsAndReports APIWrapforEventReport = GMeetAPIHandler.getEventReportDetail_V2(BDEmail, meetingcode);
                System.debug('APIWrapforEventReport =======> ' + APIWrapforEventReport);
                string ResponseStringForTimeCalculation = APIWrapforEventReport.ResponseString;

                if(APIWrapforEventdetails.ResponseString != null){
                    APILOGSCapture.captureLogs(APIWrapforEventdetails.EndPoint, 'Body Not required', APIWrapforEventdetails.StatusCode, APIWrapforEventdetails.ResponseString,null, eventList[i].id);
                }
                if(APIWrapforEventReport.ResponseString != null){
                    APILOGSCapture.captureLogs(APIWrapforEventReport.EndPoint, 'Body Not required', APIWrapforEventReport.StatusCode, APIWrapforEventReport.ResponseString,null, eventList[i].id);
                }
                //string ResponseStringForTimeCalculation = GMeetAPIHandler.getEventReportDetail_V2(BDEmail, meetingcode);
                GMeetHandler.MeetingDetailsWrap MeetWrapToUpdateEventDetails = GMeetHandler.CalculateMeetingTimes(ResponseStringForTimeCalculation, eventList[i].whoId);
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(ResponseString);
                List<Object> attendees = (List<Object>)m.get('attendees');
                if((List<Object>)m.get('attachments') != null){
                    attachmentList = (List<Object>)m.get('attachments');
                }
                else{
                    
                }
                
                Event updatedEventRec = new Event();
                updatedEventRec.id = eventList[i].id;
                updatedEventRec.Attendees__c = '';
                if (attendees != null ){
                    for (Object attObj : attendees){
                        Map<String, Object> attMap = (Map<String, Object>)attObj;
                        updatedEventRec.Attendees__c += attMap.get('email') + ' ,';
                    }
                    updatedEventRec.Attendees__c = updatedEventRec.Attendees__c.removeEnd(',');
                }         
                if(MeetWrapToUpdateEventDetails.AttendeeEmailList != null){
                    string emaillistString = String.join(MeetWrapToUpdateEventDetails.AttendeeEmailList,',');
                    //updatedEventRec.Actual_Attendees_Email_List__c = emaillistString;
                }
                if(MeetWrapToUpdateEventDetails.AttendeesMapwithDuration != null){
                    updatedEventRec.Description = 'Attendees List With Duration(in seconds) ' +'\n' +MeetWrapToUpdateEventDetails.AttendeesMapwithDuration;
                }
                if(MeetWrapToUpdateEventDetails.CallDuration != null){
                    updatedEventRec.Gmeet_call_Duration__c = MeetWrapToUpdateEventDetails.CallDuration;
                }
                if (!attachmentList.isEmpty()){
                    Map<String, Object> attachmentMap = (Map<String, Object>)attachmentList[0];
                    updatedEventRec.Recording_URL__c = attachmentMap.get('fileUrl').toString();
                    if(attachmentMap.get('fileUrl').toString() != Null){
                        updatedEventRec.Event_Status__c = 'Completed';
                    }
                } else{
                    updatedEventRec.Recording_URL__c = 'Recording Was not Initiated!';
                    updatedEventRec.Event_Status__c = 'Completed';
                }
                
                update updatedEventRec;
            }
        }
        startIndex = endIndex;
        endIndex = endIndex + 1;
        system.debug('eventListTobeUpdate-->'+eventListTobeUpdate);

        if(startIndex < eventList.size()){
            system.debug('Enqueue Job');
            System.enqueueJob(new AsyncHelperForGmeetTask(eventList,startIndex,endIndex));
        }
    }
   
}