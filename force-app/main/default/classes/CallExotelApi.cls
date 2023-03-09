global class CallExotelApi implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        DateTime systemNow = System.now();
        DateTime thirtyFiveMins = System.now().addMinutes(35);
        
        String query = 'SELECT id,Name,Phone,Email,SID__c,Interview_Date_Time_AC__c,IVR_Called__c,OwnerId,Interview_Slot_Date_Time__c FROM Lead WHERE ((Interview_Date_Time_AC__c >: systemNow AND Interview_Date_Time_AC__c <: thirtyFiveMins) OR (Slot_DateTime__c >: systemNow AND Slot_DateTime__c <: thirtyFiveMins AND Lead_Version__c = \'V1\' AND Interview_Type__c	= \'Later\')) AND IVR_Called__c = false AND Phone != null limit 40000';
        List<Lead> LeadList =  Database.query(query);
        
        if(!LeadList.isEmpty()){
            System.enqueueJob(new AsyncHelperForIVR(LeadList,0,1));
        }
    }
}