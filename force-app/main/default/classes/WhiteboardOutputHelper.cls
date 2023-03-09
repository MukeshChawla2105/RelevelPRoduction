public class WhiteboardOutputHelper {
    @AuraEnabled
    public static List<Whiteboard_Markings__c> getWhiteBoardMarkings(){
        id currentUserId = userinfo.getProfileId();
        String profileName ;
        List<Whiteboard_Markings__c> whiteboardUpdates = new List<Whiteboard_Markings__c>();
        
        if(!string.isBlank(currentUserId)){
            profileName = [select Name from profile where id = : currentUserId].Name;
            if(!String.isBlank(profileName)){
                whiteboardUpdates = [Select Id,End_Date__c,Notification__c,Profile__c,Start_Date__c From Whiteboard_Markings__c Where Profile__c =: profileName OR Profile__c = 'All' limit 2];
            }
        }
        system.debug('whiteboardUpdates-->'+whiteboardUpdates);
        return whiteboardUpdates;
    }
}