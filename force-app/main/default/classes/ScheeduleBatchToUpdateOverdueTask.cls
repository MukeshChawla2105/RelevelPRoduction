global class ScheeduleBatchToUpdateOverdueTask implements Schedulable{
global void execute(SchedulableContext sc) {
        BatchToUpdateOverdueTask batchInstance = new BatchToUpdateOverdueTask();
        Database.executeBatch(batchInstance);
    }
}