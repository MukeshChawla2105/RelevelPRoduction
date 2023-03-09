global class SchedulleBatchForNewLeadNoActivity implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchForNewLeadsWithnoActivity batchInstance = new BatchForNewLeadsWithnoActivity();
        Database.executeBatch(batchInstance);
    }
}