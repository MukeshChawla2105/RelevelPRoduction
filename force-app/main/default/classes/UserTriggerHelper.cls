public class UserTriggerHelper {
    public Static Void checkingManagerandTranferLead(Map<Id, User> oldMap, Map<Id, User> newMap){
        try{
            set<Id> deactivatedUsersId = new Set<Id>();
            
            for(User userRec : newMap.values()){
                if(userRec.isActive != oldMap.get(userRec.id).isActive && userRec.isActive == false ){
                    if(userRec.ManagerId == null){
                        system.debug('Error');
                        userRec.Id.addError('Please Tag Manager to TRANSFER LEADS');
                    }else{
                        system.debug('No Error');
                        deactivatedUsersId.add(userRec.ID);
                    }
                }
            }
            system.debug('deactivatedUsersId>>'+deactivatedUsersId);
            if(!deactivatedUsersId.isEmpty()){
                UpdateLeadOwner.changeLeadOwnerShip(deactivatedUsersId);
                UpdateLeadOwner.removeCTILicence(deactivatedUsersId);
                DeleteAssignmentGroupMember.deleteAGM(deactivatedUsersId);
                updateAuditOfficerRecords(deactivatedUsersId);
                updateAuditCounsellorRecords(deactivatedUsersId);
            }
        }catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
    
    public static void enbaleAOOnLogin(Id userId){
        
        
        if(userId != null){
            List<User_Tracking__c> userCheckout = New List<User_Tracking__c>();
            userCheckout =  [select id,Checkout_Datetime__c,Member__c from User_Tracking__c where Checkout_Datetime__c = null and Member__c =:userId and Createddate = today];
            if(userCheckout.size() > 0){
                List<AO_Availability__c> aoAvailabilityList = new List<AO_Availability__c>();
                aoAvailabilityList = [select id,status__c from AO_Availability__c where createddate = today and status__c = 'Not Available' and Audited_Officer__c =: userId];
                if(!aoAvailabilityList.isEmpty()){
                    for(AO_Availability__c ao : aoAvailabilityList){
                        ao.status__c = 'Available';
                    }
                    
                    update aoAvailabilityList;
                }
            }
            
        }
    }
    @future
    public static void updateAuditOfficerRecords(set<Id> deactivatedUsersId){
        delete[Select id,(Select Id from Audit_Counsellors__r) from Audit_Officer__c where AO__c in: deactivatedUsersId];
    }
    @future
    public static void updateAuditCounsellorRecords(set<Id> deactivatedUsersId){
       delete[select Id from Audit_Counsellor__c where User__c in:deactivatedUsersId ];
    }
}