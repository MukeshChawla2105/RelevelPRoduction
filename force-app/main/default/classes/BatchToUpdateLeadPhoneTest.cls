@isTest
public class BatchToUpdateLeadPhoneTest {
    @isTest public static void testing(){
        wk_exo__Exotel_Configuration__c wkExo = new wk_exo__Exotel_Configuration__c();
        insert wkExo;
        Lead ld = new Lead();
        ld.LastName = 'Aakash';
        ld.Company = 'abd';
        ld.Learner_Uid__c = 'can-12';
        ld.Goal_Interested_In__c = 'Data-Analytics';
        ld.phone ='+919128384384';
        insert ld;
        BatchToUpdateLeadPhone batchInstance = new BatchToUpdateLeadPhone();
        database.executeBatch(batchInstance);
    }
}