global class ScheduleBatchToTransferLead implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToTransferLeadFromDeactivatedUser batchInstance = new BatchToTransferLeadFromDeactivatedUser();
        Database.executeBatch(batchInstance);
    }
}