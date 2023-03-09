public class EventTriggerHelper {
    
    public Static void UpdateLeadInterviewDetails(Map<Id, Event> newEventMap){
        
        system.debug('newEventMap :: ' + newEventMap);
        //Set<Id> LeadIds = new Set<Id>();
        Map<String, Event> GmeetEventMapEventByLeadId = new Map<String, Event>();
        List<Lead> leadRecordsToBeUpdated = new List<Lead>();
        List<Lead> UpdatedleadRecords = new List<Lead>();
        try{
            for (Event Event : newEventMap.values()){
                if(Event.GMeet_Event_Id__c != null){
                    //LeadIds.add(Event.WhoId);
                    if(Event.Event_Status__c == 'Open'){
                        GmeetEventMapEventByLeadId.put(Event.WhoId, Event);
                    }
                }
            }
            if(!GmeetEventMapEventByLeadId.isEmpty()){
                leadRecordsToBeUpdated = [Select Id, Interview_Scheduled_AC__c, Interview_Date_Time_AC__c, Interview_Schedule_Notes_AC__c
                                          From Lead
                                          Where Id in:GmeetEventMapEventByLeadId.Keyset()];
                
                if(!leadRecordsToBeUpdated.isEmpty()){
                    for(Lead ld : leadRecordsToBeUpdated){
                        ld.Interview_Scheduled_AC__c = 'Yes';
                        ld.Interview_Date_Time_AC__c = GmeetEventMapEventByLeadId.get(ld.id).StartDateTime;
                        ld.Interview_Scheduled_at_Date_Time__c = system.now();
                        ld.Interview_Status_AO__c = 'Scheduled';
                        UpdatedleadRecords.add(ld);
                    }
                    
                    if(!UpdatedleadRecords.isEmpty()){
                        update UpdatedleadRecords;
                    }
                    
                }
            }
        }
        catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
            
        }
    }
    
    public static void UpdateLeadRescheduleInterview(Map<Id, Event> newEventMap, Map<Id, Event> OldEventMap){
        try{
            Set<Id> LeadID = new Set<Id>();
            Map<String, Event> GmeetMapEventByLeadId = new Map<String, Event>();
            List<Lead> LeadListToBeUpdated = new List<Lead>();
            List<Lead> UpdatedLeadList = new List<Lead>();
            
            if(!newEventMap.isEmpty()){
                for(Event Event : newEventMap.values()){
                    if(Event.GMeet_Event_Id__c != null && Event.StartDateTime != OldEventMap.get(Event.id).StartDateTime && Event.EndDateTime != OldEventMap.get(Event.id).EndDateTime){
                        GmeetMapEventByLeadId.put(Event.whoId, Event);
                    }
                }
                
                if(!GmeetMapEventByLeadId.isEmpty()){
                    LeadListToBeUpdated = [Select Id, Interview_Scheduled_AC__c, Interview_Date_Time_AC__c, Interview_Schedule_Notes_AC__c, Interview_Rescheduled_AC__c
                                           From Lead
                                           Where Id in:GmeetMapEventByLeadId.Keyset()];
                    
                    if(!LeadListToBeUpdated.isEmpty()){
                        for(Lead ld : LeadListToBeUpdated){
                            ld.Interview_Rescheduled_AC__c = true;
                            ld.Interview_Rescheduled_Date_Time__c = GmeetMapEventByLeadId.get(ld.Id).StartDateTime;
                            ld.Interview_Date_Time_AC__c = GmeetMapEventByLeadId.get(ld.Id).StartDateTime;
                            ld.Interview_Status_AO__c = 'Rescheduled';
                            ld.Interview_Rescheduled_at_Date_Time__c = system.now();
                            UpdatedLeadList.add(ld);
                        }
                    }
                    if(!UpdatedLeadList.isEmpty()){
                        update UpdatedLeadList;
                    }
                }
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage() + 'at line number ::' + e.getLineNumber());
        }
    }
    
    public Static void UpdateLeadAfterFetchingRecordingDetails(Map<Id, Event> newEventMap, Map<Id, Event> OldEventMap){
        try{
            Set<Id> LeadID = new Set<Id>();
            Map<String, Event> GmeetMapEventByLeadId = new Map<String, Event>();
            List<Lead> LeadListToBeUpdated = new List<Lead>();
            List<Lead> UpdatedLeadList = new List<Lead>();
            
            if(!newEventMap.isEmpty()){
                for(Event Event : newEventMap.values()){
                    if(Event.Recording_URL__c != null && Event.Recording_URL__c != OldEventMap.get(Event.id).Recording_URL__c){
                        GmeetMapEventByLeadId.put(Event.whoId, Event);
                    }
                    
                }
                if(!GmeetMapEventByLeadId.isEmpty()){
                    LeadListToBeUpdated = [Select Id, Interview_Scheduled_AC__c, Interview_Date_Time_AC__c, Interview_Schedule_Notes_AC__c, Interview_Rescheduled_AC__c
                                           From Lead
                                           Where Id in:GmeetMapEventByLeadId.Keyset()];
                    if(!LeadListToBeUpdated.isEmpty()){
                        for(Lead ld : LeadListToBeUpdated){
                            ld.Interview_Conducted__c = true;
                            //ld.Event_Status__c = 'Completed';
                            UpdatedLeadList.add(ld);
                        }
                    }
                    if(!UpdatedLeadList.isEmpty()){
                        update UpdatedLeadList;
                    }
                }
                
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage() + 'at line number ::' + e.getLineNumber());
        }
    }
    
}