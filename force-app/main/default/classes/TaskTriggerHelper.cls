public without sharing class TaskTriggerHelper{
    public static void updateCallOnLead(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap){
        try{
            set<Id> leadIdset = New set<Id>();
            List<Lead> leadList = new list<Lead>();
            List<Lead> LeadListToUpdate = New List<Lead>();
            Map<Id, List<Task>> taskByLeadId = new Map<Id, List<Task>>();
            
            for (task task : newTaskMap.values()){
                if (task.Updated_by_Scheduler__c != null && task.Updated_by_Scheduler__c == true && task.Updated_by_Scheduler__c != oldTaskMap.get(task.id).Updated_by_Scheduler__c){
                    if (task.wk_exo__call_sid__c != null && !String.isBlank(task.wk_exo__call_sid__c)){
                        // && task.CallDurationInSeconds != oldTaskMap.get(task.id).CallDurationInSeconds){
                        //integer.valueOf(task.wk_exo__Total_Talk_Time__c) >= 0 && integer.valueOf(task.wk_exo__Total_Talk_Time__c) != integer.valueOf(oldTaskMap.get(task.Id).wk_exo__Total_Talk_Time__c)) {
                        leadIdset.add(task.WhoId);
                        if (taskByLeadId.containsKey(task.WhoId))
                            taskByLeadId.get(task.WhoId).add(task);
                        else
                            taskByLeadId.put(task.WhoId, new list<Task>{ task });
                        task.Status = 'Completed';
                    }
                }
            }
            system.debug('leadIdset>>' + leadIdset.size());
            if (!leadIdset.isEmpty()){
                leadList = [select id, Talk_Time__c, Is_Interview_Conducted__c,Connected_Call_Time_in_Seconds__c, Talk_Time_Last_30_Days__c, Call_Count__c, Total_Calls_Last_30_Days__c, Total_Call_Count__c, First_Called_Date_Time__c, First_Connected_Date_Time__c, Total_Calls_after_assigned__c, Connected_calls_After_Assigned__c, Total_call_Duration_After_assigned__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c, Total_call_Duration_After_admission__c, Interview_Status_AO__c, Admission_Letter_Sent__c, Admission_Letter_Send_Date_Time__c, Admission_Letter_Expiry_Date__c
                            FROM Lead
                            Where Id IN:leadIdset AND Is_Remarketing_Lead__c = false];
                if (!leadList.isEmpty()){
                    for (lead leadRec : leadList){
                        Lead leadToUpdate = new Lead();
                        leadToUpdate.Id = leadRec.id;
                        
                        integer callTime = 0;
                        integer talkTime = 0;
                        integer totalCall = 0;
                        integer connectedCallCount = 0;
                        integer preTotalCount = 0, preCallDuaration = 0, preConnectedCall = 0;
                        integer postTotalCount = 0, postCallDuration = 0, postConnectedCall = 0;
                        
                        if (leadRec.First_Called_Date_Time__c == null)
                            leadToUpdate.First_Called_Date_Time__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                        //Last_Connected_Date__c = Called Date(Called + Connected )
                        leadToUpdate.Last_Connected_Date__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                        if (taskByLeadId.containsKey(leadRec.id)){
                            for (Task taskrec : taskByLeadId.get(leadRec.id)){
                                callTime += integer.valueOf(taskrec.CallDurationInSeconds) > 0 ? integer.valueOf(taskrec.CallDurationInSeconds) : 0;
                                // talkTime += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                                if (leadRec.Is_Interview_Conducted__c == false){
                                    preTotalCount += 1;
                                }
                                if (leadRec.Is_Interview_Conducted__c == true){
                                    postTotalCount += 1;
                                }
                                totalCall += 1;
                                if (taskrec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0){
                                    if (leadRec.First_Connected_Date_Time__c == null)
                                        leadToUpdate.First_Connected_Date_Time__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                                    // Last_Called_Date_Time__c = Connected Date
                                    talkTime += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                                    leadToUpdate.Last_Called_Date_Time__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                                    system.debug('increse Connected count');
                                    connectedCallCount += 1;
                                    if (leadRec.Is_Interview_Conducted__c == false){
                                        preCallDuaration += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                                        preConnectedCall += 1;
                                    }
                                    if (leadRec.Is_Interview_Conducted__c == true){
                                        postCallDuration += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                                        postConnectedCall += 1;
                                    }
                                }
                            }
                            system.debug('connectedCallCount::'+connectedCallCount);
                            if (leadRec.Talk_Time__c == null)
                                leadRec.Talk_Time__c = 0;
                            leadToUpdate.Talk_Time__c = callTime + leadRec.Talk_Time__c;
                            if (leadRec.Connected_Call_Time_in_Seconds__c == null)
                                leadRec.Connected_Call_Time_in_Seconds__c = 0;
                            leadToUpdate.Connected_Call_Time_in_Seconds__c = talkTime + leadRec.Connected_Call_Time_in_Seconds__c;
                            if (leadRec.Total_Call_Count__c == null)
                                leadRec.Total_Call_Count__c = 0;
                            leadToUpdate.Total_Call_Count__c = totalCall + leadRec.Total_Call_Count__c;
                            if (leadRec.Call_Count__c == null)
                                leadRec.Call_Count__c = 0;
                            leadToUpdate.Call_Count__c = connectedCallCount + leadRec.Call_Count__c;
                            system.debug('leadToUpdate.Call_Count__c::'+leadToUpdate.Call_Count__c);
                            // integer preTotalCount = 0, preCallDuaration = 0, preConnectedCall = 0;
                            // integer postTotalCount = 0, postCallDuration = 0, postConnectedCall = 0;
                            
                            if (leadRec.Total_Calls_after_assigned__c == null)
                                leadRec.Total_Calls_after_assigned__c = 0;
                            leadToUpdate.Total_Calls_after_assigned__c = leadRec.Total_Calls_after_assigned__c + preTotalCount;
                            system.debug('leadRec.Connected_calls_After_Assigned__c::'+leadRec.Connected_calls_After_Assigned__c);
                            system.debug('preConnectedCall::'+preConnectedCall);
                            if (leadRec.Connected_calls_After_Assigned__c == null)
                                leadRec.Connected_calls_After_Assigned__c = 0;
                            leadToUpdate.Connected_calls_After_Assigned__c = leadRec.Connected_calls_After_Assigned__c + preConnectedCall;
                            if (leadRec.Total_call_Duration_After_assigned__c == null)
                                leadRec.Total_call_Duration_After_assigned__c = 0;
                            leadToUpdate.Total_call_Duration_After_assigned__c = leadRec.Total_call_Duration_After_assigned__c + preCallDuaration;
                            
                            if (leadRec.Total_Calls_After_Admission__c == null)
                                leadRec.Total_Calls_After_Admission__c = 0;
                            leadToUpdate.Total_Calls_After_Admission__c = leadRec.Total_Calls_After_Admission__c + postTotalCount;
                            if (leadRec.Connected_calls_After_Admission__c == null)
                                leadRec.Connected_calls_After_Admission__c = 0;
                            leadToUpdate.Connected_calls_After_Admission__c = leadRec.Connected_calls_After_Admission__c + postConnectedCall;
                            if (leadRec.Total_call_Duration_After_admission__c == null)
                                leadRec.Total_call_Duration_After_admission__c = 0;
                            leadToUpdate.Total_call_Duration_After_admission__c = leadRec.Total_call_Duration_After_admission__c + postCallDuration;
                            
                            
                            LeadListToUpdate.add(leadToUpdate);
                        }
                    }
                    if (!LeadListToUpdate.isEmpty()){
                        update LeadListToUpdate;
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateCallOnReMarketingLead(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap){
        try{
            set<Id> leadIdset = New set<Id>();
            List<Lead> leadList = new list<Lead>();
            List<Lead> LeadListToUpdate = New List<Lead>();
            Map<Id, List<Task>> taskByLeadId = new Map<Id, List<Task>>();
            
            for (task task : newTaskMap.values()){
                if (task.Updated_by_Scheduler__c != null && task.Updated_by_Scheduler__c == true && task.Updated_by_Scheduler__c != oldTaskMap.get(task.id).Updated_by_Scheduler__c){
                    
                    if (task.wk_exo__call_sid__c != null && !String.isBlank(task.wk_exo__call_sid__c)){
                        // && task.CallDurationInSeconds != oldTaskMap.get(task.id).CallDurationInSeconds){
                        //integer.valueOf(task.wk_exo__Total_Talk_Time__c) >= 0 && integer.valueOf(task.wk_exo__Total_Talk_Time__c) != integer.valueOf(oldTaskMap.get(task.Id).wk_exo__Total_Talk_Time__c)) {
                        leadIdset.add(task.WhoId);
                        if (taskByLeadId.containsKey(task.WhoId))
                            taskByLeadId.get(task.WhoId).add(task);
                        else
                            taskByLeadId.put(task.WhoId, new list<Task>{ task });
                        task.Status = 'Completed';
                    }
                }
            }
            system.debug('leadIdset>>' + leadIdset.size());
            if (!leadIdset.isEmpty()){
                leadList = [select id, Total_Calls_Made_after_RM_assigned_date__c, First_Called_Date_Time_RM__c, First_Connected_Date_Time_RM__c, Total_Connected_calls_Made_after_RM_ass__c, Total_Talk_time_Made_after_RM_assigned__c
                            FROM Lead
                            Where Id IN:leadIdset AND Is_Remarketing_Lead__c = true];
                if (!leadList.isEmpty()){
                    for (lead leadRec : leadList){
                        Lead leadToUpdate = new Lead();
                        leadToUpdate.Id = leadRec.id;
                        
                        integer talkTime = 0;
                        integer totalCall = 0;
                        integer connectedCallCount = 0;
                        if (leadRec.First_Called_Date_Time_RM__c == null)
                            leadToUpdate.First_Called_Date_Time_RM__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                        leadToUpdate.Last_Connected_Date__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                        if (taskByLeadId.containsKey(leadRec.id)){
                            for (Task taskrec : taskByLeadId.get(leadRec.id)){
                                talkTime += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                                totalCall += 1;
                                if (integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0){
                                    if (leadRec.First_Connected_Date_Time_RM__c == null)
                                        leadToUpdate.First_Connected_Date_Time_RM__c = taskByLeadId.get(leadRec.id)[0].Activity_Date_Time__c;
                                    system.debug('increse Connected count');
                                    connectedCallCount += 1;
                                }
                            }
                            
                            if (leadRec.Total_Talk_time_Made_after_RM_assigned__c == null)
                                leadRec.Total_Talk_time_Made_after_RM_assigned__c = 0;
                            leadToUpdate.Total_Talk_time_Made_after_RM_assigned__c = talkTime + leadRec.Total_Talk_time_Made_after_RM_assigned__c;
                            if (leadRec.Total_Calls_Made_after_RM_assigned_date__c == null)
                                leadRec.Total_Calls_Made_after_RM_assigned_date__c = 0;
                            leadToUpdate.Total_Calls_Made_after_RM_assigned_date__c = totalCall + leadRec.Total_Calls_Made_after_RM_assigned_date__c;
                            if (leadRec.Total_Connected_calls_Made_after_RM_ass__c == null)
                                leadRec.Total_Connected_calls_Made_after_RM_ass__c = 0;
                            leadToUpdate.Total_Connected_calls_Made_after_RM_ass__c = connectedCallCount + leadRec.Total_Connected_calls_Made_after_RM_ass__c;
                            LeadListToUpdate.add(leadToUpdate);
                        }
                    }
                    if (!LeadListToUpdate.isEmpty()){
                        update LeadListToUpdate;
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateLeadStage(Map<Id, Task> newTaskMap){
        List<Lead> stageToBeUpdatedAsCalled = new List<Lead>();
        List<Lead> stageToBeUpdatedAsNurturing = new List<Lead>();
        List<Lead> stageToBeUpdatedAsNurturingForInboundCall = new List<Lead>();
        
        set<Id> callCompletedLeadIds = new Set<Id>();
        set<Id> calledLeadId = new Set<Id>();
        set<Id> inboundCalledLeads = new Set<Id>();
        
        try{
            for (task task : newTaskMap.values()){
                if (!string.isBlank(task.wk_exo__Exotel_Call_Type__c) && !string.isBlank(task.wk_exo__exotel_dial_status__c)){
                    //Update Lead Stage as Nurturing
                    if (task.wk_exo__Exotel_Call_Type__c == 'Dialed' && task.wk_exo__exotel_dial_status__c.containsIgnoreCase('completed') && task.wk_exo__Total_Talk_Time__c != null && integer.valueOf(task.wk_exo__Total_Talk_Time__c) > 0){
                        callCompletedLeadIds.add(task.WhoId);
                    }
                    //Update Lead Stage as CAlled
                    if (task.wk_exo__Exotel_Call_Type__c == 'Dialed' && task.wk_exo__exotel_dial_status__c != 'completed'){
                        calledLeadId.add(task.WhoId);
                    }
                    if ((task.wk_exo__Exotel_Call_Type__c == 'Missed' || task.wk_exo__Exotel_Call_Type__c == 'Received') && task.wk_exo__Total_Talk_Time__c != null && integer.valueOf(task.wk_exo__Total_Talk_Time__c) > 0){
                        inboundCalledLeads.add(task.WhoId);
                    }
                }
            }
            if (!calledLeadId.isEmpty()){
                stageToBeUpdatedAsCalled = [Select Id, Lead_Stage__c
                                            From Lead
                                            Where (Lead_Stage__c = 'New' or Lead_Stage__c = 'Conducted' or Lead_Stage__c = 'Offer Rolled Out') AND Id in:calledLeadId];
                if (!stageToBeUpdatedAsCalled.isEmpty()){
                    for (Lead LeadRec : stageToBeUpdatedAsCalled){
                        LeadRec.Lead_Stage__c = 'Called';
                    }
                    update stageToBeUpdatedAsCalled;
                }
                
            }
            if (!callCompletedLeadIds.isEmpty()){
                stageToBeUpdatedAsNurturing = [Select Id, Lead_Stage__c
                                               From Lead
                                               Where (Lead_Stage__c = 'New' OR Lead_Stage__c = 'Called' or Lead_Stage__c = 'Conducted' or Lead_Stage__c = 'Offer Rolled Out') AND Id in:callCompletedLeadIds];
                if (!stageToBeUpdatedAsNurturing.isEmpty()){
                    for (Lead LeadRec : stageToBeUpdatedAsNurturing){
                        LeadRec.Lead_Stage__c = 'Nurturing';
                    }
                    update stageToBeUpdatedAsNurturing;
                }
            }
            if (!inboundCalledLeads.isEmpty()){
                stageToBeUpdatedAsNurturingForInboundCall = [Select Id, Lead_Stage__c
                                                             From Lead
                                                             Where Lead_Stage__c = 'Called' AND Id in:inboundCalledLeads];
                for (Lead leadRec : stageToBeUpdatedAsNurturingForInboundCall){
                    leadRec.Lead_Stage__c = 'Nurturing';
                }
                update stageToBeUpdatedAsNurturingForInboundCall;
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void updateLeadDetails(Map<Id, Task> newTaskMap){
        List<Lead> leadListToBeUpdated = new LIst<Lead>();
        Map<String, List<Task>> taskListByLeadId = new Map<String, List<Task>>();
        Map<String, String> activityTypeByLeadId = new Map<String, String>();
        
        // ============================= Gmeet event Details updattion List, set and Map =============================
        // Set<Id> LeadIds = new Set<Id>();
        // Map<String, Task> GmeetEventMapTaskByLeadId = new Map<String, Task>();
        // List<Lead> leadRecordsToBeUpdated = new List<Lead>();
        // List<Lead> UpdatedleadRecords = new List<Lead>();
        
        try{
            for (task task : newTaskMap.values()){
                // if(task.GMeet_Event_Id__c != null){
                //     LeadIds.add(task.WhoId);
                //     if(task.Event_Status__c == 'Open'){
                //         GmeetEventMapTaskByLeadId.put(task.WhoId, task);
                //     }
                // }
                if (task.Subject != null)
                    activityTypeByLeadId.put(task.WhoId, task.Subject);
                if (task.Activity_Type__c == 'Payment Failed' || task.Activity_Type__c == 'Abandoned Cart'){
                    if (taskListByLeadId.containsKey(task.WhoId)){
                        List<task> taskToBeAdded = taskListByLeadId.get(task.WhoId);
                        taskToBeAdded.add(task);
                        taskListByLeadId.put(task.WhoId, taskToBeAdded);
                    } else{
                        taskListByLeadId.put(task.WhoId, new List<Task>{ task });
                    }
                }
            }
            system.debug('activityTypeByLeadId::' + activityTypeByLeadId);
            if (!activityTypeByLeadId.isEmpty()){
                List<Lead> leadToUpdateLastActivity = [Select id, Last_Activity__c
                                                       From Lead
                                                       Where id in:activityTypeByLeadId.keySet()];
                system.debug('leadToUpdateLastActivity::' + leadToUpdateLastActivity);
                if (!leadToUpdateLastActivity.isEmpty()){
                    for (Lead leadRec : leadToUpdateLastActivity){
                        leadRec.Last_Activity__c = activityTypeByLeadId.get(leadRec.Id);
                        leadRec.Last_Activity_Date__c = date.today();
                    }
                    system.debug('leadToUpdateLastActivity::' + leadToUpdateLastActivity);
                    update leadToUpdateLastActivity;
                }
            }
            if (!taskListByLeadId.isEmpty()){
                List<Lead> leadToBeUpdated = [Select Id, Last_Activity__c, No_of_Payment_Failure_Activity__c, No_of_Abandon_Cart_Activity__c, First_Activity_Date__c
                                              From Lead
                                              Where Id in:taskListByLeadId.keySet()];
                if (!leadToBeUpdated.isEmpty())
                    for (Lead lead : leadToBeUpdated){
                        Task task = taskListByLeadId.get(lead.Id)[0];
                        if (task.Activity_Type__c == 'Payment Failed'){
                            Lead leadRecUpdated = new Lead();
                            leadRecUpdated.Id = lead.Id;
                            leadRecUpdated.No_of_Payment_Failure_Activity__c = lead.No_of_Payment_Failure_Activity__c + 1;
                            leadListToBeUpdated.add(leadRecUpdated);
                        }
                        if (task.Activity_Type__c == 'Abandoned Cart'){
                            Lead leadRecUpdated = new Lead();
                            leadRecUpdated.Id = lead.Id;
                            leadRecUpdated.No_of_Abandon_Cart_Activity__c = lead.No_of_Abandon_Cart_Activity__c + 1;
                            leadListToBeUpdated.add(leadRecUpdated);
                        }
                    }
                if (!leadListToBeUpdated.isEmpty()){
                    update leadListToBeUpdated;
                }
            }
            // if(!GmeetEventMapTaskByLeadId.isEmpty()){
            //     leadRecordsToBeUpdated = [Select Id, Interview_Scheduled_AC__c, Interview_Date_Time_AC__c, Interview_Schedule_Notes_AC__c
            //                                   From Lead
            //                                   Where Id in:LeadIds];
            
            //     if(!leadRecordsToBeUpdated.isEmpty()){
            //         for(Lead ld : leadRecordsToBeUpdated){
            //             ld.Interview_Scheduled_AC__c = 'Yes';
            //             ld.Interview_Date_Time_AC__c = GmeetEventMapTaskByLeadId.get(ld.id).StartDateTime;
            //             UpdatedleadRecords.add(ld);
            //         }
            
            //         if(!UpdatedleadRecords.isEmpty()){
            //             update UpdatedleadRecords;
            //         }
            
            //     }
            // }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
            system.debug('Trace::' + ex.getStackTraceString());
            
        }
    }
    
    public static void updateLeadSingUpDetails(Map<Id, Task> newTaskMap){
        List<Lead> leadListToBeUpdated = new LIst<Lead>();
        Set<Id> leadId = new set<Id>();
        List<Lead> leadToUpdateFirstSingUp = new List<Lead>();
        List<Lead> leadList = new List<Lead>();
        Map<String, Date> activityDateByLeadId = new Map<String, Date>();
        try{
            for (task task : newTaskMap.values()){
                if (task.Activity_Type__c != null){
                    leadId.add(task.WhoId);
                    if (task.Activity_Date_Time__c != null){
                        activityDateByLeadId.put(task.WhoId, task.Activity_Date_Time__c.date());
                    } else{
                        activityDateByLeadId.put(task.WhoId, Date.today());
                    }
                }
                if (task.Activity_Type__c != null && task.Activity_Type__c.containsIgnoreCase('Sign up')){
                    Lead leadRecUpdated = new Lead();
                    leadRecUpdated.Id = task.WhoId;
                    leadRecUpdated.Signup_Date_Time__c = task.Activity_Date_Time__c != null ? task.Activity_Date_Time__c : DateTime.now();
                    leadListToBeUpdated.add(leadRecUpdated);
                }
            }
            if (!leadListToBeUpdated.isEmpty()){
                update leadListToBeUpdated;
            }
            
            /*if(!leadId.isEmpty()){
leadList = [Select Id,First_Activity_Date__c From Lead Where Id in : leadId AND First_Activity_Date__c = null ];
if(!leadList.isEmpty()){
for(Lead ld : leadList){
if(activityDateByLeadId.ContainsKey(ld.Id)){
Lead leadRec = new Lead();
leadRec.Id = ld.Id;
leadRec.First_Activity_Date__c = activityDateByLeadId.get(ld.Id);
leadToUpdateFirstSingUp.add(leadRec);
}
}
if(!leadToUpdateFirstSingUp.isEmpty()){
update leadToUpdateFirstSingUp;
}
}
}*/
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
            
        }
    }
    
    public static void updateActivityDateTime(List<Task> newTaskList){
        try{
            map<Id, task> LeadListIdLearnerActivity = new map<Id, task>();
            map<Id, task> LeadListIdExeActivity = new map<Id, task>();
            if (!newTaskList.isEmpty()){
                for (task task : newTaskList){
                    if (task.Activity_Date_Time__c == null){
                        task.Activity_Date_Time__c = dateTime.now();
                    }
                    
                    if (task.Subject.containsIgnoreCase('Clicked') || task.Subject.containsIgnoreCase('Payment') || task.Subject.containsIgnoreCase('Referral') || task.Subject.containsIgnoreCase('Talk to Us') || task.Subject.containsIgnoreCase('Test') || task.Subject.containsIgnoreCase('Financepeer') || task.Subject.containsIgnoreCase('Missed') || task.Subject.containsIgnoreCase('Brochure Download') || task.Subject.containsIgnoreCase('Course Page') || task.Subject.containsIgnoreCase('Email opened') || task.Subject.containsIgnoreCase('Received') || task.Subject.containsIgnoreCase('Apply Now')){
                        LeadListIdLearnerActivity.put(task.WhoId, task);
                    } else if (task.Subject.contains('Candidate') || task.Subject.contains('Dialed Call') || task.Subject.contains('Email Interaction') || task.Subject.contains('Follow-up')){
                        LeadListIdExeActivity.put(task.WhoId, task);
                    }
                }
                if (!LeadListIdLearnerActivity.isempty()){
                    TaskTriggerHelper.UpdateLeadBasedOnLearnerTaskSubject(LeadListIdLearnerActivity);
                }
                if (!LeadListIdExeActivity.isempty()){
                    TaskTriggerHelper.UpdateLeadBasedOnexecutiveTaskSubject(LeadListIdExeActivity);
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
            
        }
    }
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    public static void updateLeadStatus(Map<Id, Task> newTaskMap){
        Map<String, Task> taskByLeadId = new Map<String, Task>();
        List<Lead> statusToBeUpdatedAsPaymentMade = new LIst<Lead>();
        List<Lead> closedLeadsList = new List<Lead>();
        Set<String> closedLeadOwnerid = new Set<String>();
        set<string> inboundMissedCallOwnerId = new Set<String>();
        Map<Id, Lead> leadByIdMapForInboundMissedCallNotify = new Map<Id, Lead>();
        Map<Id, Lead> leadByIdMapForClosedLeadActivity = new Map<Id, Lead>();
        set<Id> leadIds = new Set<Id>();
        set<Id> inboundMissedCallLeadIds = new Set<Id>();
        set<Id> allLeadIds = new Set<Id>();
        
        try{
            system.debug('newTaskMap::' + newTaskMap);
            for (task task : newTaskMap.values()){
                if (task.WhoId != null){
                    allLeadIds.add(task.WhoId);
                }
                //Update Lead Status as Payment Made
                if (task.Activity_Type__c != null && task.Activity_Type__c.containsIgnoreCase('Payment Successful') && task.Payment_Amount__c != null){
                    leadIds.add(task.WhoId);
                    taskByLeadId.put(task.WhoId, task);
                }
                if (task.wk_exo__Exotel_Call_Type__c == 'Missed' && (task.wk_exo__Total_Talk_Time__c == null || integer.valueOf(task.wk_exo__Total_Talk_Time__c) == 0) && task.OwnerId != null){
                    inboundMissedCallLeadIds.add(task.WhoId);
                    inboundMissedCallOwnerId.add(task.OwnerId);
                }
            }
            if (!inboundMissedCallLeadIds.isEmpty())
                leadByIdMapForInboundMissedCallNotify = new Map<Id, Lead>([Select id, FirstName, LastName, name, Learner_UID__C
                                                                           From Lead
                                                                           Where id in:inboundMissedCallLeadIds]);
            if (!inboundMissedCallOwnerId.isEmpty() && !leadByIdMapForInboundMissedCallNotify.isEmpty()){
                CustomNotification.notifyUsers(inboundMissedCallOwnerId, leadByIdMapForInboundMissedCallNotify, 'Missed Call', 'An inbound call is missed, Please do contact the Candidate on early basis');
            }
            if (!leadIds.isEmpty()){
                Map<Id, Lead> leadByIdMap = new Map<Id, Lead>([Select Id, Payment_Success_Date_Time__c, Payment_details__c, Payment_DateTime__c
                                                               From Lead
                                                               Where Id in:leadIds]);
                if (!taskByLeadId.isEmpty()){
                    for (String leadId : taskByLeadId.keySet()){
                        Lead leadRecToBeUpdated = new Lead();
                        leadRecToBeUpdated.Id = leadId;
                        leadRecToBeUpdated.Lead_status__c = 'Payment Made';
                        if (leadByIdMap.containsKey(leadId)){
                            leadRecToBeUpdated.Payment_details__c = leadByIdMap.get(leadId).Payment_details__c + taskByLeadId.get(leadId).Payment_Amount__c;
                            leadRecToBeUpdated.Payment_Success_Date_Time__c = taskByLeadId.get(leadId).Activity_Date_Time__c != null ? taskByLeadId.get(leadId).Activity_Date_Time__c : dateTime.now();
                            leadRecToBeUpdated.Payment_DateTime__c = taskByLeadId.get(leadId).Activity_Date_Time__c != null ? taskByLeadId.get(leadId).Activity_Date_Time__c : dateTime.now();
                        }
                        statusToBeUpdatedAsPaymentMade.add(leadRecToBeUpdated);
                    }
                    if (!statusToBeUpdatedAsPaymentMade.isEmpty()){
                        update statusToBeUpdatedAsPaymentMade;
                    }
                }
                
                string queueId = [SELECT Id, Type
                                  FROM Group
                                  WHERE Type = 'Queue' AND Name = 'Relevel Default Queue'
                                  limit 1].Id;
                closedLeadsList = [Select id, FirstName, LastName, OwnerID
                                   From Lead
                                   Where Id In:allLeadIds AND OwnerId != :queueId AND (Lead_Stage__c = 'Closed Won' OR Lead_Stage__C = 'Closed Lost')];
                if (!closedLeadsList.isEmpty()){
                    for (Lead ldRec : closedLeadsList){
                        closedLeadOwnerid.add(ldRec.OwnerId);
                        leadByIdMapForClosedLeadActivity.put(ldRec.Id, ldRec);
                    }
                    if (!closedLeadOwnerid.isEmpty() && !leadByIdMapForClosedLeadActivity.isEmpty()){
                        CustomNotification.notifyUsers(closedLeadOwnerid, leadByIdMapForClosedLeadActivity, 'Activity Performed on Closed Lead', 'There is some activity perfomed by cadidate, which is in Closure Stage');
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void handleStageChange(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap){
        for (Task taskRec : newTaskMap.values()){
            if (taskRec.Status != oldTaskMap.get(taskRec.Id).Status && taskRec.Status == 'Open'){
                taskRec.Status = 'Closed';
            }
        }
    }
    
    // ###################### update Re-Engagement Activity Time ###################################### //
    public static void updateReEngagementActivityTime(list<Task> taskList){
        
        try{
            set<Id> IdsList = new set<Id>();
            List<Lead> UpdatedLeadList = new List<Lead>();
            List<Lead> leadlistTobeUpdatedForReEngagement = new List<Lead>();
            
            if (!taskList.isEmpty()){
                for (task taskRec : taskList){
                    if (taskRec.Type == 'Sign up' || taskRec.Type == 'Test Registered' || taskRec.Type == 'Test Taken' || taskRec.Type == 'Talk to Us' || taskRec.Type == 'Payment Failed' || taskRec.Type == 'Payment Successful' || taskRec.Type == 'No Cost EMI Financepeer' || taskRec.Type == 'Lead from Support Chat' || taskRec.Type == 'Abandoned Cart' || taskRec.Type == 'Brochure Download' || taskRec.Type == 'Course Selection' || taskRec.Type == 'Course Page - Career Impact PDF Download' || taskRec.Type == 'Pay Now Clicked' || taskRec.Type == 'Stage Changed' || taskRec.Type == 'Email Interaction'){
                        IdsList.add(taskRec.WhoId);
                    }
                }
            }
            
            if (!IdsList.isEmpty()){
                leadlistTobeUpdatedForReEngagement = [Select id, Name, Re_Engagement_Activity_Time__c
                                                      From Lead
                                                      Where Id IN:IdsList and Lead_Stage__c = 'Closed Lost'];
                if (!leadlistTobeUpdatedForReEngagement.isEmpty()){
                    for (lead ld : leadlistTobeUpdatedForReEngagement){
                        lead updatedld = new lead();
                        updatedld.Id = ld.Id;
                        updatedld.Re_Engagement_Activity_Time__c = system.now();
                        UpdatedLeadList.add(updatedld);
                    }
                    update UpdatedLeadList;
                }
            }
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void markAsRemarketingActivity(Map<Id, Task> newTaskMap){
        try{
            set<Id> leadIds = new Set<Id>();
            List<Lead> leadList = new List<lead>();
            Map<String, task> taskByLeadId = new Map<String, Task>();
            List<task> taskkListToBeUpdated = new List<Task>();
            
            if (!newTaskMap.isEmpty()){
                for (Task taskRec : newTaskMap.values()){
                    leadIds.add(taskRec.WhoId);
                    taskByLeadId.put(taskRec.WhoId, taskRec);
                }
                if (!leadIds.isEmpty()){
                    leadList = [Select id
                                From Lead
                                Where Id in:leadIds AND Is_Remarketing_Lead__c = true];
                    if (!leadList.isEmpty()){
                        for (Lead leadRec : leadList){
                            if (taskByLeadId.containsKey(leadRec.Id)){
                                Task taskRec = new Task();
                                taskRec.id = taskByLeadId.get(leadRec.Id).Id;
                                taskRec.Is_Remarketing_Activity__c = true;
                                taskkListToBeUpdated.add(taskRec);
                            }
                        }
                        if (!taskkListToBeUpdated.isEmpty()){
                            update taskkListToBeUpdated;
                        }
                    }
                }
            }
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void UpdateLeadBasedOnLearnerTaskSubject(map<Id, task> LeadMapIdWithSubject){
        try{
            system.debug('LeadMapIdWithSubject :: ' + LeadMapIdWithSubject);
            list<Lead> leadRecords = [Select id, Last_Learner_Activity__c, Last_Learner_Activity_Date_Time__c, Last_Executive_Activity__c, Last_Executive_Activity_Date_Time__c
                                      From Lead
                                      Where Id IN:LeadMapIdWithSubject.keySet()];
            List<Lead> LeadlistToBeUpdated = new List<Lead>();
            if (!leadRecords.isEmpty()){
                for (Lead ld : leadRecords){
                    lead updatedLD = new lead();
                    updatedLD.Id = ld.id;
                    updatedLD.Last_Learner_Activity__c = LeadMapIdWithSubject.get(ld.Id).Subject;
                    updatedLD.Last_Learner_Activity_Date_Time__c = LeadMapIdWithSubject.get(ld.Id).Activity_Date_Time__c != null ? LeadMapIdWithSubject.get(ld.Id).Activity_Date_Time__c : DateTime.now();
                    LeadlistToBeUpdated.add(updatedLD);
                }
                if (!LeadlistToBeUpdated.isEmpty()){
                    update LeadlistToBeUpdated;
                }
            }
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void UpdateLeadBasedOnexecutiveTaskSubject(map<Id, task> LeadMapIdWithSubject){
        try{
            system.debug('LeadMapIdWithSubject :: ' + LeadMapIdWithSubject);
            list<Lead> leadRecords = [Select id, Last_Learner_Activity__c, Last_Learner_Activity_Date_Time__c, Last_Executive_Activity__c, Last_Executive_Activity_Date_Time__c
                                      From Lead
                                      Where Id IN:LeadMapIdWithSubject.keySet()];
            List<Lead> LeadlistToBeUpdated = new List<Lead>();
            if (!leadRecords.isEmpty()){
                for (Lead ld : leadRecords){
                    lead updatedLD = new lead();
                    updatedLD.Id = ld.id;
                    updatedLD.Last_Executive_Activity__c = LeadMapIdWithSubject.get(ld.Id).Subject;
                    updatedLD.Last_Executive_Activity_Date_Time__c = LeadMapIdWithSubject.get(ld.Id).Activity_Date_Time__c != null ? LeadMapIdWithSubject.get(ld.Id).Activity_Date_Time__c : DateTime.now();
                    LeadlistToBeUpdated.add(updatedLD);
                }
                if (!LeadlistToBeUpdated.isEmpty()){
                    update LeadlistToBeUpdated;
                }
            }
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void updateFromstatusOnLead(List<Task> taskList){
        system.debug('Inside updating application form stas');
        try{
            //1. Apply Now
            //2. Courses form education details next clicked
            //3. Courses form profession details next clicked
            //4. coursed form SOP Next clicked
            // s.containsIgnoreCase('HE')
            Map<string, Task> taskListByLeadId = new Map<String, Task>();
            List<Lead> existingLeadList = new List<Lead>();
            List<Lead> leadListToUpdateRecord = new List<Lead>();
            
            for (Task taskRec : taskList){
                if (taskRec.Subject.containsIgnoreCase('Apply Now') || taskRec.Subject.containsIgnoreCase('Courses Form SOP Next Clicked') || taskRec.Subject.containsIgnoreCase('Courses Form Profession Details Next Clicked') || taskRec.Subject.containsIgnoreCase('Courses Form Education Details Next Clicked')){
                    if (taskListByLeadId.containsKey(taskRec.whoid) && taskRec.Activity_Date_Time__c > taskListByLeadId.get(taskRec.whoid).Activity_Date_Time__c){
                        taskListByLeadId.put(taskRec.whoid, taskRec);
                    } else{
                        taskListByLeadId.put(taskRec.whoid, taskRec);
                    }
                }
            }
            system.debug('taskListByLeadId-->' + taskListByLeadId);
            if (!taskListByLeadId.isEmpty()){
                existingLeadList = [Select Id, Latest_Application_Activity__c, Latest_Application_Activity_Date_Time__c
                                    FRom Lead
                                    Where id in:taskListByLeadId.keyset()];
                system.debug('existingLeadList--' + existingLeadList);
                if (!existingLeadList.isEmpty()){
                    for (Lead leadRec : existingLeadList){
                        Lead leadRecToBeUpdated = new Lead();
                        leadRecToBeUpdated.Id = leadRec.Id;
                        system.debug('taskListByLeadId-->' + taskListByLeadId);
                        if (taskListByLeadId.containsKey(leadRec.Id)){
                            if (leadRec.Latest_Application_Activity__c == null){
                                leadRecToBeUpdated.Latest_Application_Activity__c = taskListByLeadId.get(leadRec.Id).Subject;
                                if (taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c != null)
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c;
                                else
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = DateTime.now();
                            } else if (leadRec.Latest_Application_Activity__c.containsIgnoreCase('Apply Now')){
                                leadRecToBeUpdated.Latest_Application_Activity__c = taskListByLeadId.get(leadRec.Id).Subject;
                                if (taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c != null)
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c;
                                else
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = DateTime.now();
                            } else if (leadRec.Latest_Application_Activity__c.containsIgnoreCase('Courses Form Education Details Next Clicked') && ((taskListByLeadId.get(leadRec.Id).Subject).containsIgnoreCase('Courses Form SOP Next Clicked') || (taskListByLeadId.get(leadRec.Id).Subject).containsIgnoreCase('Courses Form Profession Details Next Clicked'))){
                                leadRecToBeUpdated.Latest_Application_Activity__c = taskListByLeadId.get(leadRec.Id).Subject;
                                if (taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c != null)
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c;
                                else
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = DateTime.now();
                            } else if (leadRec.Latest_Application_Activity__c.containsIgnoreCase('Courses Form Profession Details Next Clicked') && (taskListByLeadId.get(leadRec.Id).Subject).containsIgnoreCase('Courses Form SOP Next Clicked')){
                                leadRecToBeUpdated.Latest_Application_Activity__c = taskListByLeadId.get(leadRec.Id).Subject;
                                if (taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c != null)
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c;
                                else
                                    leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = DateTime.now();
                            } else if (leadRec.Latest_Application_Activity__c.containsIgnoreCase('Courses Form SOP Next Clicked')){
                                // leadRecToBeUpdated.Latest_Application_Activity__c = taskListByLeadId.get(leadRec.Id).Subject;
                                //leadRecToBeUpdated.Latest_Application_Activity_Date_Time__c = taskListByLeadId.get(leadRec.Id).Activity_Date_Time__c;
                            }
                            leadListToUpdateRecord.add(leadRecToBeUpdated);
                        }
                    }
                    if (!leadListToUpdateRecord.isEmpty()){
                        update leadListToUpdateRecord;
                    }
                }
            }
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void updateLeadCallDetails(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap){
        system.debug('Inside trigger for updating call details');
        system.debug('newTaskMap :: ' + newTaskMap);
        
        Map<string, List<Task>> taskListByLeadId = new Map<string, List<Task>>();
        List<Lead> leadListToBeUpdated = new List<Lead>();
        List<Lead> leadListAssToConductted = new List<Lead>();
        List<Lead> leadListAdmissionToExpiry = new List<Lead>();
        List<Lead> leadListToBeUpdatedAdmissionToExpiry = new List<Lead>();
        //After asssignment -> new lead assigned date != null && Interview_Conducted_Date_Time__c = null
        //After admission  -> admission letter send time and admission letter expiry time != null
        
        try{
            if (!newTaskMap.isEmpty()){
                for (Task tas : newTaskMap.values()){
                    system.debug('tas.wk_exo__call_sid__c-->' + tas.wk_exo__call_sid__c);
                    if (task.Updated_by_Scheduler__c != null && tas.Updated_by_Scheduler__c == true && tas.Updated_by_Scheduler__c != oldTaskMap.get(tas.id).Updated_by_Scheduler__c){
                        if (tas.wk_exo__call_sid__c != null && !String.isBlank(tas.wk_exo__call_sid__c)){
                            //tas.CallDurationInSeconds != oldTaskMap.get(tas.Id).CallDurationInSeconds){
                            // leadIds.add(tas.WhoId);
                            if (taskListByLeadId.containsKey(tas.whoId)){
                                taskListByLeadId.get(tas.whoId).add(tas);
                            } else{
                                taskListByLeadId.put(tas.whoId, new List<Task>{ tas });
                            }
                        }
                    }
                }
                system.debug('taskListByLeadId-->' + taskListByLeadId);
                if (!taskListByLeadId.isEmpty()){
                    leadListAssToConductted = [Select id, Name, New_Lead_Assigned_DateTime__c, Total_Calls_after_assigned__c, Connected_calls_After_Assigned__c, Total_call_Duration_After_assigned__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c, Total_call_Duration_After_admission__c, Interview_Status_AO__c, Admission_Letter_Sent__c, Admission_Letter_Send_Date_Time__c, Admission_Letter_Expiry_Date__c
                                               From Lead
                                               Where Id In:taskListByLeadId.keyset() And New_Lead_Assigned_DateTime__c != null AND (Interview_Conducted_Date_Time__c = null) And Admission_Letter_Send_Date_Time__c = null AND Admission_Letter_Expiry_Date__c = null];
                    leadListAdmissionToExpiry = [Select id, Name, New_Lead_Assigned_DateTime__c, Total_Calls_after_assigned__c, Connected_calls_After_Assigned__c, Total_call_Duration_After_assigned__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c, Total_call_Duration_After_admission__c, Interview_Status_AO__c, Admission_Letter_Sent__c, Admission_Letter_Send_Date_Time__c, Admission_Letter_Expiry_Date__c
                                                 From Lead
                                                 Where Id In:taskListByLeadId.keyset() And Admission_Letter_Send_Date_Time__c != null AND Interview_Conducted_Date_Time__c != null AND Admission_Letter_Expiry_Date__c != null];
                    system.debug('leadListAssToConductted-->' + leadListAssToConductted);
                    if (!leadListAssToConductted.isEmpty()){
                        for (Lead leadRec : leadListAssToConductted){
                            Lead leadRecToUpdate = new Lead();
                            leadRecToUpdate.Id = leadRec.Id;
                            if (taskListByLeadId.containsKey(leadRec.Id)){
                                integer callCount = 0;
                                integer connectedCall = 0;
                                integer connectedTime = 0;
                                system.debug('callCount-->' + callCount);
                                system.debug('taskListByLeadId.get(leadRec.Id)-->' + taskListByLeadId.get(leadRec.Id).size());
                                for (Task taskRec : taskListByLeadId.get(leadRec.Id)){
                                    callCount++;
                                    system.debug('callCount-->' + callCount);
                                    if (integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                                        connectedCall++;
                                        connectedTime += integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c);
                                    }
                                    system.debug('callCount-->' + callCount);
                                    system.debug('connectedCall-->' + connectedCall);
                                    system.debug('connectedTime-->' + connectedTime);
                                }
                                if (leadRec.Total_Calls_after_assigned__c == null)
                                    leadRec.Total_Calls_after_assigned__c = 0;
                                system.debug('leadRec.Total_Calls_after_assigned__c-->' + leadRec.Total_Calls_after_assigned__c);
                                system.debug('callCount-->' + callCount);
                                leadRecToUpdate.Total_Calls_after_assigned__c = leadRec.Total_Calls_after_assigned__c + callCount;
                                if (leadRec.Connected_calls_After_Assigned__c == null)
                                    leadRec.Connected_calls_After_Assigned__c = 0;
                                leadRecToUpdate.Connected_calls_After_Assigned__c = leadRec.Connected_calls_After_Assigned__c + connectedCall;
                                if (leadRec.Total_call_Duration_After_assigned__c == null)
                                    leadRec.Total_call_Duration_After_assigned__c = 0;
                                leadRecToUpdate.Total_call_Duration_After_assigned__c = leadRec.Total_call_Duration_After_assigned__c + connectedTime;
                                system.debug('leadRecToUpdate-->' + leadRecToUpdate);
                                leadListToBeUpdated.add(leadRecToUpdate);
                            }
                            
                        }
                        if (!leadListToBeUpdated.isEmpty()){
                            update leadListToBeUpdated;
                        }
                    }
                    system.debug('leadListAdmissionToExpiry-->' + leadListAdmissionToExpiry);
                    if (!leadListAdmissionToExpiry.isEmpty()){
                        for (Lead leadRec : leadListAdmissionToExpiry){
                            Lead leadRecToUpdate = new Lead();
                            leadRecToUpdate.Id = leadRec.Id;
                            if (taskListByLeadId.containsKey(leadRec.Id)){
                                integer callCount = 0;
                                integer connectedCall = 0;
                                integer connectedTime = 0;
                                system.debug('taskListByLeadId.get(leadRec.Id)-->' + taskListByLeadId.get(leadRec.Id).size());
                                for (Task taskRec : taskListByLeadId.get(leadRec.Id)){
                                    system.debug('taskRec.CreatedDate-->' + taskRec.CreatedDate);
                                    system.debug('leadRec.Admission_Letter_Send_Date_Time__c-->' + leadRec.Admission_Letter_Send_Date_Time__c);
                                    system.debug('leadRec.Admission_Letter_Expiry_Date__c-->' + leadRec.Admission_Letter_Expiry_Date__c);
                                    
                                    if (taskRec.CreatedDate > leadRec.Admission_Letter_Send_Date_Time__c && taskRec.CreatedDate < leadRec.Admission_Letter_Expiry_Date__c){
                                        callCount++;
                                        if (integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                                            connectedCall++;
                                            connectedTime += integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c);
                                        }
                                        system.debug('callCount-->' + callCount);
                                        system.debug('connectedCall-->' + connectedCall);
                                        system.debug('connectedTime-->' + connectedTime);
                                    }
                                    
                                    if (leadRec.Total_Calls_After_Admission__c == null)
                                        leadRec.Total_Calls_After_Admission__c = 0;
                                    leadRecToUpdate.Total_Calls_After_Admission__c = leadRec.Total_Calls_After_Admission__c + callCount;
                                    if (leadRec.Connected_calls_After_Admission__c == null)
                                        leadRec.Connected_calls_After_Admission__c = 0;
                                    leadRecToUpdate.Connected_calls_After_Admission__c = leadRec.Connected_calls_After_Admission__c + connectedCall;
                                    if (leadRec.Total_call_Duration_After_admission__c == null)
                                        leadRec.Total_call_Duration_After_admission__c = 0;
                                    leadRecToUpdate.Total_call_Duration_After_admission__c = leadRec.Total_call_Duration_After_admission__c + connectedTime;
                                    leadListToBeUpdatedAdmissionToExpiry.add(leadRecToUpdate);
                                }
                            }
                            
                        }
                        if (!leadListToBeUpdatedAdmissionToExpiry.isEmpty()){
                            update leadListToBeUpdatedAdmissionToExpiry;
                        }
                    }
                }
            }
            
        } catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line number :: ' + e.getLineNumber());
        }
    }
    
    public static void updatePrePostInterviewCallDetail(Map<Id, Task> oldTaskMap, Map<Id, Task> newTaskMap){
        //Is_Interview_Conducted__c
        
        Map<string, List<Task>> taskListByLeadId = new Map<string, List<Task>>();
        List<Lead> leadListPreInterview = new List<Lead>();
        List<Lead> leadListPostInterview = new List<Lead>();
        List<Lead> leadListPreToBeUpdated = new List<Lead>();
        List<Lead> leadListPostToBeUpdated = new List<Lead>();
        
        if (!newTaskMap.isEmpty()){
            for (Task tas : newTaskMap.values()){
                if (task.Updated_by_Scheduler__c != null && tas.Updated_by_Scheduler__c == true && tas.Updated_by_Scheduler__c != oldTaskMap.get(tas.id).Updated_by_Scheduler__c){
                    if (tas.wk_exo__call_sid__c != null && !String.isBlank(tas.wk_exo__call_sid__c)){
                        if (taskListByLeadId.containsKey(tas.whoId)){
                            taskListByLeadId.get(tas.whoId).add(tas);
                        } else{
                            taskListByLeadId.put(tas.whoId, new List<Task>{ tas });
                        }
                    }
                }
            }
            System.debug('taskListByLeadId-->' + taskListByLeadId);
            if (!taskListByLeadId.isEmpty()){
                leadListPreInterview = [Select id, Name, New_Lead_Assigned_DateTime__c, Total_Calls_after_assigned__c, Connected_calls_After_Assigned__c, Total_call_Duration_After_assigned__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c, Total_call_Duration_After_admission__c, Interview_Status_AO__c, Admission_Letter_Sent__c, Admission_Letter_Send_Date_Time__c, Admission_Letter_Expiry_Date__c
                                        From Lead
                                        Where Id In:taskListByLeadId.keyset() And Is_Interview_Conducted__c = false];
                leadListPostInterview = [Select id, Name, New_Lead_Assigned_DateTime__c, Total_Calls_after_assigned__c, Connected_calls_After_Assigned__c, Total_call_Duration_After_assigned__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c, Total_call_Duration_After_admission__c, Interview_Status_AO__c, Admission_Letter_Sent__c, Admission_Letter_Send_Date_Time__c, Admission_Letter_Expiry_Date__c
                                         From Lead
                                         Where Id In:taskListByLeadId.keyset() And Is_Interview_Conducted__c = true];
                system.debug('leadListPreInterview-->' + leadListPreInterview);
                if (!leadListPreInterview.isEmpty()){
                    for (Lead leadRec : leadListPreInterview){
                        Lead leadRecToUpdate = new Lead();
                        leadRecToUpdate.Id = leadRec.Id;
                        if (taskListByLeadId.containsKey(leadRec.Id)){
                            integer callCount = 0;
                            integer connectedCall = 0;
                            integer connectedTime = 0;
                            system.debug('callCount-->' + callCount);
                            system.debug('taskListByLeadId.get(leadRec.Id)-->' + taskListByLeadId.get(leadRec.Id).size());
                            for (Task taskRec : taskListByLeadId.get(leadRec.Id)){
                                callCount++;
                                system.debug('callCount-->' + callCount);
                                if (taskRec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                                    connectedCall++;
                                    connectedTime += integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c);
                                }
                                system.debug('callCount-->' + callCount);
                                system.debug('connectedCall-->' + connectedCall);
                                system.debug('connectedTime-->' + connectedTime);
                            }
                            if (leadRec.Total_Calls_after_assigned__c == null)
                                leadRec.Total_Calls_after_assigned__c = 0;
                            system.debug('leadRec.Total_Calls_after_assigned__c-->' + leadRec.Total_Calls_after_assigned__c);
                            system.debug('callCount-->' + callCount);
                            leadRecToUpdate.Total_Calls_after_assigned__c = leadRec.Total_Calls_after_assigned__c + callCount;
                            if (leadRec.Connected_calls_After_Assigned__c == null)
                                leadRec.Connected_calls_After_Assigned__c = 0;
                            leadRecToUpdate.Connected_calls_After_Assigned__c = leadRec.Connected_calls_After_Assigned__c + connectedCall;
                            if (leadRec.Total_call_Duration_After_assigned__c == null)
                                leadRec.Total_call_Duration_After_assigned__c = 0;
                            leadRecToUpdate.Total_call_Duration_After_assigned__c = leadRec.Total_call_Duration_After_assigned__c + connectedTime;
                            system.debug('leadRecToUpdate-->' + leadRecToUpdate);
                            leadListPreToBeUpdated.add(leadRecToUpdate);
                        }
                        
                    }
                    system.debug('leadListPreToBeUpdated-->' + leadListPreToBeUpdated);
                    if (!leadListPreToBeUpdated.isEmpty()){
                        update leadListPreToBeUpdated;
                    }
                }
                system.debug('leadListPostInterview-->' + leadListPostInterview);
                
                if (!leadListPostInterview.isEmpty()){
                    for (Lead leadRec : leadListPostInterview){
                        Lead leadRecToUpdate = new Lead();
                        leadRecToUpdate.Id = leadRec.Id;
                        if (taskListByLeadId.containsKey(leadRec.Id)){
                            integer callCount = 0;
                            integer connectedCall = 0;
                            integer connectedTime = 0;
                            system.debug('taskListByLeadId.get(leadRec.Id)-->' + taskListByLeadId.get(leadRec.Id).size());
                            for (Task taskRec : taskListByLeadId.get(leadRec.Id)){
                                
                                callCount++;
                                if (taskRec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                                    connectedCall++;
                                    connectedTime += integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c);
                                }
                                
                                if (leadRec.Total_Calls_After_Admission__c == null)
                                    leadRec.Total_Calls_After_Admission__c = 0;
                                leadRecToUpdate.Total_Calls_After_Admission__c = leadRec.Total_Calls_After_Admission__c + callCount;
                                if (leadRec.Connected_calls_After_Admission__c == null)
                                    leadRec.Connected_calls_After_Admission__c = 0;
                                leadRecToUpdate.Connected_calls_After_Admission__c = leadRec.Connected_calls_After_Admission__c + connectedCall;
                                if (leadRec.Total_call_Duration_After_admission__c == null)
                                    leadRec.Total_call_Duration_After_admission__c = 0;
                                leadRecToUpdate.Total_call_Duration_After_admission__c = leadRec.Total_call_Duration_After_admission__c + connectedTime;
                                leadListPostToBeUpdated.add(leadRecToUpdate);
                            }
                        }
                    }
                    system.debug('leadListPostToBeUpdated-->' + leadListPostToBeUpdated);
                    if (!leadListPostToBeUpdated.isEmpty()){
                        update leadListPostToBeUpdated;
                    }
                }
            }
        }
    }
    
}