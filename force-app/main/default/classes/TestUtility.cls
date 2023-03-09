@isTest
public class TestUtility {
    public static List<Lead> createTestData(){
        List<Lead> listLead=new List<Lead>();
        for(Integer i=0;i<10;i++)
        {
            Lead leads=new Lead();
            leads.Lead_Assigned_Date__c = Date.today();
            leads.FirstName='test'+i;
            leads.LastName='Last Name'+i;
            leads.Source_Intent__c='Backend-Development';
            leads.Goal_Interested_In__c='FrontEnd-Development';
            leads.Company='test'+i;
            leads.Learner_Uid__c='test'+i;
            leads.Payment_details__c=2.0;
            leads.Learner_Uid__c='test UID';
            leads.Temperature__c = 'Hot';
            leads.Lead_Stage__c='New';
            listLead.add(leads);
        }
        insert listLead;
        System.debug(listLead);
        return listLead;
    }
    
    public static List<Task> createTestTask(){
        List<Task> listTask=new List<Task>();
        for(Integer i=0;i<10;i++){
            Task taskData=new Task();
            taskData.Subject='Test '+i;
            taskData.Description='Test '+i;
            // taskData.wk_exo__call_end_time__c=string.valueof( DateTime.newInstance(2021,1, i+1, 3, 3, 3));
            taskData.wk_exo__call_start_time__c=string.valueof( DateTime.newInstance(2021,1, i+1, 3, 3, 3));
            listTask.add(taskData);
        }
        insert listTask;
        return listTask;
    }
    public static Lead createLead(){
        Lead leadRec = new Lead();
        leadRec.FirstName ='test first name';
        leadRec.LastName='Test last name';
        leadRec.Company='test';
        leadRec.phone='01234567891';
        leadRec.Learner_Uid__c='test';
        leadRec.Source_Intent__c='Backend-Development';
        leadRec.Goal_Interested_In__c='FrontEnd-Development';
        leadRec.Follow_Up_Date__c=Date.today();
        leadRec.Email = 'aakash.jain@mailinator.com';
        //leads.OwnerId=testGroup.Id;
        return leadRec;
    }
    public static void insertUserInfo(String firstName, String LastName, String Email, String userName, Boolean isActive,String managerId){
        
        List<Profile> profileList = [Select Id,Name From Profile Where Name =: system.label.BDE_Profile_Name OR Name = 'Sales Manager' OR Name = 'Senior Sales Manager'];
        System.debug('profileList::'+profileList);
        List<User> userList = new List<User>();
    }
}