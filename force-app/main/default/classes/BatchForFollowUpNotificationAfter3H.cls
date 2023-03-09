public class BatchForFollowUpNotificationAfter3H implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime currentTime = System.now();
        
        String query = 'SELECT Activity_Date_Time__c,Follow_Up_Activity_Datetime__c,Id,OwnerId,WhoId FROM Task WHERE Follow_Up_Activity_Datetime__c = Today AND Follow_Up_Activity_Datetime__c != null AND Follow_Up_Activity_Datetime__c <: currentTime';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        system.debug('taskList>>'+taskList.size());
        set<string> ownerId = new Set<string>();
        set<Id> leadId = new Set<Id>();
        Map<Id,Lead> leadByIdMap = new Map<Id, Lead>();
        
        if(!taskList.isEmpty()){
            for(Task taskRec : taskList){
                if(taskRec.Follow_Up_Activity_Datetime__c != null){
                    long  diff = DateTime.now().getTime() - taskrec.Follow_Up_Activity_Datetime__c.getTime();
                    diff = diff/60000;
                    if(diff < 210 && diff >150 ){
                        ownerId.add(taskRec.OwnerId);
                        leadId.add(taskRec.WhoId);
                    }
                }
            }
        }
        system.debug('leadId>>'+leadId);
        system.debug('ownerId>>'+ownerId);
        
        if(!leadId.isEmpty())
            leadByIdMap = new Map<Id,Lead>([Select Id, Name,Learner_UID__c From Lead Where Id in: leadId]);
        if(!ownerId.isEmpty() && !leadByIdMap.isEmpty()){
            CustomNotification.notifyUsers(ownerId,leadByIdMap,'Notification For Pending Followup Task','You have a pending Follow up Task Overdue 3 hours Ago');
        }
    }
    public void finish(Database.BatchableContext BC) {
    }    
}