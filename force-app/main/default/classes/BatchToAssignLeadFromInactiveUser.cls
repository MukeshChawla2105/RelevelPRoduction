public class BatchToAssignLeadFromInactiveUser implements Database.Batchable<sObject>{
    Set<Id> deactivatedUsersId;
    
    public BatchToAssignLeadFromInactiveUser(Set<Id> deactivatedIds) {
        this.deactivatedUsersId = deactivatedIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([Select Id,OwnerId From Lead Where OwnerId in : deactivatedUsersId]);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadsToBeReassignment){
        system.debug('leadsToBeReassignment-->'+leadsToBeReassignment.size());
        List<user> usersList = new List<User>();
        List<Lead> leadsToBeUpdated = new List<Lead>();
        Map<string, String> managerIdByUserId = new Map<String, String>();
        
        if(!leadsToBeReassignment.isEmpty()){
            usersList  = [SELECT Id,ManagerId FROM User where id in : deactivatedUsersId AND ManagerId != null];
            system.debug('usersList-->'+usersList);
            if(!usersList.isEmpty()){
                for(User userRecDeactivated : usersList){
                    managerIdByUserId.put(userRecDeactivated.Id, userRecDeactivated.ManagerId);
                }
            }
            for(Lead leadRec : leadsToBeReassignment){
                Lead leadRecToBeUpdated = new Lead();
                leadRecToBeUpdated.Id = leadRec.Id;
                if(managerIdByUserId.get(leadRec.OwnerId) != null)
                    leadRecToBeUpdated.OwnerId = managerIdByUserId.get(leadRec.OwnerId);
                leadsToBeUpdated.add(leadRecToBeUpdated);
            }
            if(!leadsToBeUpdated.isEmpty()){
                update leadsToBeUpdated;
            }
        }  
    }
    
    public void finish(Database.BatchableContext BC) {
    }
}