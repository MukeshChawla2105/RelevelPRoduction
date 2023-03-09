global without sharing class ScheduleBatchForFollowUpThreshold implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToUpdateFollowUpThresholdOnLead batchInstance = new BatchToUpdateFollowUpThresholdOnLead();
            Database.executeBatch(batchInstance);
        }
    }