public with sharing class BatchToUpdateAllAOActivities implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //datetime dt = system.today();
        datetime ct = system.now();
        datetime QueryStartTime = Datetime.newInstance(ct.year(), ct.month(), ct.day(), 5, 31, 0);        
       	datetime QueryEndTime = Datetime.newInstance(ct.year(), ct.month(), ct.day(), ct.hour()+5, ct.minute()+10, 0);
        //String newQueryString = 'SELECT AO_Availability__c,Attendees__c,Description__c,End_DateTime__c,Event_Actual_End_Time__c,Event_Actual_Start_Time__c,Event_Status__c,Gmeet_call_Duration__c,Id,Is_Gmeet_Recording_Available__c,Meeting_Unique_Id__c,Meeting_Url__c,Recording_URL__c FROM AO_Activity__c where Event_Status__c != \'Completed\' AND StartTime__c >=: QueryStartTime And End_DateTime__c <=: QueryEndTime';
        String newQueryString = 'SELECT AO_Availability__c,Attendees__c,Description__c,End_DateTime__c,Event_Actual_End_Time__c,Event_Actual_Start_Time__c,Event_Status__c,Gmeet_call_Duration__c,Id,Is_Gmeet_Recording_Available__c,Meeting_Unique_Id__c,Meeting_Url__c,Recording_URL__c, Meeting_Url_Charcter__c,AO_Availability__r.Audit_Officer__r.AO__c FROM AO_Activity__c where Event_Status__c != \'Completed\' AND StartTime__c >=: QueryStartTime And End_DateTime__c <=: QueryEndTime';
        return Database.getQueryLocator(newQueryString);
        
    }

    public void execute(Database.BatchableContext bc, List<AO_Activity__c> AOActivitiesRecords){
        System.debug('AOActivitiesRecords =====> ' + AOActivitiesRecords);
        if(!AOActivitiesRecords.isEmpty()){
            for(AO_Activity__c AO_Act :AOActivitiesRecords){
                if(AO_Act.Description__c == null && AO_Act.Meeting_Unique_Id__c  != null && (AO_Act.Event_Status__c == null || AO_Act.Event_Status__c != 'Completed')){
                    SMMeetingLinkGenerator.UpdateAOActivitiesLog(AO_Act);
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