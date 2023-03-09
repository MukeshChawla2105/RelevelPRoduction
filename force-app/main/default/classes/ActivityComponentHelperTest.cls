@isTest
public class ActivityComponentHelperTest {

  
    
    @isTest
    public static void fetchTasks(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name =: system.label.BDE_Profile_Name].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        
        insert u;
        
        Group testGroup = new Group(Name='Relevel Default Queue', Type='Queue');
        insert testGroup;
    
        Assignment_Group__c assignGroup = new Assignment_Group__c();
        assignGroup.Name='Front End';
        assignGroup.Last_Allocated_RRid__c=1;
        assignGroup.Lead_Stage__c = 'new';
        assignGroup.Lead_Stage_Exceed_Count__c = 25;
        assignGroup.Max_Lead_Per_Day__c = 25;
        insert assignGroup;
        
        Assignment_Group_Member__c assignMember= new Assignment_Group_Member__c();
        assignMember.Out_Of_Office__c=false;
        assignMember.Assignment_Group__c=assignGroup.Id;
        assignMember.Assignment_Id__c=1;
        assignMember.Max_Lead_Per_Day__c = 25;
        assignMember.Group_Member__c = u.id;
        insert assignMember;
        
        Assignment_Group_Member__c assignMember1= new Assignment_Group_Member__c();
        assignMember1.Out_Of_Office__c=false;
        assignMember1.Assignment_Group__c=assignGroup.Id;
        assignMember1.Assignment_Id__c=2;
        assignMember1.Group_Member__c = u.id;
        assignMember1.Max_Lead_Per_Day__c = 25;
        insert assignMember1;
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Relevel Default Queue' LIMIT 1].Id;
        Lead leads= new Lead();
        leads.FirstName ='test first name';
        leads.LastName='Test last name';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c = 'Backend-Development';
        leads.OwnerId = u.id;
        insert leads;
        test.startTest();
        ActivityComponentHelper.fetchTask(leads.Id);
        
        Task tasks=new Task();
        tasks.Subject='test';
        tasks.Description='test';
        insert tasks;
        
        ActivityComponentHelper.updatetaskRecord(tasks);
        ActivityComponentHelper.fetchTask(leads.Id);
        ActivityComponentHelper.fetchTasks(tasks.Id);
        
        ActivityComponentHelper.getPickListValuesIntoList('Lead','Source_Intent__c');
        test.stopTest();
    }
}