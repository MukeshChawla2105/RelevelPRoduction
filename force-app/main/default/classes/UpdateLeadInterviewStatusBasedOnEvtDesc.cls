public class UpdateLeadInterviewStatusBasedOnEvtDesc {
    
    public static void GetEventDescriptionDetails( Map<String,String> evtMap, String leadId){
      try {
        Integer Relevelcount = 0;
        Integer GmailCount = 0;
        //integer
        List<Lead> LeadListToUpdate = new List<Lead>();
        Lead leadRec = [SELECT Id,Interview_Status_AO__c, Interview_Sub_Status_AO__c FROM Lead WHERE Id =:leadId ];
        
        
        for(String evt : evtMap.keySet()){
            String evtupdated = (evt != NULL ||  evt != 'NULL') ? evt : '';
            System.debug('evtupdated =====> ' + evtupdated); 
            if (evt != null) {
                if(evt.contains('@relevel.com') ){
                    Relevelcount ++;                
                } else if(evt.contains('@gmail.com') ){ 
                    GmailCount ++;         
                }
                else{
                    GmailCount ++;
                }
            }
            else{
                if(String.valueOf(evt) == 'null'){
                    GmailCount ++; 
                }
            }
            
        }
        if(GmailCount > 0 && Relevelcount > 0){
            leadRec.Interview_Status_AO__c = 'Conducted';
        }
        else{
            if(GmailCount == 0 && Relevelcount > 0){
                leadRec.Interview_Status_AO__c = 'No Conducted';
                leadRec.Interview_Sub_Status_AO__c = 'Learner - No Show';
            }else if(GmailCount > 0 && Relevelcount == 0){
                leadRec.Interview_Status_AO__c = 'No Conducted';
                leadRec.Interview_Status_AO__c = 'AO No Show';

            }
        }
        //else if(GmailCount > 0 && Relevelcount == 0 ){
        //    leadRec.Interview_Status_AO__c = 'AO No Show';
        //}

        update leadRec;
        
      } catch (Exception e) {
        System.debug('Error message :; ' + e.getMessage() + ' at line number :: ' + e.getLineNumber());
      }
        
    }
}