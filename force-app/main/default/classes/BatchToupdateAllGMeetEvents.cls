public with sharing class BatchToupdateAllGMeetEvents implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String newQueryString = 'SELECT Id, Description, Event_Description__c, GMeet_Event_Id__c, Attendees__c, Recording_URL__c, whoId, meeting_Url_Charcter__c,EndDateTime, StartDateTime   FROM Event where Type = \'Google Meet\' and Event_Status__c != \'Completed\'';
        return Database.getQueryLocator(newQueryString);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Event> GoogleMeetEventRecords){
        
        if(!GoogleMeetEventRecords.isEmpty()){
            for(Event evt :GoogleMeetEventRecords){
                if(evt.Description == null && evt.GMeet_Event_Id__c  != null){
                    GMeetHandler.GetAndUpdateEventDetails(evt);
                }
                
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
    }
}