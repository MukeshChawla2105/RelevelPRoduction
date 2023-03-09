trigger UserTrigger on User (before update, after update) {
    if(System.Label.UserTriggerHandler != 'false'){
        if(trigger.isbefore && trigger.isUpdate){
            UserTriggerHelper.checkingManagerandTranferLead(trigger.oldMap, trigger.newMap);
        }
    }
}