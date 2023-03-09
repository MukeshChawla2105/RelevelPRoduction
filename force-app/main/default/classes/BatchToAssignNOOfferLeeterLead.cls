public without sharing class BatchToAssignNOOfferLeeterLead implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        string newFlowLeadRT = Constant.IdLeadNewFlowRT;
        DateTime tenNovDate = DateTime.newInstance(2022, 11, 09, 0, 0, 0);
        
        String query = 'select id,ownerId from Lead where recordtypeid =: newFlowLeadRT AND Offer_Status__c = \'No\' and  Send_Admission_Letter_No_DAte_Time__c >:tenNovDate';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        if(!leadList.isEmpty()){
            CounsellorsAssignmentModule.counsellorAssignmentLogic(leadList);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}