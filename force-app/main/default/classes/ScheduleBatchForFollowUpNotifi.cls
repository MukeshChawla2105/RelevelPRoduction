global class ScheduleBatchForFollowUpNotifi implements Schedulable{
global void execute(SchedulableContext sc) {
        BatchForFollowUpNotification batchInstance = new BatchForFollowUpNotification();
        Database.executeBatch(batchInstance);
    }
}