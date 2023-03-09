@isTest public class BDADailyKPIScheduleTest {
    @isTest
    public static void DailyTest()
    {
        Test.startTest();
        BDADailyKPISchedule testing=new BDADailyKPISchedule();
        String sch = '0 0 2 * * ?';
        system.schedule('Test status Check', sch, testing );
        Test.stopTest();
    }
}