@isTest public class SendEmailHandlerTest {
    @isTest public static void testindSendEmailHandler(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        
        Lead leads= TestUtility.createLead();
        insert leads;
        string message = 'testing {!User.FirstName} tesing {!Lead.FirstName}';
        SendEmailHandler.processEmail(leads.email, 'Subject', message);
        SendEmailHandler.fetchLeadDetails(leads.Id);
        }
}