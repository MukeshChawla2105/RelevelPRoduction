global  class BatchForIVRAsync implements Database.Batchable<sObject> , Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime thirtyMins = System.now().addMinutes(25);
        DateTime thirtyFiveMins = System.now().addMinutes(35);
        
        String query = 'SELECT id,Name,Phone,Email,Interview_Date_Time_AC__c,IVR_Called__c,OwnerId FROM Lead WHERE Interview_Date_Time_AC__c >: thirtyMins AND Interview_Date_Time_AC__c <: thirtyFiveMins AND IVR_Called__c = false AND Phone != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        List<Lead> leadListToBeUpdated = new List<Lead>();
        
        for(Lead leadRec : leadList){
            HelperForIVRAsync.ExotelCallout(leadRec.Id);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    }  
    
}