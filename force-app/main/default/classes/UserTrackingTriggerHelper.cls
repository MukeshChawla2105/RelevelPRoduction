public class UserTrackingTriggerHelper {
    public static void LinkAOWithUserTracking(Map<Id,User_Tracking__c> oldMap, Map<Id,User_Tracking__c> newMap){
        try{
            set<Id> AOIDs = new Set<Id>();
            List<AO_Availability__c> AOAvailabilityList =  new List<AO_Availability__c>();
            List<AO_Availability__c> AOAvailabilityListToUpdate =  new List<AO_Availability__c>();
            Map<String,User_Tracking__c> userTrackingRecByUserId = new Map<String,User_Tracking__c>();
            
            for(User_Tracking__c userTrackingRec : newMap.values()){
                if(userTrackingRec.Member__c != null && userTrackingRec.Check_in_Date__c != null){
                    AOIDs.add(userTrackingRec.Member__c);
                    userTrackingRecByUserId.put(userTrackingRec.Member__c, userTrackingRec);
                }
            }
            if(!AOIDs.isEmpty()){
                AOAvailabilityList = [Select Id,User_Tracking__c,Audited_Officer__c From AO_Availability__c where Audited_Officer__c In : userTrackingRecByUserId.keySet() AND Created_Date__c = today];
                if(!AOAvailabilityList.isEmpty()){
                    for(AO_Availability__c AOAvailRec : AOAvailabilityList){
                        AO_Availability__c AOAvailRecToUpdate = new AO_Availability__c();
                        AOAvailRecToUpdate.Id = AOAvailRec.Id;
                        AOAvailRecToUpdate.User_Tracking__c = userTrackingRecByUserId.containsKey(AOAvailRec.Audited_Officer__c)?userTrackingRecByUserId.get(AOAvailRec.Audited_Officer__c).Id:null;
                        
                        AOAvailabilityListToUpdate.add(AOAvailRecToUpdate);
                    }
                    if(!AOAvailabilityListToUpdate.isEmpty()){
                        update AOAvailabilityListToUpdate;
                    }
                }
            }
        }catch(exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
}