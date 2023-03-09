trigger AOActivitiesTrigger on AO_Activity__c (before insert, after insert, after update) {
    
    if(trigger.isinsert && trigger.isafter){
        AOActivitiesTriggerHandler.CreateEvent_AOActivities(trigger.newmap, trigger.new);
    }
    if(trigger.isUpdate && trigger.isafter){
        AOActivitiesTriggerHandler.UpdateEvent_AOactivities(trigger.newmap, trigger.oldmap);
    }
}