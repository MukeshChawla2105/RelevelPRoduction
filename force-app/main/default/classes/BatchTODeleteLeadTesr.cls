@isTest public class BatchTODeleteLeadTesr {
    
    @isTest Public static void deletingLeads(){
        wk_exo__Exotel_Configuration__c wkExo = new wk_exo__Exotel_Configuration__c();
        insert wkExo;
        Lead ld = new Lead();
        ld.LastName ='Test';
        ld.Company = 'Util';
        ld.Phone='0911234567892';
        ld.Goal_Interested_In__c = 'Data-Analytics';
        ld.Source_Intent__c = 'Data-Analytics';
        ld.Learner_Uid__c = 'CAN-!12214234';
        insert ld;
        BatchToDeleteAllLeads batchInstanc = new BatchToDeleteAllLeads();
        database.executeBatch(batchInstanc);
    }
}