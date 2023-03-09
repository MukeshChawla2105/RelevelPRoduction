@isTest
public class CheckOutScheduleTest {

    
    @isTest
    public static void CheckOutScheduleTestable(){
        test.startTest();
        CheckOutSchedule testing=new CheckOutSchedule();
        String sch = '0 0 2 * * ?';
        system.schedule('Test status Check', sch, testing );
        Test.stopTest();
    }
}