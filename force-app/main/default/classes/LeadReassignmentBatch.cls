public class LeadReassignmentBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(test.isRunningTest()){
           return Database.getQueryLocator([SELECT Id,OwnerId,Goal_Interested_In__c,Source_Intent__c,LeadSource,Learner_Uid__c,Company,FirstName,LastName,Email,Age__c,Birth_Year__c,Phone ,Experience__c,Country,State From Lead Where Lead_status__c = 'Not Contact' ]); 
        }else{
         return Database.getQueryLocator([SELECT Id,OwnerId,Goal_Interested_In__c,Source_Intent__c,LeadSource,Learner_Uid__c,Company,FirstName,LastName,Email,Age__c,Birth_Year__c,Phone ,Experience__c,Country,State From Lead Where Leads_Age__c >= 15 AND Lead_status__c = 'Not Contact' ]);   
        }
        
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadsToBeReassigned){
        string goalIntrestedIn = '';
        Map<String, string> leadOwnerIdByLeadId = new Map<String, String>();
        List<Lead> clonnedLeadsToBeInserted = new List<Lead>();
        List<Lead> clonnedLeadsToBeUpdated = new List<Lead>();
        List<Id> leadsToBeDeleted = new List<Id>();
        List<Id> clonnedLeadsIdToBeUpdated = new List<Id>();
        list<task> leadTaskTobeDelete = new list<task>();
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'].Id;
        system.debug('leadsToBeReassigned::'+leadsToBeReassigned);
        if(!leadsToBeReassigned.isEmpty()){
            for(Lead leadRec : leadsToBeReassigned){
                goalIntrestedIn = leadRec.Goal_Interested_In__c;
                leadOwnerIdByLeadId.put(leadRec.Id, leadRec.OwnerId);
                lead clonnedLead = new lead();
                clonnedLead = leadRec.clone();
                clonnedLead.Learner_Uid__c = leadRec.Learner_Uid__c+'UID'+leadRec.OwnerId;
                clonnedLead.OwnerId = queueId;
                clonnedLeadsToBeInserted.add(clonnedLead);
                leadsToBeDeleted.add(leadRec.Id);
            }
            
            leadTaskTobeDelete = [select id from task where whoid in: leadsToBeDeleted];
            system.debug('leadOwnerIdByLeadId::'+leadOwnerIdByLeadId);
            system.debug('clonnedLeadsToBeInserted::'+clonnedLeadsToBeInserted);
            system.debug('leadsToBeDeleted::'+leadsToBeDeleted);
            
            Database.SaveResult[] srList = Database.insert(clonnedLeadsToBeInserted, false);
            system.debug('srList::'+srList);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    clonnedLeadsIdToBeUpdated.add(sr.getId());
                }
            }
            system.debug('clonnedLeadsIdToBeUpdated::'+clonnedLeadsIdToBeUpdated);
            if(!clonnedLeadsIdToBeUpdated.isEmpty()){
                RoundRobinLeadAssignment.assignLeadsToBDS(goalIntrestedIn);
                database.delete(leadsToBeDeleted);
                database.delete(leadTaskTobeDelete);
                clonnedLeadsToBeUpdated = [Select Id,Learner_Uid__c From Lead Where Id In: clonnedLeadsIdToBeUpdated];
                system.debug('clonnedLeadsToBeUpdated::'+clonnedLeadsToBeUpdated);
                if(!clonnedLeadsToBeUpdated.isEmpty()){
                    for(Lead updateLearnerUID : clonnedLeadsToBeUpdated){
                        system.debug('updateLearnerUID::'+updateLearnerUID);
                        integer index = updateLearnerUID.Learner_Uid__c.indexOf('UID');
                        system.debug('index::'+index);
                        updateLearnerUID.Learner_Uid__c = updateLearnerUID.Learner_Uid__c.substring(0, index);
                        system.debug('updateLearnerUID.Learner_Uid__c::'+updateLearnerUID.Learner_Uid__c);
                    }
                    system.debug('clonnedLeadsToBeUpdated::'+clonnedLeadsToBeUpdated);
                    Update clonnedLeadsToBeUpdated; 
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}