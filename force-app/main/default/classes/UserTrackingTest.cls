@isTest
public class UserTrackingTest {

    
    @isTest
    public Static void Method1(){
        User_Tracking__c user = new User_Tracking__c();
        insert user;
    }

    @isTest
    public static void users()
    {
        test.startTest();
        
        User UserId = [SELECT Id,Name FROM User LIMIT 1 ];
        Assignment_Group__c grouping= new Assignment_Group__c();
        grouping.Name='Test';
        insert grouping;
        
        Assignment_Group_Member__c member=new Assignment_Group_Member__c();
        member.Group_Member__c=UserId.Id;   //
        member.Assignment_Group__c=grouping.Id;
        member.Assignment_Id__c=12;
        insert member;
            
        User_Tracking__c users=new User_Tracking__c();
        users.Checkin_Detatime__c=Date.today();
        users.Checkout_Datetime__c=Date.today();
        users.Member__c=UserId.Id; //
        insert users;
        
        UserTracking.OnpageLoad(UserId.Id);
        UserTracking.OnpageLoad(UserId.Id);
        //UserTracking.UserCheckin('0055g000002pmqhAAA');
        new UserTracking();        
        UserTracking.UserCheckin(UserId.Id);
        UserTracking.UserCheckout(UserId.Id);
        UserTracking.UserCheckout(UserId.Id);
        UserTracking.UserCheckout(null);
        test.stopTest();
    }
    
   
    @isTest
    public static void Method(){
        
        Profile p = [SELECT Id,Name FROM Profile LIMIT 1];
        System.debug('The Profile Name::'+p);
        User use = new User();
        use.Alias = 'Dines';               
        use.Username = 'dineshbaddwar@var.com';
        use.Email = 'dineshb@gmail.com';
        use.EmailEncodingKey = 'UTF-8';
        use.LastName = 'ondontecom';
        use.LanguageLocaleKey = 'en_US';
        use.LocaleSidKey = 'en_US';
        use.TimeZoneSidKey = 'America/Los_Angeles';
        use.ProfileId = p.Id;
        insert use;
          UserTracking.OnpageLoad(use.Id);
            UserTracking.UserCheckin(use.Id);
            UserTracking.UserCheckout(use.Id);
        System.debug('The User Details::'+use);
    }
    
   
    
}