trigger InterviewTrigger on Interview__c (before insert,after insert,before update, after update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        InterviewTriggerHandler.CreateAndAssignTaskWithAOAssignment(trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        InterviewTriggerHandler.DeactivateInterview(Trigger.new,Trigger.Oldmap);
        InterviewTriggerHandler.createAOActivitiesLog(Trigger.new,Trigger.Oldmap);
        InterviewTriggerHandler.CreateNextMeetingLinkForSM(Trigger.newMap, Trigger.oldMap);
        
    }
    if (trigger.isAfter && trigger.isUpdate) {
        InterviewTriggerHandler.CreateAndAssignTaskWithAOAssignment(trigger.oldMap, Trigger.newMap); 
        InterviewTriggerHandler.updateIntervieStatusToBackend(trigger.newMap, Trigger.oldMap); 
        InterviewTriggerHandler.assignCounsellorLogic(trigger.new, Trigger.oldMap);
    }

    // if (trigger.isBefore && trigger.isUpdate) {
        
    // }
}