public class AOAvailabilityTriggerHandler{
    
    Public static void UpdateLastEngagementTime(Map<Id, AO_Availability__c> newLeadMap, Map<Id, AO_Availability__c> oldLeadMap){
        try{
            system.debug('Updating engagement Time');
            
            if (!newLeadMap.isEmpty()){
                for (AO_Availability__c AO_Avail : newLeadMap.values()){
                    if (AO_Avail.Status__c != null && AO_Avail.Status__c == 'Available' && AO_Avail.Status__c != oldLeadMap.get(AO_Avail.id).Status__c && oldLeadMap.get(AO_Avail.id).Status__c == 'In Meeting'){
                        AO_Avail.Last_Engagement_Time__c = System.now();
                    }
                }
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    public static void insertLogsRecord(Map<Id, AO_Availability__c> newLeadMap, Map<Id, AO_Availability__c> oldLeadMap){
        try{
            List<AO_Availability_Log__c> AO_AvailabilityLogListToInsert = new List<AO_Availability_Log__c>();
            
            for(AO_Availability__c AO_Avail : newLeadMap.values()){
                if(AO_Avail.Status__c != oldLeadMap.get(AO_Avail.id).Status__c){
                    AO_Availability_Log__c AO_Avail_Rec = new AO_Availability_Log__c();
                    AO_Avail_Rec.AO_Availability__c = AO_Avail.Id;
                    if(AO_Avail.Status__c == 'On Break'){
                        AO_Avail_Rec.Break_Start_Time__c = system.now();
                    }
                    AO_Avail_Rec.Status__c = AO_Avail.Status__c;
                    AO_Avail_Rec.Status_Change_Date_Time__c	= system.now();
                    AO_AvailabilityLogListToInsert.add(AO_Avail_Rec);
                }
            }
            if(!AO_AvailabilityLogListToInsert.isEmpty()){
                insert AO_AvailabilityLogListToInsert;
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    Public static void updateBreakEndTime(Map<Id, AO_Availability__c> newLeadMap, Map<Id, AO_Availability__c> oldLeadMap){
        try{
            system.debug('Update End Time');
            List<AO_Availability_Log__c> AO_AvailabilityLogListToUpdate = new List<AO_Availability_Log__c>();
            List<AO_Availability__c> AO_Availability_List = new List<AO_Availability__c>();
            set<Id> AO_AvailabilityIds = new Set<Id>();
            
            if (!newLeadMap.isEmpty()){
                for (AO_Availability__c AO_Avail : newLeadMap.values()){
                    if (AO_Avail.Status__c != oldLeadMap.get(AO_Avail.id).Status__c && oldLeadMap.get(AO_Avail.id).Status__c == 'On Break'){
                        //AO_Avail.Break_End_Time__c = system.now();
                        AO_AvailabilityIds.add(AO_Avail.Id);
                    }
                }
                system.debug('AO_AvailabilityIds-->'+AO_AvailabilityIds);
                
                if (!AO_AvailabilityIds.isEmpty()){
                    AO_Availability_List = [Select Id,status__c,(select Id, Break_End_Time__c, status__c, AO_Availability__c
                                                                 from Availability_Logs__r
                                                                 where CreatedDate = Today ANd status__c = 'On Break'
                                                                 order by Break_Start_Time__c DESC
                                                                 limit 1) From AO_Availability__c where Id in : AO_AvailabilityIds];
                    
                    system.debug('AO_Availability_List' + AO_Availability_List);
                    if (!AO_Availability_List.isEmpty()){
                        for(AO_Availability__c AO_Avail_Rec : AO_Availability_List){
                            if(AO_Avail_Rec.Availability_Logs__r.size() > 0){
                                AO_Availability_Log__c AO_AvailabilityLogRec = new AO_Availability_Log__c();
                                if(AO_Avail_Rec.Availability_Logs__r[0] != null)
                                    AO_AvailabilityLogRec.Id = AO_Avail_Rec.Availability_Logs__r[0].Id;
                                AO_AvailabilityLogRec.status__c = AO_Avail_Rec.Availability_Logs__r[0].status__c;
                                AO_AvailabilityLogRec.Break_End_Time__c = system.now();
                                AO_AvailabilityLogListToUpdate.add(AO_AvailabilityLogRec);
                            }
                            
                        }
                        system.debug('AO_AvailabilityLogListToUpdate' + AO_AvailabilityLogListToUpdate);
                        if(!AO_AvailabilityLogListToUpdate.isEmpty()){
                            update AO_AvailabilityLogListToUpdate;                
                        }
                    }
                }
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    
    public static void updateEndBreakTimeToAoAvailability(List<AO_Availability__c> newAOAvailability,Map<Id,AO_Availability__c> oldAOAvailabilityMap){
        try{
            for(AO_Availability__c AO : newAOAvailability){
                if(AO.Status__c != oldAOAvailabilityMap.get(AO.id).Status__c && oldAOAvailabilityMap.get(AO.id).Status__c == 'On Break'){
                    AO.Break_End_Time__c = system.now();
                }
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    
    public static void makeAOUnavailableAfter9PM(List<AO_Availability__c> newAOAvailability,Map<Id,AO_Availability__c> oldMapAO){
        try{
            for(AO_Availability__c AO : newAOAvailability){
                //Time.newInstance(20, 59, 00, 00)
                if(System.now().time() > Time.newInstance(20, 59, 00, 00) && (AO.Status__c == 'Available' || AO.Status__c == 'In Meeting')){
                    AO.Status__c = 'Not Available';
                }
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
    public static void handleAOStatus(Map<Id, AO_Availability__c> newLeadMap, Map<Id, AO_Availability__c> oldLeadMap){
        try{
            
            List<Interview__c> intervierwsWithAO = new List<Interview__c>();
            Map<String,string> userIdByAOAvailabilityId = new Map<String, string>();
            
            
            for(AO_Availability__c AORec : newLeadMap.values()){
                if(AORec.Status__c == 'Available' && AORec.Status__c != oldLeadMap.get(AORec.Id).Status__c ){
                    userIdByAOAvailabilityId.put(AORec.Audited_Officer__c, AORec.Id);
                }
            }
            if(!userIdByAOAvailabilityId.isEmpty()){
                intervierwsWithAO = [Select Id,Active__c,Interviewer__c From Interview__c where Active__c = true and Created_Date__c = today and Interviewer__c in : userIdByAOAvailabilityId.keySet()];
                if(!intervierwsWithAO.isEmpty()){
                    for(Interview__c interviewRec : intervierwsWithAO){
                        if(userIdByAOAvailabilityId.containsKey(interviewRec.Interviewer__c)){
                            newLeadMap.get(userIdByAOAvailabilityId.get(interviewRec.Interviewer__c)).Status__c = oldLeadMap.get(userIdByAOAvailabilityId.get(interviewRec.Interviewer__c)).Status__c;
                        }
                    }
                }
            }
        }catch(exception ex){
            system.debug('Error -->'+ex.getMessage());
            system.debug('Error-->'+ex.getLineNumber());
        }
    }
}