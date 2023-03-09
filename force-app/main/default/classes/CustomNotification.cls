public class CustomNotification {
    public static void notifyUsers(Set<String> recipientsIds, Map<Id,Lead> leadByIdMap, string notificationTitle, String notificationBody) {
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FollowUpTaskReminder'];
        if(notificationType != null){
            if(!leadByIdMap.isEmpty()){
                for(Lead leadRec : leadByIdMap.values()){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    if(!string.isBlank(notificationTitle))
                        notification.setTitle(notificationTitle);
                    if(!string.isBlank(notificationBody))
                        notification.setBody(notificationBody+' '+leadRec.FirstName+' '+leadRec.LastName+' , '+leadRec.Learner_Uid__c);
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(leadRec.Id);
                    system.debug('send');
                    try {
                        system.debug('sending');
                        notification.send(recipientsIds);
                    }
                    catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                    }   
                } 
            }
        }
    }
}