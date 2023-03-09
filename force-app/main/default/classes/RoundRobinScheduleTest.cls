@isTest
public class RoundRobinScheduleTest {

    
    @isTest
    public static void RoundRobinTestSchedule()
    {
        Test.startTest();
        RoundRobinSchedule sh1 = new RoundRobinSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test RoundRobinSchedule', sch, sh1); 
        Test.stopTest();
    }
}