@isTest
public class AssignCTILicenseHandlerTest {
    
    @isTest 
    public static void AssignCTILicenseHandlerTestMethod(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name=: system.label.BDE_Profile_Name limit 1];
        System.debug('Profile list' + p);
        list<User> usr = new list<User>();
        User u = new User(Alias = 'MChawlas', Email='mukeshchawla1991@yahoo.com',
                          EmailEncodingKey='UTF-8', LastName='CHAWLAS', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id ,
                          TimeZoneSidKey='America/Los_Angeles', Username='mikeschawla0108@gmail.com',
                          CommunityNickname = 'TestUser');
        usr.add(u);
        insert u;
        system.debug('userlist' + usr);
        
        test.startTest();
        
        AssignCTILicenseHandler.fetchUsersWithoutCTILicense();
        List<String> UserIDlist = new List<String>();
        List<user> UserList = [Select id, Email, LastName From User ];
        for(User ur : UserList){
            UserIDlist.add(ur.id);
        }
        AssignCTILicenseHandler.assignLicencesToUser(UserIDlist);
        test.stopTest();
    }
    
}