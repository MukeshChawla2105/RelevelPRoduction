global class ScheduleBatchIdleTimeReport implements Schedulable{
global void execute(SchedulableContext sc) {
        BatchIdleTimeReport batchInstance = new BatchIdleTimeReport();
        Database.executeBatch(batchInstance , 5);
    }
}