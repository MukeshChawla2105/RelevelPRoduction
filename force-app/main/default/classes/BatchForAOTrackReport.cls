public class BatchForAOTrackReport implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String QueryString = 'select id,Member__c,Check_in_Date__c from User_Tracking__c where Check_in_Date__c = today';
        return Database.getQueryLocator(QueryString);
    }
    public void execute(Database.BatchableContext bc, List<User_Tracking__c> urList){

        set<Id> AOIDs = new Set<Id>();
        List<AO_Availability__c> AOAvailabilityList =  new List<AO_Availability__c>();
        List<AO_Availability__c> AOAvailabilityListToUpdate =  new List<AO_Availability__c>();
        Map<String,User_Tracking__c> userTrackingRecByUserId = new Map<String,User_Tracking__c>();
        
        for(User_Tracking__c userTrackingRec : urList){
            if(userTrackingRec.Member__c != null && userTrackingRec.Check_in_Date__c != null){
                AOIDs.add(userTrackingRec.Member__c);
                userTrackingRecByUserId.put(userTrackingRec.Member__c, userTrackingRec);
            }
        }
        if(!AOIDs.isEmpty()){
            AOAvailabilityList = [Select Id,User_Tracking__c,Audited_Officer__c From AO_Availability__c where Audited_Officer__c In : userTrackingRecByUserId.keySet() AND Created_Date__c = today AND User_Tracking__c = null];
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
    }
    public void finish(Database.BatchableContext bc){
        
    }
}