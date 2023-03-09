public class BatchToDeleteAllLeads implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = System.Label.Delete_Query;//system.l'Select Id From Lead';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        system.debug('leadList::'+leadList);
        database.delete(leadList);
    }
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}