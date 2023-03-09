public class BatchUpdateLeadFields implements Database.Batchable<sObject>{
public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'select id,wk_exo__call_start_time__c,WhoId,wk_exo__Total_Talk_Time__c,wk_exo__call_end_time__c from task where wk_exo__call_start_time__c != NULL';
    	
    return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext BC, List<task> taskList) {
        system.debug('taskList::'+taskList);
        system.debug('taskList::'+taskList.size());
        map<Id,Task> mapofTaskById = new map<Id,Task>();
        for(task ts : taskList){
            if(ts.wk_exo__call_start_time__c != null && ts.wk_exo__call_start_time__c != '')
            	mapofTaskById.put(ts.Id,ts);
        }
        if(!mapofTaskById.isEmpty())
        	BatchHandler.updateLeadRecord(mapofTaskById);
         
    }   
     
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}