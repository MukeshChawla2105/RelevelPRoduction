trigger Leadtrigger on Lead(before insert, after insert, after update, before update ){
    
    if (System.Label.LeadTriggerHandler != 'false'){
        if (trigger.isInsert && Trigger.isBefore){
            LeadTriggerHandler.assignDefaultQueue(Trigger.new );
            //LeadTriggerHandler.runLeadAssignment(Trigger.new);
            //LeadTriggerHandler.assignRecordtypeBasedOnVersion(Trigger.new );
        }
        if (trigger.isInsert && Trigger.isAfter){
            LeadTriggerHandler.onInsert(Trigger.new);
           // LeadTriggerHandler.runLeadAssignment(Trigger.new);
        }
        
        if (trigger.isUpdate && Trigger.isAfter){
            system.debug('After Update');
            LeadTriggerHandler.insertFollowUpTask(trigger.newMap, trigger.oldMap);
           // LeadTriggerHandler.runLeadAssignmentOnOwnerUpdate(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.TargetAchievementUpdationCreation(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.updateInterviewStatus(trigger.new, trigger.oldMap, Trigger.newMap);
            LeadTriggerHandler.createBookLaterInterviewRec(trigger.new,trigger.oldMap);
            //LeadTriggerHandler.IVRCallVersionV1(trigger.newMap,trigger.oldMap);
            /*
if(RoundRobinLeadAssignmentForRM.handleAfterUpdate){
LeadTriggerHandler.insertFollowUpTask(trigger.newMap, trigger.oldMap);
LeadTriggerHandler.runLeadAssignmentOnOwnerUpdate(trigger.newMap, trigger.oldMap);
LeadTriggerHandler.TargetAchievementUpdationCreation(trigger.newMap, trigger.oldMap);
//LeadAssignmentExecutionCriteria.validateEntryCriteria(trigger.new);
RoundRobinLeadAssignmentForRM.handleAfterUpdate = false;
}
*/
        }
        if (trigger.isUpdate && Trigger.isBefore){
            //system.debug('Before Update');
            LeadTriggerHandler.handleInterviewFeedback(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.assignRecordtypeBasedOnVersion(trigger.newMap, trigger.oldMap );
            LeadTriggerHandler.updateFollowUpCount(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.updateStageAsClosure(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.updateFirstResponseTime(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.trackOwnerChangeDetails(trigger.newMap, trigger.oldMap);
            if (boolean.valueOf(system.label.HandleLeadStage))
                LeadTriggerHandler.handleStageChange(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.updateNewFlowLeadStage(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.beforeUpdate(trigger.newMap, trigger.oldMap);
            LeadTriggerHandler.handleV1leadStage(trigger.new, trigger.oldMap);
        }
    }
}