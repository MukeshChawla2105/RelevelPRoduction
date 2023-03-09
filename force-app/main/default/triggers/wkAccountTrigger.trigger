trigger wkAccountTrigger on Account (before insert, before update) {
    //Webkul Trigger for masking phone number
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        wkTriggerHandler.accountTriggerController(Trigger.new);
    }
}