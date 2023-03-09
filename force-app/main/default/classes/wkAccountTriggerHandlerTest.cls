@isTest
public class wkAccountTriggerHandlerTest {
    @isTest
    public static void accountRecord(){
        List<Account> accInsertList= new List<Account>();
        wk_exo__Exotel_Configuration__c config= new wk_exo__Exotel_Configuration__c();
        config.wk_exo__By_Default_Create__c='Account';
        config.wk_exo__SID__c='wk';
        config.wk_exo__Masking_Character__c='*';
        config.wk_exo__Number_of_Digits__c='6';
        insert config;
        Account acc= new Account();
        acc.Name='08558885850';
        acc.Phone='08558885850';
        accInsertList.add(acc);
        insert accInsertList;
        wkTriggerHandler.accountTriggerController(accInsertList);
        
    }
     @isTest
    public static void contactRecord(){
        List<Contact> conInsertList= new List<Contact>();
        wk_exo__Exotel_Configuration__c config= new wk_exo__Exotel_Configuration__c();
        config.wk_exo__By_Default_Create__c='Contact';
        config.wk_exo__SID__c='wk';
        config.wk_exo__Masking_Character__c='*';
        config.wk_exo__Number_of_Digits__c='6';
        insert config;
        Contact con= new Contact();
        con.LastName='08558885850';
        con.Phone='08558885850';
        conInsertList.add(con);
        insert conInsertList;
        wkTriggerHandler.contactTriggerController(conInsertList);
        
    }
     @isTest
    public static void LeadRecord(){
        List<Lead> leadInsertList= new List<Lead>();
        wk_exo__Exotel_Configuration__c config= new wk_exo__Exotel_Configuration__c();
        config.wk_exo__By_Default_Create__c='Lead';
        config.wk_exo__SID__c='wk';
        config.wk_exo__Masking_Character__c='*';
        config.wk_exo__Number_of_Digits__c='6';
        insert config;
        Lead lead= new Lead();
        lead.Lead_status__c='New';
        lead.LastName='test';
        lead.Learner_Uid__c='xyz';
        lead.Status='Male';
        lead.Company='wk';
        lead.Goal_Interested_In__c='Business-Development';
        lead.Phone='08558885850';
        leadInsertList.add(lead);
        insert leadInsertList;
        wkTriggerHandler.leadTriggerController(leadInsertList);
        
    }
}