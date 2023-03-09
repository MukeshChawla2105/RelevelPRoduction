trigger wkContactTrigger on Contact (before insert, before update) {
	//Webkul Trigger for masking phone number
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        wkTriggerHandler.contactTriggerController(Trigger.new);
    }
}