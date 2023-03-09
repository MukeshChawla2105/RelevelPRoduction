trigger EventTrigger on Event (before insert, after insert, before update, after Update) {
    
    if (trigger.isAfter && trigger.isInsert){
        
        // ================== To Fill Lead Interview Fields ================================
        EventTriggerHelper.UpdateLeadInterviewDetails(trigger.newMap);
    }
    if (trigger.isAfter && trigger.isUpdate){
        
        // ================== To Update Lead Interview Field ================================
        EventTriggerHelper.UpdateLeadRescheduleInterview(trigger.newMap, trigger.oldMap);
        EventTriggerHelper.UpdateLeadAfterFetchingRecordingDetails(trigger.newMap, trigger.oldMap);
    }

}