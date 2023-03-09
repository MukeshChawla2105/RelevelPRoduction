public class BatchForCallUpdates implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Lead WHERE Offer_Status__c = \'Yes\' AND Admission_Letter_Send_Date_Time__c >= 2022-09-29T00:00:04.000+0000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        List<Task> taskList = new List<Task>();
        List<Task> taskListToBeUpdated = new List<Task>();
        system.debug('leadList-->'+leadList);
        if(!leadList.isEmpty()){
            for(Lead LeadRec : leadList){
                system.debug('LeadRec-->'+LeadRec);
                taskList = [SELECT Id,Updated_by_Scheduler__c FROM Task WHERE wk_exo__call_sid__c != null AND Updated_by_Scheduler__c= false AND WhoId =: LeadRec.Id];
            }
            system.debug('taskList-->'+taskList);
            if(!taskList.isEmpty()){
                for(Task taskRec : taskList){
                    Task TaskRecToUpdate= new Task();
                    TaskRecToUpdate.Id = taskRec.Id;
                    TaskRecToUpdate.Updated_by_Scheduler__c = true;
                    update TaskRecToUpdate;
                }
             
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }  
}