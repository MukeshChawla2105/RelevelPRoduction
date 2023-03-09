@isTest
public class EventTriggerHelperTest {
    
    
    @isTest 
    public static void Method1(){
        
        event e = new Event();
        e.Attendees__c = 'Mikes.chawla@gmail.com';
        e.StartDateTime = system.now().addhours(+5);
        e.Event_Status__c = 'Open';
        e.GMeet_Event_Id__c = 'ABY21964B0384BSALJ03NCW862';
        e.Meeting_URL__c = 'https://meet.google.com/hiu-rvum-fob';
        e.EndDateTime = system.now().addhours(+6);
        Test.startTest();
        // Insert book
        insert e;
        // Insert book
        e.GMeet_Event_Id__c = 'PEVCSOEWIDOE0327VB0932RN3';
        update e;
        Test.stopTest();
        
        
    }

}