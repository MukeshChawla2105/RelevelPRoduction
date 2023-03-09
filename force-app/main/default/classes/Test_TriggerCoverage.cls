@isTest
public class Test_TriggerCoverage {
    
    @isTest
    public static void triggerTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser90@testorg.com');
        insert u;
        Lead leads = new Lead();
        leads.Lead_Assigned_Date__c = Date.today();
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
        leads.OwnerId = u.id;
        insert leads;
        
        Interview__c intRec = new Interview__c();
        intRec.Lead__c = leads.Id;
        intRec.Interviewer__c = leads.OwnerId;
        intRec.Meeting_URL__c = 'test';
        intRec.Status__c = 'Started';
        insert intRec;
        
        /*intrec.Status__c = 'Completed';
update intrec;*/
        
        AO_Availability__c ao = new AO_Availability__c();
        ao.Status__c = 'Available';
        //ao.Audit_Officer__c = u.id;
        insert ao;
        
        ao.Status__c = 'In Meeting';
        update ao;
        
        AO_Activity__c AO_Act = new AO_Activity__c();
        AO_Act.Meeting_Url__c = 'https://relevel--uat.sandbox.lightning.force.com/lightning/page/home';
        AO_Act.Meeting_Unique_Id__c = 'AUVSUWFBJ83V83BC83B46VD6302';
        AO_Act.Lead__c = leads.id;
        Insert AO_Act;
        AO_Act.Description__c = 'hii how are you?';
        AO_Act.Event_Status__c = 'Completed';
        update AO_Act;
        
    }
    @isTest
    public static void logoutEventTest(){
        Test.startTest();    
        EventBus.publish(new LogoutEventStream());
        Test.stopTest();
    }
    @isTest
    public static void auditCounsellorTest(){
        Test.startTest();    
        Audit_Counsellor__c auditCounsellorRec = new Audit_Counsellor__c ();
        insert auditCounsellorRec;
        delete [Select Id from Audit_Counsellor__c];
        Test.stopTest();
    }
    @isTest
    public static void usertrackingTriggerTest(){
        Test.startTest();    
        User_Tracking__C userTrackingRec = new User_Tracking__C ();
        insert userTrackingRec;
        Test.stopTest();
    }
}