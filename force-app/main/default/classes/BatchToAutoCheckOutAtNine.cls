public class BatchToAutoCheckOutAtNine implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date todayDate = System.today();
        
        String query = 'SELECT id,Checkout_Datetime__c,Check_in_Date__c FROM User_Tracking__c WHERE Checkout_Datetime__c = null AND Checkin_Detatime__c != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<User_Tracking__c> userTrackingList){
        try{
            time everyDayNine = time.newInstance(21, 00, 00, 00);
            if(!userTrackingList.isEmpty()){
                for(User_Tracking__c userTrackingRec : userTrackingList){
                    userTrackingRec.Checkout_Datetime__c = DateTime.newInstance(userTrackingRec.Check_in_Date__c, everyDayNine);
                }
                update userTrackingList;
            }
        }
        catch(exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
            
        }
    }
    public void finish(Database.BatchableContext BC) {
    }  
}