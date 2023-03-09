trigger Trigger_LogoutEvent on LogoutEvent__c (after insert) {
	
    if(Trigger.isInsert && Trigger.isAfter){
        LogoutEventHandler.disbaleAOOnLogout(trigger.new);
    }
}