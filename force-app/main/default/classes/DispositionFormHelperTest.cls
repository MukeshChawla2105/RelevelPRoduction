@isTest
public class DispositionFormHelperTest {
    
    
    
    @isTest
    public static void testFetchLead(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        Lead leads=new Lead();
        //leads.=Date.today();
        leads.FirstName='test';
        leads.LastName='Last Name';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c = 'Backend-Development';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Payment_details__c=2.0;
        insert leads;
        
        test.startTest();
        DispositionFormHelper.fetchLead(leads.Id);
        DispositionFormHelper.updateLeadData(leads);
        //'Lead','Source_Intent__c'
        DispositionFormHelper.getPickListValuesIntoList('Lead','Source_Intent__c');
        DispositionFormHelper.getAllPickValues('Lead');
        test.stopTest();
    }
}