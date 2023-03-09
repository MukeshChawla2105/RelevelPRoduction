public class LogoutEventTriggerHandler {
	
    public static void disableAoOnLogout(LogoutEventStream logoutEvent){
        LogoutEvent__c record = new LogoutEvent__c();
        record.UserId__c = logoutEvent.UserId;
        insert(record);
    }
}