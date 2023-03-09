@isTest
public class Webservice_CreateActivityTest {

    
    @isTest
    public static void webServiceCheck(){
        wk_exo__Exotel_Configuration__c testExotel = new wk_exo__Exotel_Configuration__c();
        testExotel.wk_exo__By_Default_Create__c = 'Lead';
        testExotel.wk_exo__SID__c = '12345';
        testExotel.wk_exo__Masking_Character__c = '*';
        testExotel.wk_exo__Number_of_Digits__c = '11';
        testExotel.wk_exo__Record_Type__c = 'test';
        insert testExotel; 
        ActivityModel detailsModel= new ActivityModel();
        detailsModel.activity_details=new List<ActivityModel.ActivityDetails>();
        
        test.startTest();
        Lead leads=new Lead();
        //leads.=Date.today();
        leads.FirstName='test';
        leads.LastName='Last Name';
        leads.Source_Intent__c='Backend-Development';
        leads.Goal_Interested_In__c = 'Backend-Development';
        leads.Company='test';
        leads.Learner_Uid__c='test';
        leads.Payment_details__c=2.0;
        leads.Learner_Uid__c='Can-1234';
        leads.Lead_Stage__c='New';
        insert leads;
        
        ActivityModel.ActivityDetails details=new ActivityModel.ActivityDetails();
        details.course_name='test';
        details.course_slug='test';
        details.email='test@mailinator.com';
        details.revenue='20000';
        details.activity_type='Test Taken';
        details.search_by_value='Can-1234';
        details.exam_name='Front end';
        details.exam_slug='Front end';
        details.exam_date=Date.today();
        details.exam_score=20;
        details.course_id='12';
        details.cohort_name='test';
        details.cohort_id='12';
        details.redirect_url='https://';
        details.skill_based_exam_score='89.02';
        details.is_qualified_in_exam=true;
        detailsModel.activity_details.add(details);
        
        ActivityModel.ActivityDetails details1=new ActivityModel.ActivityDetails();
        details1.course_name='test';
        details1.course_slug='test';
        details1.email='test@mailinator.com';
        details1.revenue='20000';
        details1.activity_type='Test Taken';
        details1.search_by_value='Can-1234';
        details1.exam_name='Front end';
        details1.exam_slug='Front end';
        details1.exam_date=Date.today();
        details1.exam_score=20;
        details1.skill_based_exam_score='89.02';
        details.course_id='12';

        details.cohort_name='test';
        details.cohort_id='12';
        details.redirect_url='https://';
        details1.is_qualified_in_exam=true;
        detailsModel.activity_details.add(details);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/activity_creation_event/*'; 
        req.requestBody = Blob.valueof(JSON.serialize(detailsModel.activity_details));

        RestContext.request = req;
        RestContext.response= res;
        Webservice_CreateActivity.createActivityAgainstLead();
        
        for(ActivityModel.ActivityDetails modelData:detailsModel.activity_details ){
            modelData.search_by_value=null;
        }
        Webservice_CreateActivity.createActivityAgainstLead();
        test.stopTest();
    }
}