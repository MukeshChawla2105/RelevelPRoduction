public class BatchToUpdateQScoreOnLead implements
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String QueryString = 'SELECT Id,Lead__c,Name,Quality_Score__c FROM Quality_Score__c where Lead__c !=null';
        return Database.getQueryLocator(QueryString);
    }
    public void execute(Database.BatchableContext bc, List<Quality_Score__c> QScoreList){
        // process each batch of records
        map<String, Quality_Score__c> LeadIdWithQualityScore = new map<String, Quality_Score__c>();
        set<Id> LeadIdlist = new set<Id>();
        List<Lead> LeadListToBeFetched = new List<Lead>();
        List<Lead> LeadListToBeUpdated = new List<Lead>();
        
        if(!QScoreList.isEmpty()){
            for(Quality_Score__c Qscore : QScoreList){
                LeadIdWithQualityScore.put(Qscore.Lead__c, Qscore);
                LeadIdlist.add(Qscore.Lead__c);
            }
            if(!LeadIdlist.isEmpty()){
                LeadListToBeFetched = [SELECT Id, name, Quality_Score__c FROM Lead where Id IN: LeadIdlist and (Quality_Score__c = null OR Quality_Score__c = 0)];
                system.debug('LeadListToBeFetched :: ' + LeadListToBeFetched);
            }
            if(!LeadListToBeFetched.isEmpty()){
                for(Lead ld : LeadListToBeFetched){
                    lead updatedlead = new Lead();
                    updatedlead.Id = ld.id;
                    updatedlead.isQualityScoreUpdated__c = true;
                    updatedlead.Quality_Score__c = LeadIdWithQualityScore.get(ld.id).Quality_Score__c;
                    LeadListToBeUpdated.add(updatedlead);
                }
            }
            if(!LeadListToBeUpdated.isEmpty()){
                update LeadListToBeUpdated;
            }
        }
        
        
    }
    public void finish(Database.BatchableContext bc){
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }
    
}