public without sharing class SMAuditFormTriggerHandler {
    
    public static void updateLead(List<SM_Call_Audit_Form__c> SMAUditFormList){
        
        Set<Id> LeadIdList = new Set<Id>();
        Map<String, SM_Call_Audit_Form__c> MapOfLeadIdWithSMAUDitRec = new Map<String, SM_Call_Audit_Form__c>(); 
        list<Lead> LeadListTobeUpdated = new list<Lead>();
        List<Lead> FinalleadlistTobeUpdated = new List<Lead>();
        
        if(!SMAUditFormList.isEmpty()){
            for(SM_Call_Audit_Form__c SMAudit : SMAUditFormList){
                LeadIdList.add(SMAudit.Lead__c);
                MapOfLeadIdWithSMAUDitRec.put(SMAudit.Lead__c, SMAudit);
            }
        }
        if(!LeadIdList.isEmpty()){
            LeadListTobeUpdated = [Select id, SM_Audit_Score__c From Lead Where Id In: LeadIdList];
        }
        if(!LeadListTobeUpdated.isEmpty()){
            for(Lead ld : LeadListTobeUpdated){
                if(MapOfLeadIdWithSMAUDitRec.containsKey(ld.Id)){
                    ld.SM_Audit_Score__c = MapOfLeadIdWithSMAUDitRec.get(ld.Id).Final_Total_Score__c;
                    FinalleadlistTobeUpdated.add(ld);
                }
            }
        }
        if(!FinalleadlistTobeUpdated.isEmpty()){
            update FinalleadlistTobeUpdated;
        }
    }

}