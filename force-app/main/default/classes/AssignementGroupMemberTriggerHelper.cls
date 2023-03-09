public class AssignementGroupMemberTriggerHelper {
    public static void reassignAssignmentAfterDeletion(List<Assignment_Group_Member__c> oldList){
        try{
            system.debug('oldList::'+oldList);
            Set<Id> assignmentGroupId = new Set<Id>();
            List<Assignment_Group_Member__c> agmListToBeUpdated = new List<Assignment_Group_Member__c>();
            List<Assignment_Group__c> assignmentGroup = new List<Assignment_Group__c>();
            
            if(!oldList.isEmpty()){
                for(Assignment_Group_Member__c agmRec : oldList){
                    assignmentGroupId.add(agmRec.Assignment_Group__c);
                }
                if(!assignmentGroupId.isEmpty()){
                    assignmentGroup = [Select Id,(Select Id,Assignment_Id__c,Assignment_Group__c From Assignment_Group_Members__r) From Assignment_Group__c where Id in: assignmentGroupId];
                    if(!assignmentGroup.isEmpty()){
                        for(Assignment_Group__c assignmentGroupRec : assignmentGroup){
                            integer i = 1;
                            for(Assignment_Group_Member__c agmRec : assignmentGroupRec.Assignment_Group_Members__r){
                                Assignment_Group_Member__c agmRecToBeUpdated = new Assignment_Group_Member__c();
                                agmRecToBeUpdated.id = agmRec.Id;
                                agmRecToBeUpdated.Assignment_Id__c = i;
                                agmListToBeUpdated.add(agmRecToBeUpdated);
                                i++;
                            }
                        }
                        if(!agmListToBeUpdated.isEmpty()){
                            update agmListToBeUpdated;
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
}