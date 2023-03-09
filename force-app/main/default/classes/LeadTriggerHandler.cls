public without sharing class LeadTriggerHandler{
    public static Boolean runOnce = false;
    public static Id oldFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Old Flow').getRecordTypeId();
    public static Id newFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('New Flow').getRecordTypeId();
    
    public static void onInsert(List<Lead> leadList){
        set<id> leadIds = new Set<Id>();
        
        if(!leadList.isEmpty()){
            for(Lead leadRec : leadList){
                leadIds.add(leadRec.Id);
            }
            if(!leadIds.isEmpty()){
                splitTransactionOnInsert(leadIds);
            }
        }
    }
    @future(callout=true)
    public static void splitTransactionOnInsert(set<Id> leadIds){
        Id oldFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Old Flow').getRecordTypeId();
        Id newFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('New Flow').getRecordTypeId();
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                          limit 1].Id;
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListToUpdate = new List<Lead>();
        List<Lead> existingLeadLists = new List<Lead>();
        Map<String, Lead> leadIdByLearnerUID = new Map<String, Lead>();
        Map<String, string> ownerIdByLearnerUID = new Map<String, String>();
        
        leadList = [Select Id,Lead_Version__c,Referred_User_ID__c,recordTypeId,LeadSource From Lead Where Id in : leadIds];
        if(!leadList.isEmpty()){
            for(Lead ld : leadList){
                if (ld.LeadSource == 'Referral' && ld.Referred_User_ID__c != null){
                    leadIdByLearnerUID.put(ld.Referred_User_ID__c, ld);
                }
            }
            if (!leadIdByLearnerUID.isEmpty()){
                existingLeadLists = [Select id, Learner_UID__C, Ownerid
                                     from Lead
                                     where Learner_UID__C in:leadIdByLearnerUID.keySet()];
                system.debug('existingLeadLists::' + existingLeadLists);
                if (!existingLeadLists.isEmpty()){
                    for (Lead leadRec : existingLeadLists){
                        ownerIdByLearnerUID.put(leadRec.Learner_Uid__c, leadRec.OwnerId);
                    }
                }
            }
            for (Lead ld : leadList){
                /*    if (ld.Lead_Version__c != null && ld.Lead_Version__c == 'V0'){
ld.recordTypeId = oldFlowRecTypeId;
} else if (ld.Lead_Version__c != null && ld.Lead_Version__c == 'V1'){
ld.recordTypeId = newFlowRecTypeId;
}
if (ld.LeadSource != null && ld.LeadSource == 'Referral'){
ld.recordTypeId = oldFlowRecTypeId;
ld.Lead_Version__c = 'V0';
}*/
                if (ld.LeadSource == 'Referral' && ld.Referred_User_ID__c != null){
                    ld.ownerId = ownerIdByLearnerUID.get(ld.Referred_User_ID__c);
                }else{
                    ld.ownerId = queueId;
                }
            }
            update leadList;
        }  
    }
    public static void assignRecordtypeBasedOnVersion(Map<Id,Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        // Id oldFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Old Flow').getRecordTypeId();
        //Id newFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('New Flow').getRecordTypeId();
        
        for (Lead ld : newLeadMap.values()){
            /*  if (ld.Lead_Version__c != null && ld.Lead_Version__c == 'V0'){
ld.recordTypeId = oldFlowRecTypeId;
} else if (ld.Lead_Version__c != null && ld.Lead_Version__c == 'V1'){
ld.recordTypeId = newFlowRecTypeId;
}

if (ld.LeadSource != null && ld.LeadSource == 'Referral'){
ld.recordTypeId = oldFlowRecTypeId;
ld.Lead_Version__c = 'V0';
}*/
            if(ld.AO_Interview_Status_Manual__c != oldLeadMap.get(ld.Id).AO_Interview_Status_Manual__c && ld.AO_Interview_Status_Manual__c == 'AO No-Show'){
                ld.OwnerId = Constant.noShowQueueId;
            }
        }
    }
    
    public static void createBookLaterInterviewRec(List<Lead> leadList, map<Id, Lead> oldLeadMap){
        List<Interview__c> inRecTobeInsert = new List<Interview__c>();
        for (Lead ld : leadList){
            if ((ld.Book_Later_Flow__c && ld.Interview_Id__c != null && oldLeadMap.get(ld.Id).Book_Later_Flow__c != ld.Book_Later_Flow__c) || (ld.Book_Later_Flow__c && ld.Interview_Id__c != null && oldLeadMap.get(ld.Id).Interview_Id__c != ld.Interview_Id__c)){
                Interview__c inRec = new Interview__c();
                inRec.Relevel_Interview_Id__c = ld.Interview_Id__c;
                inRec.Lead__c = ld.Id;
                inRec.Active__c = true;
                inRecTobeInsert.add(inRec);
            }
        }
        
        if (!inRecTobeInsert.isEmpty()){
            insert inRecTobeInsert;
        }
    }
    
    public static void assignDefaultQueue(list<lead> newLeadList){
        try{
            List<Lead> existingLeadLists = new List<Lead>();
            Map<String, Lead> leadIdByLearnerUID = new Map<String, Lead>();
            Map<String, string> ownerIdByLearnerUID = new Map<String, String>();
            //List<String> leadEmail = new List<String>();
            List<String> leadPhone = new List<String>();
            Map<Id, Lead> existingLeadListWithEmailOrPhone = new Map<Id, Lead>();
            Map<String, String> leadEmailByLeadIdMap = new Map<String, String>();
            Map<String, String> leadPhoneByLeadIdMap = new Map<String, String>();
            Map<String, String> leadLearnerUIDByLeadIdMap = new Map<String, String>();
            newFlowRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('New Flow').getRecordTypeId();
            string queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                              limit 1].Id;
            for (Lead ld : newLeadList){
                ld.recordTypeId = newFlowRecTypeId;
                ld.Lead_Version__c = 'V1';
                ld.First_Activity_Date__c = system.today();
            }
            if (leadPhone != null){
                existingLeadListWithEmailOrPhone = new Map<Id, Lead>([Select Id, Email, Phone, Learner_Uid__c
                                                                      From Lead
                                                                      Where Phone in:leadPhone]);
                
                if (!existingLeadListWithEmailOrPhone.isEmpty()){
                    for (Lead ld : existingLeadListWithEmailOrPhone.values()){
                        if (ld.Email != null)
                            leadEmailByLeadIdMap.put(ld.Email, Ld.Id);
                        if (ld.Phone != null)
                            leadPhoneByLeadIdMap.put(ld.phone, ld.Id);
                        if (ld.Learner_Uid__c != null)
                            leadLearnerUIDByLeadIdMap.put(ld.Learner_Uid__c, ld.Id);
                    }
                }
            }
            for (Lead leadRec : newLeadList){
                if (leadEmailByLeadIdMap.containsKey(leadRec.email) || leadPhoneByLeadIdMap.containsKey(leadRec.Phone) || leadLearnerUIDByLeadIdMap.containsKey(leadRec.Learner_Uid__c)){
                    leadRec.addError('Potential Duplicate Found');
                }
            }
            
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void runLeadAssignment(List<Lead> leadList){
        try{
            /* if (!leadList.isEmpty() && leadList[0].Goal_Interested_In__c != null){
RoundRobinLeadAssignment.assignLeadsToBDS(leadList[0].Goal_Interested_In__c);
}*/
            if (!leadList.isEmpty() && leadList[0].Category__c != null){
                RoundRobinLeadAssignment.assignLeadsToBDS(leadList[0].Category__c);
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void assignDefaultQueueBeforeReassign(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            list<lead> reassignmentleadList = new list<lead>();
            for (Lead leadRec : newLeadMap.values()){
                if (leadRec.Goal_Interested_In__c != oldLeadMap.get(leadRec.Id).Goal_Interested_In__c){
                    reassignmentleadList.add(leadRec);
                }
            }
            if (!reassignmentleadList.isEmpty()){
                string queueId = [SELECT Id, Type
                                  FROM Group
                                  WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                                  limit 1].Id;
                for (Lead ld : reassignmentleadList){
                    ld.ownerId = queueId;
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void runLeadAssignmentOnOwnerUpdate(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            boolean rerunLeadassignment = false;
            string courseIntrested = '';
            for (Lead leadRec : newLeadMap.values()){
                if (leadRec.Category__c != oldLeadMap.get(leadRec.Id).Category__c){
                    rerunLeadassignment = true;
                    courseIntrested = leadRec.Category__c;
                    break;
                    
                }
            }
            if (rerunLeadassignment){
                RoundRobinLeadAssignment.assignLeadsToBDS(courseIntrested);
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void insertFollowUpTask(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();
        List<Task> taskListForNextFollowUp = new List<Task>();
        
        try{
            for (Lead lead : newLeadMap.values()){
                //System.debug(lead.Follow_Up_Date__c);
                //System.debug(oldLeadMap);
                if (lead.Follow_Up_Date__c != null && lead.Follow_Up_Date__c != oldLeadMap.get(lead.Id).Follow_Up_Date__c){
                    Task taskrec = new Task();
                    taskrec.Activity_Type__c = system.label.FollowUpTaskActivityType;
                    taskrec.status = 'Open';
                    taskrec.Subject = 'Follow-up ' + lead.Follow_Up_Date__c.format();
                    taskrec.OwnerId = lead.OwnerId;
                    taskrec.WhoId = lead.Id;
                    //taskrec.ActivityDate = lead.Follow_Up_Date__c;
                    taskrec.Follow_Up_Activity_Datetime__c = lead.Follow_Up_Date__c;
                    taskrec.Priority = 'Normal';
                    taskrec.Activity_Date_Time__c = dateTime.now();
                    taskList.add(taskrec);
                    
                }
                if (lead.Next_Followup_Date_Time__c != null && lead.Next_Followup_Date_Time__c != oldLeadMap.get(lead.Id).Next_Followup_Date_Time__c){
                    Task taskrec = new Task();
                    //taskrec.Activity_Type__c = system.label.FollowUpTaskActivityType;
                    taskrec.status = 'Open';
                    taskrec.Subject = 'Interview Scheduled ' + lead.Next_Followup_Date_Time__c.format();
                    taskrec.OwnerId = lead.OwnerId;
                    taskrec.WhoId = lead.Id;
                    taskrec.IsReminderSet = true;
                    taskrec.ReminderDateTime = lead.Next_Followup_Date_Time__c.addhours(-1);
                    //taskrec.ActivityDate = lead.Follow_Up_Date__c;
                    taskrec.Next_FollowUp_Activity_date_Time__c = lead.Next_Followup_Date_Time__c;
                    taskrec.Priority = 'Normal';
                    taskrec.Activity_Date_Time__c = dateTime.now();
                    
                    taskListForNextFollowUp.add(taskrec);
                    
                }
            }
            if (!taskList.isEmpty()){
                insert taskList;
            }
            if (!taskListForNextFollowUp.isEmpty()){
                insert taskListForNextFollowUp;
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateFollowUpCount(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            set<id> leadId = new Set<Id>();
            List<Task> followUpTaskList = new List<Task>();
            Map<String, integer> taskCountByLeadId = new Map<String, integer>();
            
            for (Lead lead : newLeadMap.values()){
                if (lead.Follow_Up_Date__c != oldLeadMap.get(lead.Id).Follow_Up_Date__c && lead.Follow_Up_Date__c != null){
                    leadId.add(lead.Id);
                    lead.Follow_Up_Counter__c += 1;
                }
                if (lead.Offer_Status__c != oldLeadMap.get(lead.Id).Offer_Status__c && lead.Offer_Status__c == 'Yes'){
                    if (!lead.Is_Interview_Conducted__c)
                        lead.Is_Interview_Conducted__c = true;
                    Date myDate = system.today().addDays(1);
                    Time myTime = Time.newInstance(10, 00, 00, 00);
                    DateTime dt = DateTime.newInstance(myDate, myTime);
                    lead.Admission_Letter_Send_Date_Time__c = dt;
                    lead.Admission_Letter_Expiry_Date__c = DateTime.now().addDays(3);
                }
                if (lead.Offer_Status__c != oldLeadMap.get(lead.Id).Offer_Status__c && lead.Offer_Status__c == 'No'){
                    if (!lead.Is_Interview_Conducted__c)
                        lead.Is_Interview_Conducted__c = true;
                    lead.Admission_Letter_Send_Date_Time__c = null;
                    lead.Admission_Letter_Expiry_Date__c = null;
                }
            }
            if (!leadId.isEmpty()){
                followUpTaskList = [SELECT WhoId, Status, Follow_Up_Activity_Datetime__c
                                    FROM Task
                                    WHERE (Status = 'Open') AND Follow_Up_Activity_Datetime__c != null AND WhoId in:leadId];
                if (!followUpTaskList.isEmpty()){
                    for (Task taskRec : followUpTaskList){
                        if (taskCountByLeadId.containsKey(taskRec.WhoId)){
                            integer noOfFollowUpTask = taskCountByLeadId.get(taskRec.WhoId) + 1;
                            taskCountByLeadId.put(taskRec.WhoId, noOfFollowUpTask);
                        } else{
                            taskCountByLeadId.put(taskRec.WhoId, 1);
                        }
                    }
                    if (!taskCountByLeadId.isEmpty()){
                        for (Id leadRecId : leadId){
                            if (taskCountByLeadId.containsKey(leadRecId)){
                                if (taskCountByLeadId.get(leadRecId) != null && taskCountByLeadId.get(leadRecId) > 0){
                                    (newLeadMap.get(leadRecId).Id).addError('Please Close Opened Followup Task, to create a new Followup');
                                }
                            }
                        }
                    }
                }
            }
            
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateStageAsClosure(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        set<Id> leadIdsForClosedWon = new Set<Id>();
        set<Id> leadIdsForClosedLost = new Set<Id>();
        set<Id> leadIdsToShowError = new Set<Id>();
        List<Lead> leadToShowError = new List<Lead>();
        List<Task> taskListToBeCompletedManually = new List<Task>();
        List<Task> taskListToBeCompletedAutomatically = new List<Task>();
        //system.debug('Payment Activity');
        try{
            for (Lead lead : newLeadMap.values()){
                if (lead.Lead_status__c != oldLeadMap.get(lead.Id).Lead_status__c){
                    // system.debug('lead.Lead_status__c------------------>'+lead.Lead_status__c);
                    if ((lead.Lead_status__c == 'Refund' || lead.Lead_status__c == 'Junk' || lead.Lead_status__c == 'Rejected' || lead.Lead_status__c == 'Not interested' || lead.Lead_status__c == 'No access to desktop/laptop' || lead.Lead_status__c == 'Cannot understand English' || lead.Lead_status__c == 'Just Checking Details' || lead.Lead_status__c == 'Joined/Will join competitor' || lead.Lead_status__c == 'Fee is High' || lead.Lead_status__c == 'Next Batch' || lead.Lead_status__c == 'Professionally Busy' || lead.Lead_status__c == 'Personal Reason' || lead.Lead_status__c == 'Travelling Abroad / Onsite' || lead.Lead_status__c == 'Looking for another Program' || lead.Lead_status__c == 'Enrolled for another Program with us' || lead.Lead_status__c == 'Did not Enquire' || lead.Lead_status__c == 'Looking for WFH jobs' || lead.Lead_status__c == 'Do not have laptop/desktop' || lead.Lead_status__c == 'Can not understand English' || lead.Lead_status__c == 'Can not pay 1st EMI as well' || lead.Lead_status__c == 'Loan Rejected' || lead.Lead_status__c == 'Work Experience' || lead.Lead_status__c == 'Age Bar' || lead.Lead_status__c == 'Poor Communication' || lead.Lead_status__c == 'Not a Graduate' || lead.Lead_status__c == 'Score is low')){
                        
                        leadIdsForClosedLost.add(lead.Id);
                        lead.Lead_Stage__c = 'Closed Lost';
                        lead.Closed_Lost_Date_Time__c = system.now();
                    }
                    if (lead.Lead_status__c == 'Payment Made'){
                        lead.Lead_Stage__c = 'Closed Won';
                        leadIdsForClosedWon.add(lead.Id);
                    }
                }
            }
            
            if (!leadIdsForClosedLost.isEmpty()){
                taskListToBeCompletedManually = [SELECT Id, Status, WhoId
                                                 FROM Task
                                                 WHERE WhoId in:leadIdsForClosedLost AND Status = 'Open'];
                if (!taskListToBeCompletedManually.isEmpty()){
                    for (Task taskRec : taskListToBeCompletedManually){
                        leadIdsToShowError.add(taskRec.WhoId);
                    }
                    if (!leadIdsToShowError.isEmpty()){
                        leadToShowError = [Select id, Name
                                           from Lead
                                           Where Id in:leadIdsToShowError];
                        if (!leadIdsToShowError.isEmpty()){
                            for (Lead leadRec : leadToShowError){
                                newLeadMap.get(leadRec.Id).addError('Please Complete All Pending Tasks');
                                //leadRec.addError('Please Complete All Pending Tasks');
                            }
                        }
                    }
                    
                }
            }
            //system.debug('leadIdsForClosedWon::'+leadIdsForClosedWon);
            if (!leadIdsForClosedWon.isEmpty()){
                // system.debug('Task List');
                taskListToBeCompletedAutomatically = [SELECT Id, Status
                                                      FROM Task
                                                      WHERE WhoId in:leadIdsForClosedWon];
                if (!taskListToBeCompletedAutomatically.isEmpty()){
                    for (Task taskrec : taskListToBeCompletedAutomatically){
                        taskRec.Status = 'Completed';
                    }
                    update taskListToBeCompletedAutomatically;
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateFirstResponseTime(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            for (Lead lead : newLeadMap.values()){
                if (lead.First_Called_Date_Time__c != oldLeadMap.get(lead.Id).First_Called_Date_Time__c){
                    if (lead.First_Called_Date_Time__c != null)
                        lead.First_Response_Time__c = decimal.valueof((lead.First_Called_Date_Time__c.getTime() - lead.CreatedDate.getTime()) / (60000));
                    //DateTime dt = DateTime.newInstance(myDate, myTime);
                    if (lead.New_Lead_Assigned_DateTime__c != null && lead.First_Called_Date_Time__c != null)
                        lead.FRT_Based_on_Assigned_Date_Called__c = decimal.valueof((lead.First_Called_Date_Time__c.getTime() - (lead.New_Lead_Assigned_DateTime__c).getTime()) / (60000));
                }
                //
                if (lead.First_Connected_Date_Time__c != oldLeadMap.get(lead.Id).First_Connected_Date_Time__c){
                    if (lead.First_Connected_Date_Time__c != null)
                        lead.FRT_Based_on_Created_Date_Connected__c = decimal.valueof((lead.First_Connected_Date_Time__c.getTime() - lead.CreatedDate.getTime()) / (60000));
                    //FRT_Based_on_Assigned_Date_Connected__c
                    if (lead.First_Connected_Date_Time__c != null && lead.New_Lead_Assigned_DateTime__c != null)
                        lead.FRT_Based_on_Assigned_Date_Connected__c = decimal.valueof((lead.First_Connected_Date_Time__c.getTime() - (lead.New_Lead_Assigned_DateTime__c).getTime()) / (60000));
                }
                if (oldLeadMap.get(lead.Id).Re_Engagement_Activity_Time__c != lead.Re_Engagement_Activity_Time__c){
                    if (lead.Re_Engagement_Activity_Time__c != null && lead.Closed_Lost_Date_Time__c != null)
                        lead.Re_Engagement_Time__c = decimal.valueof((lead.Re_Engagement_Activity_Time__c.getTime() - lead.Closed_Lost_Date_Time__c.getTime()) / (60000));
                }
                if (lead.First_Connected_Date_Time_RM__c != oldLeadMap.get(lead.Id).First_Connected_Date_Time_RM__c){
                    if (lead.First_Connected_Date_Time_RM__c != null)
                        lead.FRT_Based_on_RM_Connected_Date_Time__c = decimal.valueof((lead.First_Connected_Date_Time_RM__c.getTime() - lead.RM_assigned_Date_Time__c.getTime()) / (60000));
                }
                if (lead.First_Called_Date_Time_RM__c != oldLeadMap.get(lead.Id).First_Called_Date_Time_RM__c){
                    if (lead.First_Called_Date_Time_RM__c != null)
                        lead.FRT_Based_on_RM_Called_Date_Time__c = decimal.valueof((lead.First_Called_Date_Time_RM__c.getTime() - lead.RM_assigned_Date_Time__c.getTime()) / (60000));
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void trackOwnerChangeDetails(map<Id, Lead> newLeadMap, map<Id, Lead> oldLeadMap){
        //system.debug('newMap::'+newLeadMap);
        //system.debug('oldMap::'+oldLeadMap);
        try{
            Map<Id, Lead> leadByIdMap = new Map<ID, Lead>();
            Set<String> reciepientsId = new Set<String>();
            
            string queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                              limit 1].Id;
            for (lead ld : newLeadMap.values()){
                if (ld.ownerID != oldLeadMap.get(ld.Id).ownerId){
                    if (oldLeadMap.get(ld.Id).ownerId != queueId && oldLeadMap.get(ld.Id).ownerId != Constant.noShowQueueId){
                        
                        ld.Previous_Owner__c = oldLeadMap.get(ld.Id).ownerId;
                        ld.Transferred_By__c = UserInfo.getName();
                    }
                    ld.Owner_Change_Datetime__c = DateTime.now();
                }
                if (ld.lead_stage__c == 'Unassigned' && ld.ownerID != queueId && ld.recordtypeId == Constant.IdLeadOldFlowRT){
                    ld.lead_stage__c = 'New';
                }
                if (ld.ownerId != oldLeadMap.get(ld.Id).ownerId){
                    reciepientsId.add(ld.ownerId);
                    leadByIdMap.put(ld.Id, ld);
                    if (oldLeadMap.get(ld.Id).ownerId == queueId){
                        ld.New_Lead_Assigned_DateTime__c = datetime.now();
                    }
                    if (oldLeadMap.get(ld.Id).ownerId != queueId && ld.OwnerId != queueId){
                        ld.Reassign_Date_Time__c = datetime.now();
                    }
                    
                    
                }
            }
            if (!reciepientsId.isEmpty() && !leadByIdMap.isEmpty()){
                CustomNotification.notifyUsers(reciepientsId, leadByIdMap, 'New Lead Assigned', 'New Lead Has Been Assigned to you ');
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void handleStageChange(map<Id, Lead> newLeadMap, map<Id, Lead> oldLeadMap){
        //system.debug('newMap::'+newLeadMap);
        //system.debug('oldMap::'+oldLeadMap);
        try{
            for (lead ld : newLeadMap.values()){
                if ((ld.lead_stage__c == 'New' || ld.lead_stage__c == 'Called' || ld.lead_stage__c == 'Unassigned') && oldLeadMap.get(ld.Id).lead_stage__c == 'Nurturing'){
                    ld.lead_stage__c = 'Nurturing';
                    if (ld.Nurturing_to_New_Stage__c == null)
                        ld.Nurturing_to_New_Stage__c = 0;
                    ld.Nurturing_to_New_Stage__c += 1;
                }
                
                // system.debug('oldLeadMap.get(ld.Id).lead_stage__c--->'+oldLeadMap.get(ld.Id).lead_stage__c);
                if (oldLeadMap.get(ld.Id).lead_stage__c == 'Closed Won'){
                    // system.debug('oldLeadMap.get(ld.Id).lead_stage__c--->'+oldLeadMap.get(ld.Id).lead_stage__c);
                    ld.lead_stage__c = 'Closed Won';
                    ld.Lead_status__c = oldLeadMap.get(ld.Id).Lead_status__c;
                }
                if (oldLeadMap.get(ld.Id).lead_stage__c == 'Closed Lost' && ld.Lead_Stage__c != 'Closed Won' && ld.RecordTypeId == Constant.IdLeadOldFlowRT){
                    ld.lead_stage__c = 'Closed Lost';
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void TargetAchievementUpdationCreation(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        
        integer currentMonth = system.today().month();
        List<Target_Achievement__c> TAListTobeUpdated = new List<Target_Achievement__c>();
        List<Target_Achievement__c> allTargetAchievementRecs = new List<Target_Achievement__c>();
        Map<string, Target_Achievement__c> TArecByUserId = new Map<String, Target_Achievement__c>();
        map<Id, List<Lead>> listOfLeadByUserId = new map<Id, List<Lead>>();
        Map<String, Map<String, Target_Achievement__c>> TArecByMonthByUserId = new Map<String, Map<String, Target_Achievement__c>>();
        
        try{
            if (!newMap.isEmpty()){
                for (lead newlead : newMap.values()){
                    if (newlead.Payment_details__c != null && newlead.Payment_details__c != oldMap.get(newlead.id).Payment_details__c && newlead.Payment_Date__c != null){
                        if (listOfLeadByUserId.containsKey(newlead.OwnerId)){
                            //system.debug('inside If');
                            List<Lead> leadList = listOfLeadByUserId.get(newlead.OwnerId);
                            leadList.add(newlead);
                            listOfLeadByUserId.put(newlead.OwnerId, leadList);
                        } else{
                            listOfLeadByUserId.put(newlead.OwnerId, new List<Lead>{ newlead });
                        }
                    }
                }
            }
            //system.debug('listOfLeadByUserId :: ' + listOfLeadByUserId);
            
            if (!listOfLeadByUserId.isEmpty()){
                allTargetAchievementRecs = [Select Id, Achievement_Revenue__c, User__c, Total_Orders__c
                                            From Target_Achievement__c
                                            Where User__c in:listOfLeadByUserId.keySet() And Month__c = :currentMonth];
                if (!allTargetAchievementRecs.isEmpty()){
                    for (Target_Achievement__c TARec : allTargetAchievementRecs){
                        TArecByUserId.put(TARec.User__c, TARec);
                    }
                }
                
                for (Id userId : listOfLeadByUserId.keySet()){
                    Target_Achievement__c targetAchivementRec = new Target_Achievement__c();
                    if (TArecByUserId.containsKey(userId)){
                        decimal amount = 0;
                        integer orders = 0;
                        
                        for (Lead leadRec : listOfLeadByUserId.get(userId)){
                            amount += leadRec.Payment_details__c;
                            orders++;
                        }
                        targetAchivementRec.Id = TArecByUserId.get(userId).Id;
                        targetAchivementRec.Achievement_Revenue__c = TArecByUserId.get(userId).Achievement_Revenue__c + amount;
                        targetAchivementRec.Total_Orders__c = TArecByUserId.get(userId).Total_Orders__c + orders;
                    } else{
                        targetAchivementRec.User__c = userId;
                        decimal amount = 0;
                        integer orders = 0;
                        
                        for (Lead leadRec : listOfLeadByUserId.get(userId)){
                            amount += leadRec.Payment_details__c;
                            orders++;
                        }
                        targetAchivementRec.Start_Date__c = system.today();
                        targetAchivementRec.Target_Revenue__c = 100000;
                        targetAchivementRec.Achievement_Revenue__c = amount;
                        targetAchivementRec.Total_Orders__c = orders;
                    }
                    TAListTobeUpdated.add(targetAchivementRec);
                }
                if (!TAListTobeUpdated.isEmpty()){
                    upsert TAListTobeUpdated;
                }
            }
        } catch (exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error-->' + ex.getLineNumber());
        }
    }
    
    public static void updateFlagForRemarketingLeadClosure(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        try{
            List<Remarketing_Config__c> customSettingForRmTeam = Remarketing_Config__c.getall().values();
            for (Lead leadRec : newMap.values()){
                if (leadRec.Is_Remarketing_Lead__c == true){
                    if ((leadRec.Total_Calls_Made_after_RM_assigned_date__c != oldMap.get(leadRec.Id).Total_Calls_Made_after_RM_assigned_date__c && leadRec.Total_Calls_Made_after_RM_assigned_date__c > oldMap.get(leadRec.Id).Total_Calls_Made_after_RM_assigned_date__c && leadRec.Total_Calls_Made_after_RM_assigned_date__c > integer.valueOf(customSettingForRmTeam[0].Lead_Called_X_times__c)) || (leadRec.Total_Connected_calls_Made_after_RM_ass__c != oldMap.get(leadRec.Id).Total_Connected_calls_Made_after_RM_ass__c && leadRec.Total_Connected_calls_Made_after_RM_ass__c > oldMap.get(leadRec.Id).Total_Connected_calls_Made_after_RM_ass__c && leadRec.Total_Calls_Made_after_RM_assigned_date__c > integer.valueOf(customSettingForRmTeam[0].Leads_Connected_X_times__c))){
                        leadRec.Closed_By_Remarketing__c = true;
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error-->' + ex.getLineNumber());
        }
    }
    
    public static void beforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        try{
            List<Task> taskListToInsert = new List<Task>();
            for (Lead leadRec : newMap.values()){
                if (leadRec.Application_form_completed__c != oldMap.get(leadRec.Id).Application_form_completed__c && (leadRec.Application_form_completed__c == 'Submitted')){
                    if (leadRec.Application_Form_Completed_Date_Time__c == null)
                        leadRec.Application_Form_Completed_Date_Time__c = system.now();
                }
                if (leadRec.Application_form_completed__c != oldMap.get(leadRec.Id).Application_form_completed__c && (leadRec.Application_form_completed__c == 'Interview Slot Booked')){
                    if (leadRec.Interview_Slot_Date_Time__c == null)
                        leadRec.Interview_Slot_Date_Time__c = system.now();
                }
                if (leadRec.Interview_Status_AO__c != oldMap.get(leadRec.Id).Interview_Status_AO__c && (leadRec.Interview_Status_AO__c == 'Conducted')){
                    if (leadRec.Interview_Conducted_Date_Time__c == null)
                        leadRec.Interview_Conducted_Date_Time__c = system.now();
                }
                if (leadRec.Is_Interview_Conducted__c != oldMap.get(leadRec.Id).Is_Interview_Conducted__c && leadRec.Is_Interview_Conducted__c == true){
                    Task gmeetTask = new Task();
                    gmeetTask.Subject = 'Interview Task at ' + String.valueOf(Time.newInstance(system.now().hour(), system.now().minute(), system.now().second(), 00)).remove('.000Z') + ' on ' + string.valueOf(system.now().Date()).remove(' 00:00:00');
                    gmeetTask.WhoId = leadRec.Id;
                    gmeetTask.OwnerId = leadRec.OwnerId;
                    gmeetTask.Status = 'Completed';
                    gmeetTask.Priority = 'Normal';
                    gmeetTask.Activity_Date_Time__c = system.now();
                    gmeetTask.Activity_Type__c = 'Interview Scheduled';
                    taskListToInsert.add(gmeetTask);
                }
                
                if (leadRec.Communication__c != null && leadRec.Intent__c != null && leadRec.Financials__c != null && (leadRec.Communication__c != oldMap.get(leadRec.Id).Communication__c || leadRec.Intent__c != oldMap.get(leadRec.Id).Intent__c || leadRec.Financials__c != oldMap.get(leadRec.Id).Financials__c || (leadRec.Profession__c   != oldMap.get(leadRec.Id).Profession__c &&  leadRec.Profession__c != null))){
                    if (leadRec.Offer_Status__c == 'Yes'){
                        leadRec.Send_Admission_Letter_Yes_Date_Time__c = system.now();
                    } else if (leadRec.Offer_Status__c == 'No'){
                        leadRec.Send_Admission_Letter_No_DAte_Time__c = system.now();
                    }
                }
                
            }
            if (!taskListToInsert.isEmpty()){
                insert taskListToInsert;
            }
        } catch (exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error-->' + ex.getLineNumber());
        }
    }
    
    public static void updateInterviewStatus(List<Lead> leadList, Map<Id, Lead> oldMapOfLead, Map<Id, Lead> NewMapOfLead){
        system.DEBUG('uPDATIG iNTERVIEEW sTATUS');
        
        
        Map<Id, String> mapofLeadIdByStatus = New Map<Id, String>();
        
        for (Lead ld : leadList){
            if (ld.Lead_Version__c != null && ld.Lead_Version__c == 'V1'){
                system.debug('ld.Lead_Version__c-->'+ld.Lead_Version__c);
                if (ld.Interview_Status_AO__c != null && ld.Interview_Status_AO__c != oldMapOfLead.get(ld.Id).Interview_Status_AO__c){
                    if (ld.Interview_Status_AO__c == 'No Conducted'){
                        mapofLeadIdByStatus.put(ld.Id, Constant.SKIPPED_INTERVIEW);
                    }
                } else if (ld.Offer_Status__c == 'Yes'){
                    mapofLeadIdByStatus.put(ld.Id, Constant.ACCEPTED_OFFER);
                } else if (ld.Offer_Status__c == 'No'){
                    mapofLeadIdByStatus.put(ld.Id, Constant.REJECTED_OFFER);
                }
                if ((ld.AO_Interview_Status_Manual__c == 'Learner No-Show' || ld.AO_Interview_Status_Manual__c =='Joined & Dropped') && ld.AO_Interview_Status_Manual__c != oldMapOfLead.get(ld.Id).AO_Interview_Status_Manual__c){
                    mapofLeadIdByStatus.put(ld.Id, Constant.INTERVIEW_STATUS_MISSED);
                } else if (ld.AO_Interview_Status_Manual__c == 'AO No-Show' && ld.AO_Interview_Status_Manual__c != oldMapOfLead.get(ld.Id).AO_Interview_Status_Manual__c){
                    mapofLeadIdByStatus.put(ld.Id, Constant.INTERVIEW_STATUS_INTERVIEW_MISSED);
                }
            }
        }
        system.debug('mapofLeadIdByStatus::' + mapofLeadIdByStatus);
        if (!mapofLeadIdByStatus.isEmpty() && mapofLeadIdByStatus.keySet() != null){
            List<Interview__c> interviewListTobeUpdate = [select id, Status__c, lead__c
                                                          from Interview__c
                                                          where lead__c in:mapofLeadIdByStatus.keySet() and active__c = true];
            
            if (!interviewListTobeUpdate.isEmpty()){
                for (Interview__c intRec : interviewListTobeUpdate){
                    if (mapofLeadIdByStatus.get(intRec.lead__c) != null){
                        intRec.Status__c = mapofLeadIdByStatus.get(intRec.lead__c);
                        intRec.Intent__c = NewMapOfLead.get(intRec.lead__c).Intent__c;
                        intRec.Financials__c = NewMapOfLead.get(intRec.lead__c).Financials__c;
                        intRec.Communication__c = NewMapOfLead.get(intRec.lead__c).Communication__c;
                        intRec.Offer_Status__c = NewMapOfLead.get(intRec.lead__c).Offer_Status__c;
                        intRec.Recommended_Course_Offer__c = NewMapOfLead.get(intRec.lead__c).Recommended_Course_Offer__c;
                        intRec.Recommended_Plan_Offer__c = NewMapOfLead.get(intRec.lead__c).Recommended_Course__c;
                        if(!String.valueOf(NewMapOfLead.get(intRec.lead__c).OwnerId).startsWith('00G'))
                            intRec.Lead_assigned_to__c = NewMapOfLead.get(intRec.lead__c).OwnerId;
                        intRec.Interview_Feedback_Notes_AO__c = NewMapOfLead.get(intRec.lead__c).Interview_Feedback_Notes_AO__c;
                        intRec.Send_Admission_Letter__c = NewMapOfLead.get(intRec.lead__c).Offer_Status__c;
                        intRec.AO_Interview_Status_Manual__c = NewMapOfLead.get(intRec.lead__c).AO_Interview_Status_Manual__c;
                    } else{
                        continue;
                    }
                }
            }
            system.debug('interviewListTobeUpdateLL::' + interviewListTobeUpdate);
            update interviewListTobeUpdate;
        }
    }
    
    public static void updateNewFlowLeadStage(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            for (Lead leadRec : newLeadMap.values()){
                if (leadRec.recordTypeId == Constant.IdLeadNewFlowRT){
                    if (leadRec.Interview_Status_AO__c != oldLeadMap.get(leadRec.Id).Interview_Status_AO__c && leadRec.Interview_Status_AO__c == 'Conducted'){
                        leadRec.Lead_Stage__c = 'Conducted';
                    }
                    if (leadRec.Offer_Status__c != oldLeadMap.get(leadRec.Id).Offer_Status__c && leadRec.Offer_Status__c != null && oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'CLosed Won'){
                        leadRec.Lead_Stage__c = oldLeadMap.get(leadRec.Id).Lead_Stage__c;
                    }else if ( leadRec.Offer_Status__c != oldLeadMap.get(leadRec.Id).Offer_Status__c && leadRec.Offer_Status__c != null ){
                        leadRec.Lead_Stage__c = 'Offer Rolled Out';
                    }
                    
                }
            }
        } catch (exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error-->' + ex.getLineNumber());
        }
    }
    
    public static void CloseTaskForV1Flow(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        
        Set<Id> LeadIds = new Set<Id>();
        List<Task> TaskListToBeUpdated = new List<Task>();
        List<Task> UpdatedTaskList = new List<Task>();
        
        if (!newLeadMap.isEmpty()){
            for (Lead Ld : newLeadMap.values()){
                if ((Ld.Intent__c == 'High' || Ld.Intent__c == 'Medium' || Ld.Intent__c == 'Low') && (Ld.Communication__c == 'High' || Ld.Communication__c == 'Medium' || Ld.Communication__c == 'Low') && (Ld.Financials__c == 'High' || Ld.Financials__c == 'Low')){
                    LeadIds.add(Ld.Id);
                }
            }
        }
        if (!LeadIds.isEmpty()){
            TaskListToBeUpdated = [SELECT Id, Meeting_URL__c, OwnerId, Priority, Status, Subject, WhatId, WhoId
                                   FROM Task
                                   Where WhoId IN:LeadIds];
        }
        if (!TaskListToBeUpdated.isEmpty()){
            for (Task tas : TaskListToBeUpdated){
                if (tas.Subject == 'New Interview Scheduled'){
                    Task updatedTask = new Task();
                    updatedTask.id = tas.Id;
                    updatedTask.Status = 'Completed';
                    UpdatedTaskList.add(updatedTask);
                }
            }
        }
        if (!UpdatedTaskList.isEmpty()){
            update UpdatedTaskList;
        }
    }
    
    public static void IVRCallVersionV1(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        system.debug('IVR Calling for V1');
        for(Lead leadRec : newLeadMap.values()){
            if(leadRec.Lead_Version__c == 'V1' ){
                if(leadRec.Interview_Date__c != oldLeadMap.get(leadRec.Id).Interview_Date__c && leadRec.Interview_slot__c  != oldLeadMap.get(leadRec.Id).Interview_slot__c ){
                    Callout_ExotelAutoCall_V1.triggerExotelAutoCall(leadRec.Id);
                }
            }
        }
    }
    public static void handleV1leadStage(List<Lead> leadList, Map<Id, Lead> mapofOldLead){
        for (Lead ld : leadList){
            if (ld.RecordTypeId == Constant.IdLeadNewFlowRT && ld.Offer_Status__c == null && (ld.Lead_Stage__c == 'Called' || ld.Lead_Stage__c == 'Nurturing')){
                ld.Lead_Stage__c = mapofOldLead.get(ld.Id).Lead_Stage__c;
            }
        }
    }
    
    public static void assignLeadToDeafultQueue(List<Lead> leadList, Map<Id, Lead> oldMapOfLead){
        string queueId = [SELECT Id, Type
                          FROM Group
                          WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                          limit 1].Id;
        for (Lead ld : leadList){
            if (ld.AO_Interview_Status_Manual__c == 'Learner No-Show' && ld.AO_Interview_Status_Manual__c != oldMapOfLead.get(ld.Id).AO_Interview_Status_Manual__c){
                ld.OwnerId = queueId;
            } else if (ld.AO_Interview_Status_Manual__c == 'AO No-Show' && ld.AO_Interview_Status_Manual__c != oldMapOfLead.get(ld.Id).AO_Interview_Status_Manual__c){
                ld.OwnerId = queueId;
            }
        }
    }
    public static void handleInterviewFeedback(Map<Id, Lead> newMap, Map<id, Lead> oldMap){
        for(Lead leadRec : newMap.values()){
            if( (leadRec.Profession__c != oldMap.get(leadRec.id).Profession__c && (leadRec.Profession__c != null || leadRec.Profession__c == null)) || 
               (leadRec.Communication__c != oldMap.get(leadRec.id).Communication__c && (leadRec.Communication__c != null || leadRec.Communication__c == null)) || 
               (leadRec.Intent__c != oldMap.get(leadRec.id).Intent__c && (leadRec.Intent__c != null || leadRec.Intent__c == null))|| 
               (leadRec.Financials__c != oldMap.get(leadRec.id).Financials__c && (leadRec.Financials__c != null || leadRec.Financials__c == null) )){
                if(leadRec.Profession__c == null && leadRec.Communication__c == null && leadRec.Intent__c == null && leadRec.Financials__c == null ){
                    //leadRec.addError('Relevant fields related to Interview Feedback should be provided(Profession/Intent/Communication/Financial)');

                }else if(leadRec.Profession__c == null || leadRec.Communication__c == null || leadRec.Intent__c == null || leadRec.Financials__c == null ){
                    leadRec.addError('Relevant fields related to Interview Feedback should be provided(Profession/Intent/Communication/Financial)');

                }
            }
        }
    }
}