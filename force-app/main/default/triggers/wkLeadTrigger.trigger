trigger wkLeadTrigger on Lead (before insert, before update) {
  if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        //Webkul Trigger for masking phone number
      if(!test.isRunningTest())
          wkTriggerHandler.leadTriggerController(Trigger.new);
    }
}