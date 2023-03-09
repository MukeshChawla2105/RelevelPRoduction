public class AuditCounsellorTriggerHelper {
    public static void updateSequence(List<Audit_Counsellor__c> oldList){
        try{
            Set<Id> auditOfficerId = new Set<Id>();
            List<Audit_Counsellor__c> agmListToBeUpdated = new List<Audit_Counsellor__c>();
            List<Audit_Officer__c> assignmentGroup = new List<Audit_Officer__c>();
            
            if(!oldList.isEmpty()){
                for(Audit_Counsellor__c agmRec : oldList){
                    auditOfficerId.add(agmRec.Audit_Officer__c);
                }
                if(!auditOfficerId.isEmpty()){
                    assignmentGroup = [Select Id,(Select Id,Last_RRid__c,Audit_Officer__c From Audit_Counsellors__r order by Last_RRid__c ASC) From Audit_Officer__c where Id in: auditOfficerId];
                    if(!assignmentGroup.isEmpty()){
                        for(Audit_Officer__c assignmentGroupRec : assignmentGroup){
                            integer i = 1;
                            for(Audit_Counsellor__c agmRec : assignmentGroupRec.Audit_Counsellors__r){
                                Audit_Counsellor__c agmRecToBeUpdated = new Audit_Counsellor__c();
                                agmRecToBeUpdated.id = agmRec.Id;
                                agmRecToBeUpdated.Last_RRid__c = i;
                                agmListToBeUpdated.add(agmRecToBeUpdated);
                                i++;
                            }
                        }
                        if(!agmListToBeUpdated.isEmpty()){
                            update agmListToBeUpdated;
                        }
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Error-->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    
    public static void afterUpdate(Map<Id, Audit_Counsellor__c> oldMap, Map<Id, Audit_Counsellor__c> newMap){
        try
        {
            set<Id> AO_Ids = new Set<Id>();
            List<Audit_Officer__c> AO_List = new List<Audit_Officer__c>();
            List<Audit_Counsellor__c> AC_List_ToUpdate = new List<Audit_Counsellor__c>();
            
            for(Audit_Counsellor__c auditCounsellorRec : newMap.values()){
                if(auditCounsellorRec.Available__c == true && auditCounsellorRec.Available__c != oldMap.get(auditCounsellorRec.Id).Available__c && auditCounsellorRec.Last_RRid__c > 1){
                    AO_Ids.add(auditCounsellorRec.Audit_Officer__c);
                }
            }
            if(!AO_Ids.isEmpty()){
                AO_List = [Select Id,(Select id,Last_RRid__c,Available__c From Audit_Counsellors__r order by Available__c) From Audit_Officer__c where Id in : AO_Ids];
                if(!AO_List.isEmpty()){
                    for(Audit_Officer__c AO_Officer_Rec : AO_List){
                        integer i = 1;
                        integer j = AO_Officer_Rec.Audit_Counsellors__r.size();
                        for(Audit_Counsellor__c  AC_Rec : AO_Officer_Rec.Audit_Counsellors__r){
                            Audit_Counsellor__c AC_Rec_toUpdate = new Audit_Counsellor__c();
                            AC_Rec_toUpdate.Id = AC_Rec.Id;
                            if(AC_Rec.Available__c == true){
                                AC_Rec_toUpdate.Last_RRid__c = i;
                                i++;
                            }
                            else{
                                AC_Rec_toUpdate.Last_RRid__c = j;
                                j--;
                            }
                            AC_List_ToUpdate.add(AC_Rec_toUpdate);
                        }
                    }
                    if(!AC_List_ToUpdate.isEmpty()){
                        update AC_List_ToUpdate;
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Error-->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
}