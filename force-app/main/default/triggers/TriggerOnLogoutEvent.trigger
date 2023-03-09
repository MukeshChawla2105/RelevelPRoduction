trigger TriggerOnLogoutEvent on LogoutEventStream (after insert) {
	
    if(trigger.isInsert && trigger.isAfter){
        LogoutEventTriggerHandler.disableAoOnLogout(Trigger.new[0]);
    }
}