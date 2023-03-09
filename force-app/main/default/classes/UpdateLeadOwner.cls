public class UpdateLeadOwner {
    public static void changeLeadOwnerShip(Set<Id> deactivatedUsersId){
        try{
            BatchToAssignLeadFromInactiveUser batchInstance = new BatchToAssignLeadFromInactiveUser(deactivatedUsersId); 
            database.executeBatch(batchInstance,200);  
            /*List<user> usersList = new List<User>();
            List<Lead> leadsToBeReassignment = new List<Lead>();
            List<Lead> leadsToBeUpdated = new List<Lead>();
            Map<string, String> managerIdByUserId = new Map<String, String>();
            
            if(!deactivatedUsersId.isEmpty()){
                usersList  = [SELECT Id,ManagerId FROM User where id in : deactivatedUsersId AND ManagerId != null];
                if(!usersList.isEmpty()){
                    for(User userRecDeactivated : usersList){
                        managerIdByUserId.put(userRecDeactivated.Id, userRecDeactivated.ManagerId);
                    }
                }
                system.debug('deactivatedUsersId>>'+deactivatedUsersId);
                leadsToBeReassignment = [Select Id,OwnerId From Lead Where OwnerId in : deactivatedUsersId];
                system.debug('leadsToBeReassignment>>'+leadsToBeReassignment);
                if(!leadsToBeReassignment.isEmpty()){
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
            }*/
        }
        catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
    @future
    public static void removeCTILicence(Set<Id> deactivatedUsersId){
        list<UserPackageLicense> userPackageTobeInsert = new list<UserPackageLicense>();
        map<string,string> mapofuserIdbyPackgeId = new map<string,string>();
        list<UserPackageLicense> userPackage = new List<UserPackageLicense>();
        set<string> userIdSet = new set<string>();
        list<user> userlist = new list<user>();
        
        userPackage = [select id,PackageLicenseId,UserId from UserPackageLicense where PackageLicenseId =: system.label.CTI_PACKAGE_ID AND UserId in: deactivatedUsersId];
        if(!userPackage.isEmpty()){
            for(UserPackageLicense up : userPackage){
                userIdSet.add(up.UserId);
                mapofuserIdbyPackgeId.put(up.UserId,up.Id);
            } 
            if(!userIdSet.isEmpty()){
                userlist = [select id,isactive,userroleid,profile.name from user where id in:userIdSet and profile.name = 'BDA' and isactive = false and userroleid != null];
                if(!userlist.isEmpty()){
                    for(user us : userlist){
                        UserPackageLicense userPck = new UserPackageLicense();
                        userPck.PackageLicenseId = null;
                        userPck.UserId = us.Id;
                        userPck.Id = mapofuserIdbyPackgeId.get(us.Id);
                        userPackageTobeInsert.add(userPck);
                    }
                    system.debug('userPackageTobeInsert>>'+userPackageTobeInsert);
                    if(!userPackageTobeInsert.isEmpty()){
                        delete userPackageTobeInsert;
                    } 
                }
            }
        }
    }
}