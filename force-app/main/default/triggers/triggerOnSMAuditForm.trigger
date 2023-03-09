trigger triggerOnSMAuditForm on SM_Call_Audit_Form__c (after insert) {
    
    if(trigger.isafter && trigger.isInsert){
        SMAuditFormTriggerHandler.updateLead(trigger.new);
    }

}