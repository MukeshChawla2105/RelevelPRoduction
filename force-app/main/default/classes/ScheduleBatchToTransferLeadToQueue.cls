global with sharing class ScheduleBatchToTransferLeadToQueue implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        BatchToTransferLeadToQueue b = new BatchToTransferLeadToQueue(); 
        Database.executeBatch(b);
     }
}