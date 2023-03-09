trigger TaskTrigger on Task (before update, after update, after insert, before Insert){

    if (System.Label.TaskTriggerHandler != 'false'){
        if (trigger.isBefore && trigger.isUpdate){
            System.debug('Before Update');
            TaskTriggerHelper.updateCallOnLead(trigger.newMap, trigger.oldMap);
            TaskTriggerHelper.handleStageChange(trigger.newMap, trigger.oldMap);
            TaskTriggerHelper.updateCallOnReMarketingLead(trigger.newMap, trigger.oldMap);
        }
        if (trigger.isBefore && trigger.isInsert){
            System.debug('Before Insert');
            TaskTriggerHelper.updateActivityDateTime(trigger.new );
            // TaskTriggerHelper.TaskOnLead(trigger.new);
        }
        if (trigger.isAfter && trigger.isUpdate){
            //Update stage as nurturing or called based on call type
            TaskTriggerHelper.updateLeadStage(trigger.newMap);
            //TaskTriggerHelper.updatePrePostInterviewCallDetail(trigger.oldmap, trigger.newMap);

        }
        if (trigger.isAfter && (trigger.isInsert)){
            //payment Activity
            TaskTriggerHelper.updateLeadStatus(trigger.newMap);
            //update last Activity/Payment Failed/Abandoned cart//login detail
            TaskTriggerHelper.updateLeadDetails(trigger.newMap);
            //Update Login and singup details and first activity date time
            TaskTriggerHelper.updateLeadSingUpDetails(trigger.newMap);
            TaskTriggerHelper.markAsRemarketingActivity(trigger.newMap);
            // ############################ lead Re-engagementActivity Time ######################
            TaskTriggerHelper.updateReEngagementActivityTime(trigger.new );
            //Application Form Activity
            TaskTriggerHelper.updateFromstatusOnLead(trigger.new );
        }
    }
}