public without sharing class InterviewTriggerHandler{
    public static void DeactivateInterview(List<Interview__c> listofInterviews, Map<Id, Interview__c> oldMapInterview){
        Set<Id> leadIdSet = New Set<Id>();
        for ( Interview__c intRec : listofInterviews ){
            //ACCEPTED_OFFER = Accepted
            //REJECTED_OFFER = 'Rejected'
            //COMPLETED_OFFER = 'Completed'
            //INTERVIEW_STATUS_MISSED = 'Missed'
            //INTERVIEW_STATUS_INTERVIEW_MISSED = 'Interviewer Missed'
            if ( intRec.Status__c != oldMapInterview.get(intRec.Id).Status__c && ( intRec.Status__c == Constant.ACCEPTED_OFFER || intRec.Status__c == Constant.REJECTED_OFFER || intRec.Status__c == Constant.COMPLETED_OFFER 
                                                                                 || intRec.Status__c == Constant.INTERVIEW_STATUS_MISSED || intRec.Status__c == Constant.INTERVIEW_STATUS_INTERVIEW_MISSED) ){
                intRec.Active__c = false;
                intRec.End_Time__c = system.now();                                                                     
                leadIdSet.add(intRec.Lead__c);
                                                                                     
            }
        }
        
        if(!leadIdSet.isEmpty()){
            List<Task> taskListTobeUpdate = [select id,WhoId,Status from task where WhoId in: leadIdSet and Subject =: system.label.Interview_Task_Subject and Status = 'Open'];
            if(!taskListTobeUpdate.isEmpty()){
                for(Task ts : taskListTobeUpdate){
                    ts.status = 'Completed';
                }
                
                update taskListTobeUpdate;
            }
            
        }
    }

    public static void CreateAndAssignTaskWithAOAssignment(Map<Id, Interview__c> oldMapInterview, Map<Id, Interview__c> newMapInterview){
        List<task> taskListToBeAssignedToAO = new List<Task>();
        set<String> recipientsIds = new set<String>();
        set<id> LeadIds = new Set<Id>(); //leadByIdMap
        List<Lead> LeadList = new List<Lead>();
        map<Id, Lead> leadByIdMap = new map<Id, Lead>();
        List<AO_Availability__c> AOAvailableListTobeUpdated = new List<AO_Availability__c>();
        List<AO_Availability__c> UpdatedAOAvailableList = new List<AO_Availability__c>();
        try{
            if ( !newMapInterview.isEmpty() ){
                for ( Interview__c Interview : newMapInterview.values() ){
                    if ((Interview.Interviewer__c != null && oldMapInterview == null) || (Interview.Interviewer__c != null && oldMapInterview != null && Interview.Interviewer__c != oldMapInterview.get(Interview.id).Interviewer__c)){                         //Interview.Interviewer__c != oldMapInterview.get(Interview.Id).Interviewer__c 
                        recipientsIds.add(Interview.Interviewer__c);
                        LeadIds.add(Interview.Lead__c);
                        task tsk = new Task();
                        tsk.Subject = system.label.Interview_Task_Subject;
                        tsk.Status = 'Open';
                        tsk.Priority = 'High';
                        tsk.WhoId = Interview.Lead__c;
                        tsk.OwnerId = Interview.Interviewer__c;
                        tsk.Meeting_URL__c = Interview.Meeting_URL__c;
                        tsk.IsReminderSet = true;
                        tsk.ReminderDateTime = System.now();
                        taskListToBeAssignedToAO.add(tsk);
                        if ( !LeadIds.isEmpty() ){
                            LeadList = [Select Id, FirstName, LastName, Name
                                        From Lead
                                        Where Id In:LeadIds];
                        }
                        if ( !LeadList.isEmpty() ){
                            for ( Lead ld : LeadList ){
                                leadByIdMap.put(ld.Id, ld);
                            }
                        }
                        if (!recipientsIds.isEmpty()) {
                            AOAvailableListTobeUpdated = [Select Id, Audited_Officer__c,Checkin_DateTime__c, Meeting_Url__c, Status__c
                                                        From AO_Availability__c
                                                        Where Audited_Officer__c IN : recipientsIds And CreatedDate = TODAY];
                            
                            if (!AOAvailableListTobeUpdated.isEmpty()) {
                                for (AO_Availability__c AOAvailable : AOAvailableListTobeUpdated) {
                                    AOAvailable.status__c = 'In Meeting';
                                    UpdatedAOAvailableList.add(AOAvailable);
                                }
                            }
                        }
                    }
                }
            }
            if (!UpdatedAOAvailableList.isEmpty()) {
                update UpdatedAOAvailableList;
            }
            if ( !taskListToBeAssignedToAO.isEmpty()){
                insert taskListToBeAssignedToAO;
            }
            if (!leadByIdMap.isEmpty() && !recipientsIds.isEmpty()) {
                CustomNotifications.notifyUsers(recipientsIds, leadByIdMap);
            }
        }
        catch ( Exception e ){
            System.debug('This error has occured due to =======> ' + e.getMessage() + ' at Line Number  ========> ' + e.getLineNumber());

        }
    }
    
    public static void createAOActivitiesLog(List<Interview__c> interviewList,Map<Id,Interview__c> mapofOldInterviewRec){
        List<AO_Activity__c> aoActivitiesToBeInsert = new List<AO_Activity__c>();
        List<AO_Availability__c> listodAOAvalability = new List<AO_Availability__c>();
        Map<Id,Id> mapofAOIdByAOId = new Map<Id,Id>();
        listodAOAvalability = [select id,Audit_Officer__c,Audited_Officer__c from AO_Availability__c where createddate = today];
        for(AO_Availability__c ao : listodAOAvalability){
            mapofAOIdByAOId.put(ao.Audited_Officer__c,ao.Id);
        }
        for(Interview__c InterRecord : interviewList){
            if(InterRecord.Status__c != null && InterRecord.Status__c != mapofOldInterviewRec.get(InterRecord.Id).Status__c && (InterRecord.Status__c == Constant.INTERVIEW_STATUS_INTERVIEW_MISSED || InterRecord.Status__c == 'Accepted' || InterRecord.Status__c == 'Rejected' || InterRecord.Status__c == 'Missed' || InterRecord.Status__c == 'Completed')){
                AO_Activity__c aoActivity = new AO_Activity__c();
                aoActivity.AO_Availability__c = mapofAOIdByAOId.get(InterRecord.Interviewer__c);
                aoActivity.AO_Member__c = InterRecord.Interviewer__c;
                aoActivity.Meeting_Unique_Id__c = InterRecord.Meeting_Unique_Id__c;
                aoActivity.Meeting_Url__c = InterRecord.Meeting_Url__c;
                aoActivity.StartTime__c = InterRecord.CreatedDate;
                aoActivity.End_DateTime__c = InterRecord.End_Time__c;
                aoActivity.Interview__c = InterRecord.Id;
                aoActivity.Lead__c = InterRecord.Lead__c;
                aoActivitiesToBeInsert.add(aoActivity);
            }
        }
        
        if(!aoActivitiesToBeInsert.isEmpty()){
            insert aoActivitiesToBeInsert;
        }
    }

    public static void CreateNextMeetingLinkForSM(Map<Id, Interview__c> newMapInterview , Map<Id, Interview__c> oldMapInterview) {

        System.debug('newMapInterview =====> ' + newMapInterview);
        System.debug('oldMapInterview =====> ' + oldMapInterview);
        Set<String> InterviewIds = new Set<String>();
        Map<Id,Interview__c> mapofInterviewerIdByInterviewId = new Map<Id,Interview__c>();
        if (!newMapInterview.isEmpty()) {
            for (Interview__c InterRecord : newMapInterview.values()) {
                if (InterRecord.Status__c != null && InterRecord.Status__c != oldMapInterview.get(InterRecord.Id).Status__c && (InterRecord.Status__c == 'Accepted' || InterRecord.Status__c == 'Rejected' || InterRecord.Status__c == 'Missed' || InterRecord.Status__c == 'Interviewer Missed' || InterRecord.Status__c == 'Completed')){
                    InterviewIds.add(InterRecord.Interviewer__c);
                    mapofInterviewerIdByInterviewId.put(InterRecord.Interviewer__c,InterRecord);
                }
            }
            System.debug('InterviewIds ======> ' + InterviewIds);
            System.debug('InterviewIds =====>' + InterviewIds.size());
            if (!InterviewIds.isEmpty()) {
                for (String InterviewId : InterviewIds) {
                    CallingSMLinkGeneratorInFuture.SMLinkGenratorInFuture(InterviewId);
                }
            }
        }
    }

    public static void updateIntervieStatusToBackend(Map<Id, Interview__c> newMapInterview , Map<Id, Interview__c> oldMapInterview) {

        System.debug('newMapInterview =====> ' + newMapInterview);
        System.debug('oldMapInterview =====> ' + oldMapInterview);
        Set<String> InterviewIds = new Set<String>();

        if (!newMapInterview.isEmpty()) {
            system.debug('Inside newmapinterview');
            for (Interview__c InterRecord : newMapInterview.values()) {
                system.debug('inside for loop');
                if (InterRecord.Status__c != null && InterRecord.Status__c != oldMapInterview.get(InterRecord.Id).Status__c && (InterRecord.Status__c == Constant.INTERVIEW_STATUS_INTERVIEW_MISSED || InterRecord.Status__c == 'Accepted' || InterRecord.Status__c == 'Rejected' || InterRecord.Status__c == 'Missed' || InterRecord.Status__c == 'Completed')){ //|| InterRecord.Status__c == 'Qualified' || InterRecord.Status__c == 'Disqualified'
                    InterviewIds.add(InterRecord.Id);
                }
                system.debug('InterviewIds::'+InterviewIds);
            }
            Callout_Interview_Response.sendInterviewStatusUpdate(InterviewIds);
        }
        
    }
    
    public static void assignCounsellorLogic(List<Interview__c> interviewList,Map<Id, Interview__c> oldMapInterview){
        Set<Id> leadIdSet = New Set<Id>();
        for(Interview__c intRec : interviewList){
            if((intRec.Status__c == 'Accepted' || intRec.Status__c == 'Rejected') && intRec.Status__c != oldMapInterview.get(intRec.Id).Status__c){
                leadIdSet.add(intRec.Lead__c);
            }
        }
        
        if(!leadIdSet.isEmpty()){
            List<Lead> leadList = [select id,ownerId from Lead where id in: leadIdSet ];
            if(!leadList.isEmpty()){
                CounsellorsAssignmentModule.counsellorAssignmentLogic(leadList);
            }
        }
    }

}