@isTest
public class LeadReassignmentBatchTest {

    
    @isTest
    public static void LeadAssignmentTest(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        List<Lead> listOfLead=new List<Lead>();
        for(Integer i=0;i<100;i++){
            Lead leadData=new Lead();
            leadData.FirstName='First Name'+i;
            leadData.LastName='Last Name'+i;
            leadData.Company='Company '+i;
            //leadData.Lead_Stage__c='Called';
            leadData.Learner_Uid__c='UIC-'+(i+1);
            leadData.Source_Intent__c='FrontEnd-Development';
            leadData.Goal_Interested_In__c='FrontEnd-Development';
            leadData.Lead_Stage__c='Called';
            leadData.Lead_Age__c=i+1;
            leadData.Lead_status__c = 'Not Contact';
            leadData.Temperature__c = 'Hot';
            listOfLead.add(leadData);
        }
        
        Test.startTest();
        insert listOfLead;
        //LeadReassignmentBatch batchClass= new LeadReassignmentBatch();
        //Database.executeBatch(batchClass);
        Test.stopTest();
    }
}