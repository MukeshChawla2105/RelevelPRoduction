public class BatchToUpdateFirstConnected implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'Select id, First_Connected_Date_Time__c,CreatedDate,FRT_Based_on_Created_Date_Connected__c,(Select id,CreatedDate  from tasks Where (wk_exo__call_sid__c  != null OR wk_exo__call_start_time__c != null OR wk_exo__call_end_time__c != null) AND Exotel_call_Duration_min_Sec__c > 0 order by CreatedDate Asc LIMIT 1) From Lead Where FRT_Connected_Updated__c = false AND(Lead_Stage__C = \'Connected\' OR Lead_Stage__C = \'Closed Won\' OR Lead_Stage__C = \'Closed Lost\')  limit 49000';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        List<Lead> leadlistToBeUpdated = new List<Lead>();
        if(!leadList.isEmpty()){
            for(Lead ld : leadList){
                if(ld.Tasks.size() > 0){
                    lead leadToBeUpdated = new lead();
                    leadToBeUpdated.id = ld.Id;
                    leadToBeUpdated.First_Connected_Date_Time__c = ld.Tasks[0].CreatedDate;
                    
                    if(ld.Tasks[0].CreatedDate != null)
                        leadToBeUpdated.FRT_Based_on_Created_Date_Connected__c  = decimal.valueof((ld.Tasks[0].CreatedDate.getTime() - ld.CreatedDate.getTime())/(60000));
                    leadToBeUpdated.FRT_Connected_Updated__c = true;
                    leadlistToBeUpdated.add(leadToBeUpdated);
                }
            }
            if(!leadlistToBeUpdated.isEmpty()){
                update leadlistToBeUpdated;
            }
        }
        
    }   
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }}