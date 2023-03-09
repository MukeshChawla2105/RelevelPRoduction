global class ScheduleBatchforFollowUpPriorFifteen  implements Schedulable{
    // schedule for every 10 mins
global void execute(SchedulableContext sc) {
        BatchForFollowUpNotPriorFifteenMin batchInstance = new BatchForFollowUpNotPriorFifteenMin();
        Database.executeBatch(batchInstance);
    }
}