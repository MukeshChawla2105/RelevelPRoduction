public class AssignCTILicenseHandler {
    @AuraEnabled
    public static list<user> fetchUsersWithoutCTILicense(){
        list<user> userlist =new list<user>();
        list<UserPackageLicense> userPackage = new list<UserPackageLicense>();
        set<string> userIdSet = new set<string>();
        map<string,string> mapofuserIdbyPackgeId = new map<string,string>();
        
        userPackage = [select id,PackageLicenseId,UserId from UserPackageLicense where PackageLicenseId =: system.label.CTI_PACKAGE_ID];
        if(!userPackage.isEmpty()){
            for(UserPackageLicense up : userPackage){
                userIdSet.add(up.UserId);
            }
            if(!userIdSet.isEmpty())
                userlist = [select id,isactive,userroleid,profile.name,Name from user where id NOT in:userIdSet and isactive = True ANd Profile.Name =: system.label.BDE_Profile_Name ];
        }
        return userlist;
    }
    @AuraEnabled
    public static void assignLicencesToUser(List<String> usersIdToAssignLicence){
        system.debug('usersIdToAssignLicence>>'+usersIdToAssignLicence);
        try{
            if(!usersIdToAssignLicence.isEmpty()){
                list<UserPackageLicense> userPackageTobeInsert = new List<UserPackageLicense>();
                for(String userid : usersIdToAssignLicence){
                    UserPackageLicense userPck = new UserPackageLicense();
                    userPck.PackageLicenseId = system.label.CTI_PACKAGE_ID;
                    userPck.UserId = userid;
                    userPackageTobeInsert.add(userPck);
                }
                if(!userPackageTobeInsert.isEmpty()){
                    insert userPackageTobeInsert;
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>'+ex.getLineNumber());
        }
    }
    @AuraEnabled
    public static integer reassignLicences(){
        integer noOfLicences = 0;
        try{
            set<string> userIdSet = new set<string>();
            list<user> userlist = new list<user>();
            list<UserPackageLicense > userPackage = new list<UserPackageLicense >();
            list<UserPackageLicense> userPackageTobeDeleted = new list<UserPackageLicense>();
            map<string,string> mapofuserIdbyPackgeId = new map<string,string>();
            
            
            String PackageId = [Select Id FROM PackageLicense Where NamespacePrefix = 'wk_exo'].Id;
            if(!String.isBlank(PackageId)){
                userPackage = [select id,PackageLicenseId,UserId from UserPackageLicense where PackageLicenseId =: PackageId];  
                if(!userPackage.isEmpty()){
                    for(UserPackageLicense up : userPackage){
                        userIdSet.add(up.UserId);
                        mapofuserIdbyPackgeId.put(up.UserId,up.Id);
                    } 
                    if(!userIdSet.isEmpty()){
                        userlist = [select id,isactive,userroleid,profile.name from user where id in:userIdSet and profile.name = 'BDA' and isactive = false and userroleid != null ];
                        if(!userlist.isEmpty()){
                            noOfLicences = userlist.size();
                            for(user us : userlist){
                                UserPackageLicense userPck = new UserPackageLicense();
                                userPck.PackageLicenseId = null;
                                userPck.UserId = us.Id;
                                userPck.Id = mapofuserIdbyPackgeId.get(us.Id);
                                userPackageTobeDeleted.add(userPck);
                            }
                            if(!userPackageTobeDeleted.isEmpty()){
                                delete userPackageTobeDeleted;
                            }
                        }
                    }
                }
            }
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>'+ex.getLineNumber());
        }
        return noOfLicences;
    }
}