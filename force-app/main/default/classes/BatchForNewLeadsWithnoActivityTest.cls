@isTest public class BatchForNewLeadsWithnoActivityTest {
    @isTest public static void batchTesting(){
       
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        Lead LeadRec = TestUtility.createLead();
        LeadRec.Lead_Assigned_Date__c = system.today();
        LeadRec.Lead_Stage__c = 'New';
        LeadRec.Phone = '07042458620';
        LeadRec.OwnerId = userinfo.getUserId();
        insert LeadRec;
        Task taskData=new Task();
        taskData.Subject='Test ';
        taskData.whoId = LeadRec.Id;
        taskData.ownerId =userinfo.getUserId();
        taskData.Description='Test ';
        taskDAta.Follow_Up_Activity_Datetime__c = Datetime.now().addMinutes(-75);
        insert taskData;
        
        BatchForNewLeadsWithnoActivity batchInstance = new BatchForNewLeadsWithnoActivity();
        database.executeBatch(batchInstance);
        BatchForFollowUpNotification batchInstanceForFollowupNotification = new BatchForFollowUpNotification();
        database.executeBatch(batchInstanceForFollowupNotification);
    }
}