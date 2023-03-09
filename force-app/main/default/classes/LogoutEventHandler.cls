public class LogoutEventHandler {
	
    public static void disbaleAOOnLogout(list<LogoutEvent__c> logEvents){
        Set<Id> userIdTobeMarkUnavailable = new Set<Id>();
        for(LogoutEvent__c logEvent : logEvents){
            userIdTobeMarkUnavailable.add(logEvent.UserId__c);
        }
        
        if(!userIdTobeMarkUnavailable.isEmpty()){
            List<AO_Availability__c> aoAvailabilityList = new List<AO_Availability__c>();
            aoAvailabilityList = [select id,status__c from AO_Availability__c where createddate = today and status__c = 'Available' and Audited_Officer__c in: userIdTobeMarkUnavailable];
            
            if(!aoAvailabilityList.isEmpty()){
                for(AO_Availability__c ao : aoAvailabilityList){
                    ao.status__c = 'Not Available';
                }
                
                update aoAvailabilityList;
            }
        }
    }
}