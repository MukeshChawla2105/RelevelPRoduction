public class BatchToUpdateOverdueTask implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        dateTime todayDate = DateTime.now();
        String query = 'SELECT Activity_Date_Time__c,Follow_Up_Activity_Datetime__c,Id,OwnerId,Overdue__c,CreatedDate FROM Task WHERE Follow_Up_Activity_Datetime__c != null AND Status != \'Completed\' AND Follow_Up_Activity_Datetime__c <: todayDate';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        List<Task> taskListToBeUpdated = new List<Task>();
        dateTime todayDate = DateTime.now();
        todayDate = todayDate.addMonths(-1);
        system.debug('taskList>>'+taskList);
        
        if(!taskList.isEmpty()){
            for(Task taskRec : taskList){
                Task taskToBeUpdated = new Task();
                taskToBeUpdated.Id = taskRec.Id;
                if(taskRec.Follow_Up_Activity_Datetime__c < todayDate)
                {
                    taskToBeUpdated.Status = 'Completed';
                }else{
                    taskToBeUpdated.Status = 'Overdue';
                }
                taskToBeUpdated.Overdue__c = true;
                taskListToBeUpdated.add(taskToBeUpdated);
            }
            if(!taskListToBeUpdated.isEmpty()){
                update taskListToBeUpdated;
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }    
}