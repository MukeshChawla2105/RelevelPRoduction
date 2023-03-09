trigger AOAvailabilityTrigger on AO_Availability__c (before update,after update) {
    
    if (trigger.isBefore && trigger.isUpdate) {
        system.debug('Before Update');
        AOAvailabilityTriggerHandler.UpdateLastEngagementTime(trigger.newMap, Trigger.oldMap);
        AOAvailabilityTriggerHandler.updateEndBreakTimeToAoAvailability(trigger.new, Trigger.oldMap); 
        AOAvailabilityTriggerHandler.makeAOUnavailableAfter9PM(trigger.new, Trigger.oldMap); 
        AOAvailabilityTriggerHandler.handleAOStatus(trigger.newMap, Trigger.oldMap);
    }
    
    if (trigger.isAfter && trigger.isUpdate) {
        AOAvailabilityTriggerHandler.insertLogsRecord(trigger.newMap, Trigger.oldMap);
        
         AOAvailabilityTriggerHandler.updateBreakEndTime(trigger.newMap, Trigger.oldMap);
    }
    
}