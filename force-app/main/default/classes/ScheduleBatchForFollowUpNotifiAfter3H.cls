global class ScheduleBatchForFollowUpNotifiAfter3H implements Schedulable{
global void execute(SchedulableContext sc) {
        BatchForFollowUpNotificationAfter3H batchInstance = new BatchForFollowUpNotificationAfter3H();
        Database.executeBatch(batchInstance);
    }
}