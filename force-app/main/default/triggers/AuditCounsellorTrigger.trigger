trigger AuditCounsellorTrigger on Audit_Counsellor__c (after delete, after update) {
    if(trigger.isAfter && trigger.isDelete){
        AuditCounsellorTriggerHelper.updateSequence(trigger.old);
    }
    if(trigger.isAfter && trigger.IsUpdate){
        AuditCounsellorTriggerHelper.afterUpdate(trigger.oldMap, trigger.newMap);
    }
}