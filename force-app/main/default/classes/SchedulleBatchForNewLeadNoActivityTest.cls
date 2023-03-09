@istest
public class SchedulleBatchForNewLeadNoActivityTest {
    
    public static testMethod void testschedule() {
		Test.StartTest();
		SchedulleBatchForNewLeadNoActivity testsche = new SchedulleBatchForNewLeadNoActivity();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}