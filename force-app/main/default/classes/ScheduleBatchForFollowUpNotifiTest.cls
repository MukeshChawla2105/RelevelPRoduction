@istest
public class ScheduleBatchForFollowUpNotifiTest {
    
    public static testMethod void testschedule() {
		Test.StartTest();
		ScheduleBatchForFollowUpNotifi testsche = new ScheduleBatchForFollowUpNotifi();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}