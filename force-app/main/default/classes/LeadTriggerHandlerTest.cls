@isTest
public without sharing class LeadTriggerHandlerTest {

    
    @isTest
    public static void LeadTriggerTest(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        Group testGroup = new Group(Name='Relevel Default Queue', Type='Queue');
        insert testGroup;
        
        
        Lead leads= new Lead();
        leads.FirstName ='test first name';
        leads.LastName='Test last name';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Source_Intent__c='Backend-Development';
        leads.Temperature__c = 'Hot';
        leads.Follow_Up_Date__c=Date.today();
        leads.Goal_Interested_In__c = 'Business-Development';
        leads.Lead_status__c = 'New';
        //leads.OwnerId=testGroup.Id;
        List<Lead> listLead=new List<Lead>();
        listLead.add(leads);
        
        test.startTest();
        
        insert listLead;
        LeadTriggerHandler.assignDefaultQueue(listLead);
        LeadTriggerHandler.runLeadAssignment(listLead);
        
        List<Lead> listofLead=new List<Lead>();
        leads.Follow_Up_Date__c=Date.today().addDays(2);
        listofLead.add(leads);
        update listofLead;
        
        Map<Id,Lead> leadsMap=new Map<Id,Lead>(listLead);
        System.debug(leadsMap);
        Map<Id,Lead> newleadsMap=new Map<Id,Lead>(listofLead);
        System.debug(newleadsMap);
        System.debug(leadsMap);
        LeadTriggerHandler.insertFollowUpTask(newleadsMap,leadsMap);// (leadsMap,newleadsMap);
        LeadTriggerHandler.updateFollowUpCount(leadsMap,newleadsMap);
        LeadTriggerHandler.updateStageAsClosure(leadsMap,newleadsMap);
        test.stopTest();
        
        Lead Leadrec = [Select Id,Lead_status__c From Lead limit 1] ;
        Leadrec.Lead_status__c = 'non-contact';
        Leadrec.Goal_Interested_In__c = 'Frontend-Development';
        update LeadRec;
        
    }
}