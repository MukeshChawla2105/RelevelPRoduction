@isTest
public class DailyKPIsTest {

    
    
    @isTest
    public static void calculateKPIS(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        //testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel;
        test.startTest();
        DailyKPIs kpis=new DailyKPIs();
        Task tasks=new Task();
        tasks.Subject='test';
        tasks.Description='test';
        tasks.wk_exo__Exotel_Call_Type__c='Received';
        insert tasks;
        
        Assignment_Group__c groups=new Assignment_Group__c();
        groups.Name='test';
        insert groups;
        
        Assignment_Group_Member__c member = new Assignment_Group_Member__c();
        member.Out_Of_Office__c=false;
        member.Active__c=true;
        member.Assignment_Group__c=groups.Id;
        member.Assignment_Id__c=12;
        
        Lead leads=new Lead();
        //leads.=Date.today();
        leads.FirstName='test';
        leads.LastName='Last Name';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c = 'Backend-Development';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Payment_details__c=2.0;
        leads.Phone='+917042458620';
        insert leads;
        
        insert member;
        DailyKPIs.calculateDailyKPIs();
        
        
        Daily_KPIs__c daily=new Daily_KPIs__c();
        daily.Avg_Order_Value_MTD__c=2.22;
       // daily.CreatedDate=Date.addDays(2);
        insert daily;
        DailyKPIs.calculateDailyKPIs();

        test.stopTest();
    }
}