trigger UserTrackingTrigger on User_Tracking__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        //UserTrackingTriggerHelper.LinkAOWithUserTracking(trigger.oldMap, trigger.newMap);
    }
}