@isTest public class UserTriggerHandlerTest {
    @testSetup
    public static void testSetupMethod(){
        User manager = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name =: system.label.BDE_Profile_Name].Id,
            LastName = 'last',
            Email = 'test@mailinator.com',
            isActive = true,
            Username = 'test@mailinator.com'+ System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        ); 
        insert manager;
        User BDA = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :system.label.BDE_Profile_Name].Id,
            LastName = 'BDA',
            isActive = true,
            Email = 'test@mailinator.com',
            Username = 'test@mailinator.com'+ System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ManagerId = manager.Id
        ); 
        insert BDA;
   
        wk_exo__Exotel_Configuration__c exoConfig = new wk_exo__Exotel_Configuration__c();
        insert exoConfig;
        Assignment_Group__c ag = new Assignment_Group__c();
        ag.Name = 'Test';
        insert ag;
        Assignment_Group_Member__c agm1 = new Assignment_Group_Member__c();
        agm1.Assignment_Group__c = ag.Id;
        agm1.Assignment_Id__c = 1;
        agm1.Group_Member__c = manager.Id;
        insert agm1;
        Assignment_Group_Member__c agm2 = new Assignment_Group_Member__c();
        agm2.Assignment_Group__c = ag.Id;
        agm2.Assignment_Id__c = 2;
        agm2.Group_Member__c = BDA.Id;
        insert agm2;   
        Lead leadRec = TestUtility.createLead();
        system.debug('BDA.Id>>'+BDA.Id);
        leadRec.ownerId = BDA.Id;
        insert leadRec;
        system.debug('leadRec>>'+leadRec);
    }
    @isTest
    public static void testingUserTriggerTest(){
        User userToUpdate = [Select Id,IsActive From User WHere LastName = 'BDA' limit 1];
        system.debug('userToUpdate::>'+userToUpdate);
        userToUpdate.IsActive = false;
        update userToUpdate;
    }
}