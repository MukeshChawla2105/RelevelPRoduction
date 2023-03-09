global without sharing class ScheduleBatchToAutoCheckOutAtNine implements Schedulable{
    global void execute(SchedulableContext SC) {
        BatchToAutoCheckOutAtNine batchInstance = new BatchToAutoCheckOutAtNine();
        database.executeBatch(batchInstance);
    }
}