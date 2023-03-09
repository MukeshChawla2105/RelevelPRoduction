@isTest public class CustomNotificationTest {
    @isTest public static void notifyUsersTest(){
        Map<Id, Lead> leadByIdMap = new Map<Id, Lead>();
        
        set<String> recipientsIds = new Set<String>{userInfo.getUserId()};
        
            List<Lead> leadList = TestUtility.createTestData(); 
        
        for(Lead leadRec : leadList){
            leadByIdMap.put(leadRec.Id, leadRec);
        }
        CustomNotification.notifyUsers(recipientsIds,leadByIdMap, 'notificationTitle', 'notificationBody');
    }
}