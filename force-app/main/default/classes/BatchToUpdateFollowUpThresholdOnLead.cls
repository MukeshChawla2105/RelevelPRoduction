public class BatchToUpdateFollowUpThresholdOnLead implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<Remarketing_Config__c> customSettingForRmTeam = Remarketing_Config__c.getall().values();
        date todayDate = DAte.today();
        date overdueDate = todayDate.addDays(-integer.valueOf(customSettingForRmTeam[0].Lead_Overdue_Day__c));        
        String query = 'SELECT Activity_Date_Time__c,Follow_Up_Activity_Datetime__c,Id,OwnerId,Overdue__c,CreatedDate,WhoId,Overdue_Date_Time__c FROM Task WHERE Overdue_Date_Time__c != null AND Status = \'Overdue\' AND Overdue_Date_Time__c <= :'+overdueDate;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        List<Lead> leadListToBeUpdated = new List<Lead>();
        Map<String,Task> taskByLeadID = new Map<String, Task>();

        if(!taskList.isEmpty()){
            for(Task taskRec: taskList){
                if(taskByLeadID.containsKey(taskRec.whoId)){
                    DateTime overDueDAteTime = taskByLeadID.get(taskRec.whoId).Overdue_Date_Time__c;
                    if(overDueDAteTime < taskRec.Overdue_Date_Time__c){
                        taskByLeadID.put(taskRec.whoId, taskRec);
                    }
                }else{
                    taskByLeadID.put(taskRec.whoId, taskRec);
                }
            }
            if(!taskByLeadID.isEmpty()){
                for(String leadId : taskByLeadID.keySet()){
                    Lead leadTOUpdate = new Lead();
                    leadTOUpdate.Id = leadId;
                    leadTOUpdate.Followup_Threshold_Overdue__c	= true;
                    leadListToBeUpdated.add(leadTOUpdate);
                }
                if(!leadListToBeUpdated.isEmpty()){
                    update leadListToBeUpdated;
                }
              
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }
}