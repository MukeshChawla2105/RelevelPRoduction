@isTest public class LeadReassignmentHelperTest {
    @isTest public static void reassignmentHelperTest(){
        wk_exo__Exotel_Configuration__c exoConfig = new wk_exo__Exotel_Configuration__c ();
        insert exoConfig;
        Lead leads=new Lead();
        leads.FirstName='test';
        leads.LastName='Last Name';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c='FrontEnd-Development';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Payment_details__c=2.0;
        leads.Learner_Uid__c='test UID';
        leads.Temperature__c = 'Hot';
        //leads.Lead_Stage__c='New';
        insert leads;
        //LeadReassignmentHelper.updateLeadDetails(leads.Id);
    }
}