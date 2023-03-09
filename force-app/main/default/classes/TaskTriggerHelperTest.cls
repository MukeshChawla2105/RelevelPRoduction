@isTest
public class TaskTriggerHelperTest {

    
    
    @isTest 
    public static void Method1(){
       
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
         Set<Id> IdSet = new Set<Id>();
        List<Task> newTask = new List<Task>();
        List<Lead> LeadList = new List<Lead>();
        Map<Id,List<Task>> newTaskMap = new Map<Id,List<Task>>();
        Map<Id,List<Task>> oldTaskMap = new Map<Id,List<Task>>();
        integer callTime = 0;
        integer talkTime = 0;
        integer totalCall = 0;
        integer connectedCallCount = 0;
        
        Lead le = new Lead();
        le.FirstName='test';
        le.LastName='Last Name';
        le.Source_Intent__c='Backend-Development';
        le.Goal_Interested_In__c = 'Backend-Development';
        le.Company='test';
        le.Learner_Uid__c='test';
        le.Phone = '07042458620';
        le.Temperature__c = 'Hot';
        le.Payment_details__c=2.0;
        insert le;
        
        Task tk = new Task();
        tk.Subject = 'New Subject';
        tk.Status = 'Open';
        tk.WhoId = le.Id;
        tk.CallDurationInSeconds = 10;
        insert tk;
        tk.CallDurationInSeconds= 50;
        update tk;
       
        
        Lead led = new Lead();
        led.Phone = '07042458620';
        led.FirstName='test';
        led.LastName='Last Name';
        led.Source_Intent__c='Backend-Development';
        led.Goal_Interested_In__c = 'Backend-Development';
        led.Company='test';
        led.Talk_Time__c = null;
        led.Connected_Call_Time_in_Seconds__c =null;
        led.Total_Call_Count__c = null;
        led.Call_Count__c = null;
        insert led;
        
         
        Task tk1 = new Task();
        tk1.Subject = 'New Subject';
        tk1.Status = 'Open';
        tk1.WhoId = led.Id;
        tk1.CallDurationInSeconds = 10;
        insert tk1;
        tk.CallDurationInSeconds= 20;
        update tk1;
        
    }
    
    @isTest
    public static void testing(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        
        test.startTest();
        List<Task> listTask=new List<Task>();
        
        
        Lead leads=new Lead();
        //leads.=Date.today();
        leads.FirstName='test';
        leads.LastName='Last Name';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c = 'Backend-Development';
        leads.Company='test';
        leads.Phone = '07042458620';
        leads.Learner_Uid__c='test';
        leads.Temperature__c = 'Hot';
        leads.Payment_details__c=2.0;
        insert leads;
        
        
        Task taskData=new Task();
        taskData.Subject='Test ';
        taskData.Description='Test ';
        // taskData.wk_exo__call_end_time__c=string.valueof( DateTime.newInstance(2021,1, i+1, 3, 3, 3));
        taskData.wk_exo__call_start_time__c=string.valueof( DateTime.newInstance(2021,1, 1, 3, 3, 3));
        taskData.wk_exo__Exotel_Call_Type__c='Dialed';
        taskData.wk_exo__Total_Talk_Time__c='50';
        taskData.WhoId=leads.Id;
        taskData.Activity_Type__c='Sign Up';
        taskData.wk_exo__exotel_dial_status__c='Test';
        //taskData.wk_exo__Exotel_Call_Type__c='Received';
        listTask.add(taskData);
        insert listTask;
        
        Map<Id,Task> oldMap=new Map<Id,Task>(listTask);
        
        for(Task getTasks:listTask){
            getTasks.wk_exo__call_end_time__c=string.valueof( DateTime.newInstance(2021,1, 1, 3, 3, 3));
        }
        update listTask;
        Map<Id,Task> newMap=new Map<Id,Task>(listTask);
        
        
        /*
        TaskTriggerHelper.updateCallDuration(newMap,oldMap);
        for(Task getTasks:listTask){
            taskData.wk_exo__Exotel_Call_Type__c='Received';
            
        }
        update listTask;
        newMap=new Map<Id,Task>(listTask);
        TaskTriggerHelper.updateCallActivityOnLead(newMap,oldMap); */
        
        
        test.stopTest();
    }
    
    @isTest
    public static void updateLeadTest(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        test.startTest();
        List<Lead> listLead= TestUtility.createTestData();
    
        List<Task> listTask=new List<Task>();
    
        for(Integer i=0;i<10;i++){
            Task taskData=new Task();
            taskData.Subject='Test ';
            taskData.Description='Test ';
            // taskData.wk_exo__call_end_time__c=string.valueof( DateTime.newInstance(2021,1, i+1, 3, 3, 3));
            taskData.wk_exo__call_start_time__c=string.valueof( DateTime.newInstance(2021,1, 1, 3, 3, 3));
            taskData.wk_exo__Exotel_Call_Type__c='Dialed';
            taskData.wk_exo__Total_Talk_Time__c='50';
            taskData.WhoId=listLead[i].Id;
            if(math.mod(i, 2)==0)
            {
                taskData.Activity_Type__c='Payment Failed';    
            }
            else if(math.mod(i, 3)==0)
            {
                taskData.Activity_Type__c='sign up';    
            }
            else{
                taskData.Activity_Type__c='Abandoned Cart';
            }
            taskData.wk_exo__exotel_dial_status__c='Test';
            //taskData.wk_exo__Exotel_Call_Type__c='Received';
            listTask.add(taskData);
        }  
        
      insert listTask;
        Map<Id,Task> mapTask=new Map<Id,Task>(listTask);
        TaskTriggerHelper.updateLeadStage(mapTask);
        test.stopTest();
    }
    
}