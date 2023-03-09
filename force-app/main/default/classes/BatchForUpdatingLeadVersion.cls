public class BatchForUpdatingLeadVersion implements Database.Batchable<sObject>{
    public static final string IdLeadOldFlowRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Old Flow').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,Lead_Version__c,recordTypeId,Updated_Lead_Version__c From Lead where Updated_Lead_Version__c = false';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        List<Lead> leadListToUpdate = new List<Lead>();
        
        for(Lead leadRec : leadList){
            Lead LeadRecToUpdate = new Lead();
            LeadRecToUpdate.Id = leadRec.Id;
            LeadRecToUpdate.RecordTypeId = IdLeadOldFlowRT; 
            LeadRecToUpdate.Lead_Version__c = 'V0';
            LeadRecToUpdate.Updated_Lead_Version__c = true;
            leadListToUpdate.add(LeadRecToUpdate);
        }
        if(!leadListToUpdate.isEmpty()){
            update leadListToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC) {
    }  
}