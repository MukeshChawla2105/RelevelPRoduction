public class BatchForNewLeadsWithnoActivity implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,Lead_Assigned_Date__c,FirstName,LastName,OwnerId,(Select Id From tasks where Stage_Changed__c = FALSE) FROM Lead WHERE Lead_Assigned_Date__c = Today AND Lead_Stage__c = \'New\' and owner_email__c != null  ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        system.debug('leadList>>'+leadList);
        Set<string> ownersToBeNotified = new Set<string>();
        Map<Id,Lead> leadByIdMap = new Map<Id, Lead>();
        
        if(!leadList.isEmpty()){
            for(Lead leadRec : leadList){
                system.debug('leadRec>>'+leadRec);
                integer taskListSize = leadRec.Tasks.size();
                system.debug('taskListSize>>'+taskListSize);
                if(taskListSize == 0 || taskListSize == null){
                    system.debug('taskListSize>>'+taskListSize);
                    ownersToBeNotified.add(leadRec.OwnerId);
                    leadByIdMap.put(leadRec.Id, leadRec);
                }
            }
            if(!ownersToBeNotified.isEmpty()){
                CustomNotification.notifyUsers(ownersToBeNotified, leadByIdMap, 'No Action on Todays Lead', 'There are leads in your bucket on which you havenot taken any Actions');
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }  
}