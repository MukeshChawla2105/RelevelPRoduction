public with sharing class CallingSMLinkGeneratorInFuture {
    
    @future(callout=true)
    public static void SMLinkGenratorInFuture(String userId) {
        
        User_Tracking__c userTrackRec = new User_Tracking__c();
        SMMeetingLinkGenerator.MeetingUrlGenerator(userId, userTrackRec);
    }
}