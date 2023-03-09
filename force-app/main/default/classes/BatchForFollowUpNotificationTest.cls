@isTest
public class BatchForFollowUpNotificationTest {
    
    @testSetup
    static void setup() {
        user u = [Select id, name from user LIMIT 1];
        list<Task> TaskList = new List<Task>();
        for(integer i = 0; i<5; i++){
            task tsk = new task();
            tsk.Activity_Date_Time__c = system.today()+i;
            tsk.Follow_Up_Activity_Datetime__c = system.today()+i;
            tsk.OwnerId = u.Id;
            tasklist.add(tsk);
        }
        insert tasklist;
    }
    @isTest static void test() {
        Test.startTest();
        BatchForFollowUpNotification BFFUN = new BatchForFollowUpNotification();
        Id batchId = Database.executeBatch(BFFUN);
        Test.stopTest();
        
    }

}