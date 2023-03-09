public class BatchToUpdateLeadPhone implements Database.Batchable<sObject>{
public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = String.valueOf(system.Label.QueryToUpdatePhone);
    	
    return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        system.debug('leadList::'+leadList);
        for(Lead ld : leadList){
            if(ld.phone != null){
                ld.phone = '0'+ld.phone.right(10);
            }
        }
        update leadList;
    }   
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}