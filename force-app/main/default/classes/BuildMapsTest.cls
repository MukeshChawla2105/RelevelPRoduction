@isTest
public class BuildMapsTest {

    
    @isTest
    public static void BuildMapTest()
    {
         wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        
        Group testGroup = new Group(Name='Relevel Default Queue', Type='Queue');
        insert testGroup;
    
        Assignment_Group__c assignGroup = new Assignment_Group__c();
        assignGroup.Name='Front End';
        assignGroup.Last_Allocated_RRid__c=1;
        insert assignGroup;
        
        Assignment_Group_Member__c assignMember= new Assignment_Group_Member__c();
        assignMember.Out_Of_Office__c=false;
        assignMember.Assignment_Group__c=assignGroup.Id;
        assignMember.Assignment_Id__c=1;
        assignMember.Active__c=true;
        insert assignMember;
        
        Assignment_Group_Member__c assignMember1= new Assignment_Group_Member__c();
        assignMember1.Out_Of_Office__c=false;
        assignMember1.Assignment_Group__c=assignGroup.Id;
        assignMember1.Assignment_Id__c=2;
        assignMember1.Active__c=true;
        insert assignMember1;
        
        Assignment_Group_Member__c assignMember2= new Assignment_Group_Member__c();
        assignMember2.Out_Of_Office__c=false;
        assignMember2.Assignment_Group__c=assignGroup.Id;
        assignMember2.Assignment_Id__c=3;
        assignMember2.Active__c=true;
        insert assignMember2;
        
        List<Lead> listOfLead=new List<Lead>();
        for(Integer i=0;i<100;i++){
            Lead leadData=new Lead();
            leadData.FirstName='First Name'+i;
            leadData.LastName='Last Name'+i;
            leadData.Company='Company '+i;
            leadData.Lead_Stage__c='new';
            leadData.Learner_Uid__c='UIC-'+(i+1);
            leadData.Source_Intent__c='Frontend-Development';
            leadData.Goal_Interested_In__c='Frontend-Development';
            leadData.Lead_Stage__c='New';
            leadData.Lead_Age__c=i+1;
            leadData.Lead_Assigned_Date__c = system.today();
           // leadData.OwnerId='00G9D000002jYUDUA2';
            listOfLead.add(leadData);
        }
        
        
        
        Test.startTest();
        insert listOfLead;
       
        TestUtility.createTestData();
        BuildMaps buildMap=new BuildMaps();
        
        //BuildMaps.makeQueueNameToListOfAssignedLeadsMap();
        //BuildMaps.makeCustomQueueNameToListOfUserId();
        BuildMaps.makeAllMemberOOF();
        //BuildMaps.userWiseLeadCount();
        Test.stopTest();
    }
}