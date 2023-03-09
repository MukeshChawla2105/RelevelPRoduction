@isTest
public class ActivityModelTest {

    
    
    @isTest
    public static void testActivityDetails(){
        ActivityModel.ActivityDetails details=new ActivityModel.ActivityDetails();
        details.course_name='test';
        details.course_slug='test';
        details.email='test@mailinator.com';
        details.revenue='20000';
        
        ActivityModel.ActivityDetails details1=new ActivityModel.ActivityDetails();
        details1.course_name='test';
        details1.course_slug='test';
        details1.email='test@mailinator.com';
        details1.revenue='20000';
        
        ActivityModel model=new ActivityModel();
        model.activity_details =new List<ActivityModel.ActivityDetails>();
        model.activity_details.add(details);
        
        model.activity_details.add(details1);
        
        test.startTest();
        
        
        ActivityModel.parse(System.JSON.serialize(model));
        test.stopTest();
    }
}