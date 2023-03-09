public with sharing class BatchToTransferLeadToQueue implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                          limit 1].Id;
        String QueryString = 'SELECT AO_Interview_Status_Manual__c,Email,Id,Interview_Id__c,isActive__c,Is_Interview_Conducted__c,LastName,Lead_Version__c,Name,Offer_Status__c,OwnerId,Phone_formatted__c FROM Lead Where AO_Interview_Status_Manual__c != Null And Lead_Version__c = \'V1\' and OwnerId !=: queueId';
        return Database.getQueryLocator(QueryString);
        
    }

    public void execute(Database.BatchableContext bc, List<Lead> LeadList){
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                          limit 1].Id;
         string noShowQueueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'NO Show Queue'
                          limit 1].Id;
        System.debug('queueId =====> ' + queueId);
        List<Lead> UpdatedLeadList = new List<Lead>();
        if (!LeadList.isEmpty()) {
            for (Lead Ld : LeadList) {
                if (ld.Lead_Version__c == 'V1' && ld.AO_Interview_Status_Manual__c != null && (ld.AO_Interview_Status_Manual__c == 'Learner No-Show' || ld.AO_Interview_Status_Manual__c =='AO No-Show') && ld.OwnerId != queueId) {
                    ld.OwnerId = noShowQueueId;
                    ld.Lead_Stage__c = 'Unassigned';
                    UpdatedLeadList.add(ld);
                }  
            }
        }
        if (!UpdatedLeadList.isEmpty()) {
            update UpdatedLeadList;
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