public class DeleteAssignmentGroupMember {
    @future
    public static void deleteAGM(set<Id> deactivatedUsersId){
        try{
            List<Assignment_Group_Member__c> AGMList = new List<Assignment_Group_Member__c>();
            if(!deactivatedUsersId.isEmpty()){
                AGMList = [Select Id From Assignment_Group_Member__c Where Group_Member__c in : deactivatedUsersId];
                if(!AGMList.isEmpty()){
                    database.delete(AGMList);
                }
            }
        }
        catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
    
}