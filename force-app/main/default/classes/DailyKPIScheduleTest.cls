@isTest
public class DailyKPIScheduleTest {

    
    @isTest
    public static void DailyTest()
    {
        Test.startTest();
        DailyKPISchedule sh1 = new DailyKPISchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test DailyKPISchedule', sch, sh1); 
        Test.stopTest();
    }
}