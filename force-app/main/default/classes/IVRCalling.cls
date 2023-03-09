public class IVRCalling {
    
    public static void notifyLearnerForInterview(){
        list<String> leadIdList = New List<String>();
        DateTime thirtyFiveMins = System.now().addMinutes(35);
        String leadId = '';
        system.debug('thirtyFiveMin-->'+thirtyFiveMins);
        system.debug('System.now()-->'+System.now());
        List<Lead> leadListToNotify = [SELECT id,Name,Phone,Email,Interview_Date_Time_AC__c,IVR_Called__c,OwnerId FROM Lead WHERE Interview_Date_Time_AC__c <: thirtyFiveMins AND Interview_Date_Time_AC__c >: system.now() AND IVR_Called__c = false AND Phone != null limit 90];
        if(!leadListToNotify.isEmpty()){
            for(Lead leadRec : leadListToNotify){
                leadId = Callout_ExotelAutoCall.triggerExotelAutoCall(leadRec);
                if(leadId != ''){
                   leadIdList.add(leadId); 
                }
            }
            if(!leadIdList.isEmpty()){
                updateIvrStat(leadIdList);
            }
        }
    }
    @future(callout=true)
    public static void updateIvrStat(list<String> leadIds){
        system.debug('LeadIds -->'+leadIds);
        List<Lead> leadListToUpdate = new List<Lead>();
        
        if(!LeadIds.isEmpty()){
            for(String leadId : leadIds){
                Lead leadRecToUpdate = new Lead();
                leadRecToUpdate.Id = leadId;
                leadRecToUpdate.IVR_Called__c = true;
                leadListToUpdate.add(leadRecToUpdate);
            }
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }
    }
    
}