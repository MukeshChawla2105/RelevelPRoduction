global class ScheduleBatchToAssignNOOfferLetterLead implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToAssignNOOfferLeeterLead batchInstance = new BatchToAssignNOOfferLeeterLead();
        Database.executeBatch(batchInstance);
    }
}