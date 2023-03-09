global class ScheduleBatchToEvaluateCallCount implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToEvaluateCallCount batchInstance = new BatchToEvaluateCallCount();
        Database.executeBatch(batchInstance);
    }
}