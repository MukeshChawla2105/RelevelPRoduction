global class ScheduleBatchForAOTrackReport  implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchForAOTrackReport batchInstance = new BatchForAOTrackReport();
        Database.executeBatch(batchInstance);
    }
}