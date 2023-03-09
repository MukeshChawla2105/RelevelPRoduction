global with sharing class ScheduleBatchToUpdateAllAOActivities implements Schedulable{

    global void execute(SchedulableContext sc) {
        BatchToUpdateAllAOActivities b = new BatchToUpdateAllAOActivities(); 
        Database.executeBatch(b, 1);
     }
    
}