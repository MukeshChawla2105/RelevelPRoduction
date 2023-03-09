trigger AssignementGroupMemberTrigger on Assignment_Group_Member__c (after delete) {
    if(System.Label.AssignmentDroupMemberTrigger != 'false'){
        if(trigger.isAfter && trigger.isDelete){
            AssignementGroupMemberTriggerHelper.reassignAssignmentAfterDeletion(trigger.old);
        }
    }
}