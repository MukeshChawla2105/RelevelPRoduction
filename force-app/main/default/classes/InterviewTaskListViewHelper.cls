public without sharing class InterviewTaskListViewHelper{
    @AuraEnabled
    public static List<taskWrap> getAllInterviewTask(){
        string currentUserId = UserInfo.getUserId();
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();
        List<taskWrap> taskwarpList = new List<taskWrap>();
        Map<Id, Task> taskByLeadIdMap = new Map<Id, Task>();
        Map<Id, Lead> leadByIdMap = new Map<Id, Lead>();
        
        taskList = [Select Id,Subject,Who.Name,Meeting_URL__c,CreatedDate,WhoId,Owner.name,status,priority,Beep_Effect__c From Task where  Subject =: system.label.Interview_Task_Subject AND ownerId =: currentUserId and (status = 'Open' or Status = 'Completed') order by CreatedDate Desc ];//ownerId =: currentUserId AND CreatedDate >: system.today()];
//ownerId =: currentUserId AND CreatedDate >: system.today()];
        system.debug('taskList-->'+taskList); /*
taskList = [Select Id, Subject, Who.Name, Meeting_URL__c, CreatedDate, WhoId, Owner.name, status, priority, Beep_Effect__c
From Task
where Subject = :system.label.Interview_Task_Subject AND ownerId = :currentUserId and (status = 'Open' or Status = 'Completed')
order by CreatedDate Desc];//ownerId =: currentUserId AND CreatedDate >: system.today()];
*///taskList = [Select Id,Subject,Who.Name,Meeting_URL__c,CreatedDate,WhoId,Owner.name,status,priority From Task where Subject = 'New Interview Scheduled' limit 11 ];//ownerId =: currentUserId AND CreatedDate >: system.today()];
        if (!taskList.isEmpty()){
            for (Task taskRec : taskList){
                taskByLeadIdMap.put(taskRec.WhoId, taskRec);
            }
            if (!taskByLeadIdMap.isEmpty()){
                leadByIdMap = new Map<Id, Lead>([Select Id, Name, Email, Phone, Course_Name__c,Owner.Name, OwnerId, Interview_Feedback_Notes_AO__c, Total_Calls_After_Admission__c, Connected_calls_After_Admission__c
                                                 From lead
                                                 where Id in:taskByLeadIdMap.keyset()]);
                if (!leadByIdMap.isEmpty() && !taskByLeadIdMap.isEmpty()){
                    for (Task taskRec : taskByLeadIdMap.values()){
                        taskWrap taskwarpRec = new taskWrap(taskRec.who.Name, taskRec.subject
                                                            , taskRec.CreatedDate,taskRec.Owner.name, taskRec.status
                                                            , taskRec.priority, taskRec.Meeting_URL__c, leadByIdMap.get(taskRec.WhoId).Course_Name__c,leadByIdMap.get(taskRec.WhoId).owner.Name, 
                                                            leadByIdMap.get(taskRec.WhoId).Interview_Feedback_Notes_AO__c,
                                                            leadByIdMap.get(taskRec.WhoId).Connected_calls_After_Admission__c, leadByIdMap.get(taskRec.WhoId).Total_Calls_After_Admission__c, 
                                                            taskRec.Beep_Effect__c, taskRec.WhoId, taskRec.Id);
                        
                        /*taskwarpRec.name = taskRec.who.Name;
taskwarpRec.subject = taskRec.subject;
taskwarpRec.assignedDate = taskRec.CreatedDate;
taskwarpRec.assignedTo = taskRec.Owner.name;
                        taskwarpRec.status = taskRec.status;
                        taskwarpRec.priority = taskRec.priority;
                        taskwarpRec.meetingLink = taskRec.Meeting_URL__c;
                        taskwarpRec.beepEffect = taskRec.Beep_Effect__c;
                        taskwarpRec.leadId = taskRec.WhoId;
                        taskwarpRec.taskId = taskRec.Id;
                        taskwarpRec.courseName = leadByIdMap.get(taskRec.WhoId).Course_Name__c;
                        taskwarpRec.acName = leadByIdMap.get(taskRec.WhoId).owner.Name;
                        taskwarpRec.interviewFeedbackNotesAO = leadByIdMap.get(taskRec.WhoId).Interview_Feedback_Notes_AO__c;
                        taskwarpRec.connectedCallPostInterview = leadByIdMap.get(taskRec.WhoId).Connected_calls_After_Admission__c;
                        taskwarpRec.totalcallsPostInterview = leadByIdMap.get(taskRec.WhoId).Total_Calls_After_Admission__c;*/
                        taskwarpList.add(taskwarpRec);
                    }
                }
            }
        }
        system.debug('taskwarpList-->'+taskwarpList);
        return taskwarpList;
    }
    
    @AuraEnabled
    public static void updateSoundField(List<taskWrap> taskwarpList){
        system.debug('taskwarpList-->'+taskwarpList);
        List<Task> taskListToUpdate = new List<Task>();
        if(!taskwarpList.isEmpty()){
            for(taskWrap taskWrapRec : taskwarpList){
                system.debug('taskWrapRec.beepEffect-->'+taskWrapRec.beepEffect);
                if(taskWrapRec.beepEffect == false){
                    Task taskRecToUpdate = new Task();
                    taskRecToUpdate.Id = taskWrapRec.taskId;
                    taskRecToUpdate.Beep_Effect__c = true;
                    taskListToUpdate.add(taskRecToUpdate);
                }
            }
            system.debug('taskListToUpdate-->'+taskListToUpdate);
            if(!taskListToUpdate.isEmpty()){
                update taskListToUpdate;
            }
        }
        /* List<Task> taskListToUpdate = new List<Task>();

if (!taskList.isEmpty()){
for (Task taskRec : taskList){
if (taskRec.Beep_Effect__c == false){
Task taskRecToUpdate = new Task();
taskRecToUpdate.Id = taskRec.Id;
taskRecToUpdate.Beep_Effect__c = true;
taskListToUpdate.add(taskRecToUpdate);
}
}
if (!taskListToUpdate.isEmpty()){
update taskListToUpdate;
}
}*/
    }
    
    public class taskWrap{
         @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String subject{get;set;}
        @AuraEnabled
        public DateTime assignedDate{get;set;}
        @AuraEnabled
        public String assignedTo{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String priority{get;set;}
        @AuraEnabled
        public String meetingLink{get;set;}
        @AuraEnabled
        public String courseName{get;set;}
        @AuraEnabled
        public String acName{get;set;}
        @AuraEnabled
        public String interviewFeedbackNotesAO{get;set;}
        @AuraEnabled
        public Decimal connectedCallPostInterview{get;set;}
        @AuraEnabled
        public Decimal totalcallsPostInterview{get;set;}
        @AuraEnabled
        public boolean beepEffect{get;set;}
        @AuraEnabled
        public string leadId{get;set;}
        @AuraEnabled
        public string taskId{get;set;}
        public taskWrap(){
            
        }
        public taskWrap(String name, string subject, DateTime assignedDate,String assignedTo, String status, String priority, String meetingLink, String courseName,String acName, String interviewFeedbackNotesAO,Decimal connectedCallPostInterview, Decimal totalcallsPostInterview, boolean beepEffect, string leadId, string taskId){
            this.name = name;
            this.subject = subject;
            this.assignedDate = assignedDate;
            this.assignedTo = assignedTo;
            this.status = status;
            this.priority = priority;
            this.meetingLink = meetingLink;
            this.courseName = courseName;
            this.acName = acName;
            this.interviewFeedbackNotesAO = interviewFeedbackNotesAO;
            this.connectedCallPostInterview = connectedCallPostInterview;
            this.totalcallsPostInterview = totalcallsPostInterview;
            this.beepEffect = beepEffect;
            this.leadId = leadId;
            this.taskId = taskId;
        }
    }
}