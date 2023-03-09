public class AOActivitiesTriggerHandler {
    
    public static void CreateEvent_AOActivities(Map<Id, AO_Activity__c> AoActNewMap, List<AO_Activity__c> AoActNewList){
        List<Event> EventListToBeInserted = new List<Event>();
        Set<Id> aoActId = new Set<Id>();
        for(AO_Activity__c aoAct : AoActNewList){
            aoActId.add(aoAct.Id);
        }
        
        List<AO_Activity__c> detailedActList = [select id,Lead__r.name,AO_Member__r.Name,Meeting_Unique_Id__c,AO_Availability__c,
                                                Meeting_Url__c,StartTime__c,End_DateTime__c,Interview__c,Lead__c from AO_Activity__c where id in: aoActId];
        
        
        try {
            if (!detailedActList.isEmpty()) {
                for (AO_Activity__c AOAct : detailedActList) {
                    Event createEvent = new Event();
                    createEvent.Subject = 'Google Meet with ' + AOAct.Lead__r.name +' By ' + AOAct.AO_Member__r.Name;
                    createEvent.GMeet_Event_Id__c = AOAct.Meeting_Unique_Id__c;
                    //createEvent.AO_Member__c = AOAct.AO_Member__c;
                    createEvent.AO_Availability__c = AOAct.AO_Availability__c;
                    createEvent.Meeting_URL__c = AOAct.Meeting_Url__c;
                    createEvent.StartDateTime = AOAct.StartTime__c;
                    createEvent.EndDateTime = AOAct.End_DateTime__c;
                    createEvent.Interview__c = AOAct.Interview__c;
                    createEvent.WhoId = AOAct.Lead__c;
                    EventListToBeInserted.add(createEvent);
                }
                if (!EventListToBeInserted.isEmpty()) {
                    insert EventListToBeInserted;
                }
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to ==== > ' + e.getStackTraceString());            
        }
    }
    
    public static void UpdateEvent_AOactivities(Map<Id, AO_Activity__c> AoActNewMap, Map<Id, AO_Activity__c> AoActOldMap){
        
        try {
            Set<Id> LeadIds = new Set<Id>();
            List<Event> EventListToBeUpdated = new List<Event>();
            List<Event> UpdatedEventList = new List<Event>();
            List<Lead> leadListToUpdate = new List<Lead>();
            Map<Id, AO_Activity__c> MapofLeadIdWithAOact = new Map<Id, AO_Activity__c>();
            
            if (!AoActNewMap.isEmpty()) {
                for (AO_Activity__c AO_Update : AoActNewMap.values()) {
                    if (AO_Update.Event_Status__c != null && AO_Update.Event_Status__c == 'Completed' && AO_Update.Description__c != null) {
                        LeadIds.add(AO_Update.Lead__c);
                        MapofLeadIdWithAOact.put(AO_Update.Lead__c, AO_Update);
                    }
                }
                if (!MapofLeadIdWithAOact.isEmpty()) {
                    EventListToBeUpdated = [SELECT AccountId,Actual_Attendees_Email_List__c,AO_Availability__c,Attendees_Except_BDE__c,Attendees_list__c,Attendees__c,Description,EndDateTime,Event_Actual_End_Time__c,Event_Actual_Start_Time__c,Event_Description__c,Event_Status__c,Gmeet_call_Duration__c,GMeet_Event_Id__c,Interview__c,IsGmeetRecordingAvailable__c,meeting_Url_Charcter__c,Meeting_URL__c,WhoId 
                                            FROM Event
                                            Where whoId IN: LeadIds];
                    if (!EventListToBeUpdated.isEmpty()) {
                        for (Event EventTobeupdated : EventListToBeUpdated) {
                            if (MapofLeadIdWithAOact.containsKey(EventTobeupdated.whoId)) {
                                Event updatedEvent = new Event();
                                updatedEvent.id = EventTobeupdated.id;
                                updatedEvent.Recording_URL__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Recording_URL__c;
                                updatedEvent.Event_Actual_Start_Time__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Event_Actual_Start_Time__c;
                                updatedEvent.Event_Actual_End_Time__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Event_Actual_End_Time__c;
                                updatedEvent.Description = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Description__c;
                                updatedEvent.Event_Status__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Event_Status__c;
                                updatedEvent.Gmeet_call_Duration__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Gmeet_call_Duration__c;
                                updatedEvent.IsGmeetRecordingAvailable__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Is_Gmeet_Recording_Available__c;
                                Lead leadRec = new Lead();
                                leadRec.Id = EventTobeupdated.whoId;
                                leadRec.Actual_Start_Time__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Event_Actual_Start_Time__c;
                                leadRec.Actual_End_Time__c = MapofLeadIdWithAOact.get(EventTobeupdated.whoId).Event_Actual_End_Time__c;
                                leadListToUpdate.add(leadRec);
                                UpdatedEventList.add(updatedEvent);
                            }
                        }
                    }
                }
                if (!UpdatedEventList.isEmpty()) {
                    update UpdatedEventList;
                }
                if(!leadListToUpdate.isEmpty()){
                    update leadListToUpdate;
                }
            }
            
        } catch (Exception e) {
            
        }
        
    }
    
}