public class BatchToTransferLeadFromDeactivatedUser implements
Database.Batchable<sObject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String newQueryString = 'SELECT id, name, ownerId FROM Lead where isActive__c = false';
        return Database.getQueryLocator(newQueryString);
    }
    public void execute(Database.BatchableContext bc, List<Lead> LeadlistofDeactivatedUser){
        
        // ====================================== FETCHING LEAD ASSIGNED TO DEACTIVATED USERS ================================ 
        
        try{
            
            map<String, string> UserIdWithManagerID = new map<String, string>();
            map<String, user> UserIdWithUserdetails = new map<String, user>();
            Map<String, List<Lead>> ownerIdWithLeadList = new Map<String, List<Lead>>();
            
            for(Lead ld : LeadlistofDeactivatedUser){
                if(ownerIdWithLeadList.containsKey(ld.ownerId)){
                    //system.debug('inside If');
                    List<Lead> leadListForExistedUserinMap = ownerIdWithLeadList.get(ld.ownerId);
                    leadListForExistedUserinMap.add(ld);
                    ownerIdWithLeadList.put(ld.ownerId, leadListForExistedUserinMap);
                }else{
                    ownerIdWithLeadList.put(ld.ownerId,new List<Lead> { ld } );
                }
                system.debug('ownerIdWithLeadList :: ' + ownerIdWithLeadList);
            }
            system.debug(' owner Id With Lead List :: ' + ownerIdWithLeadList.keySet().size());        
            
            //============================ FETCHING DEACTIVATED USER HAVING LEAD ==========================================
            
            list<User> deactivatedUserListhavingLead = [SELECT AccountId,ManagerId, manager.isActive, Email,Id,IsActive,
                       				manager.managerId, manager.manager.isActive,
                       				manager.manager.managerID, manager.manager.manager.isActive,
                       				manager.manager.manager.managerID, manager.manager.manager.manager.isActive
                       				FROM User 
                                   	where Id in : ownerIdWithLeadList.keyset()];
            for(user userRec : deactivatedUserListhavingLead){
                system.debug('u.id :: ' + userRec.id);
                system.debug('manager Id  :; ' +userRec.ManagerId);
                if(userRec.ManagerId != null){
                    //UserIdWithManagerID.put(userRec.id, userRec.ManagerId);
                    UserIdWithUserdetails.put(userRec.id,userRec);
                }
            }
            system.debug('UserIdWithUserdetails :: ' + UserIdWithUserdetails);
            
            // ============================= UPDATING LEAD OWNER =========================================
            List<Lead> LeadListWithUpdatedOwner = new List<Lead>();
            
            for(string str :UserIdWithUserdetails.keySet()){
                for(lead ld : ownerIdWithLeadList.get(str)){
                    system.debug('ld owner :: ' + ld.OwnerId);
                    lead updatedLeadRec = new lead();
                    updatedLeadRec.Id = ld.Id;
                    if(UserIdWithUserdetails.get(ld.ownerId).ManagerId != null && UserIdWithUserdetails.get(ld.ownerId).Manager.isActive == true){
                        updatedLeadRec.OwnerId = UserIdWithUserdetails.get(ld.ownerId).ManagerId;
                    }
                    else if(UserIdWithUserdetails.get(ld.ownerId).ManagerId != null && UserIdWithUserdetails.get(ld.ownerId).Manager.isActive == false){
                        if(UserIdWithUserdetails.get(ld.ownerId).Manager.managerID != null && UserIdWithUserdetails.get(ld.ownerId).Manager.manager.isActive == true){
                            updatedLeadRec.OwnerId = UserIdWithUserdetails.get(ld.ownerId).Manager.managerID;
                        }
                        else if(UserIdWithUserdetails.get(ld.ownerId).Manager.managerID != null && UserIdWithUserdetails.get(ld.ownerId).Manager.manager.isActive == false){
                            if(UserIdWithUserdetails.get(ld.ownerId).manager.Manager.managerID != null && UserIdWithUserdetails.get(ld.ownerId).manager.Manager.manager.isActive == true){
                                updatedLeadRec.OwnerId = UserIdWithUserdetails.get(ld.ownerId).manager.Manager.managerID;
                            }
                            else if(UserIdWithUserdetails.get(ld.ownerId).manager.Manager.managerID != null && UserIdWithUserdetails.get(ld.ownerId).manager.Manager.manager.isActive == false){
                                if(UserIdWithUserdetails.get(ld.ownerId).manager.manager.Manager.managerID != null && UserIdWithUserdetails.get(ld.ownerId).manager.manager.Manager.manager.isActive == true){
                                    updatedLeadRec.OwnerId = UserIdWithUserdetails.get(ld.ownerId).manager.manager.Manager.managerID;
                                }
                            }
                        }
                    }
                    LeadListWithUpdatedOwner.add(updatedLeadRec);
                }
            }
            if(!LeadListWithUpdatedOwner.isEmpty()){
                system.debug('LeadListWithUpdatedOwner :: ' + LeadListWithUpdatedOwner);
                system.debug('LeadListWithUpdatedOwner --> ' + LeadListWithUpdatedOwner.size());
                update LeadListWithUpdatedOwner;
            }
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage() + ' at line Number :: ' + e.getLineNumber() + ' due to ' + e.getCause());
        } 
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
    }
    
}