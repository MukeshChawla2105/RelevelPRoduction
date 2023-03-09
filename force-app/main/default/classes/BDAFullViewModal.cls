public without Sharing class BDAFullViewModal{
    public static list<Lead> GetLead(String UserId){
        list<Lead> LeadRecord = [Select id, createdDate, name, LeadSource, Lead_Stage__c, Lead_status__c
                                 From lead
                                 where OwnerId = :UserId];
        return LeadRecord;
    }

    public static List<Task> GetTask(String UserId, date DateTobeQuery){

        DateTime startDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 0, 0, 1);
        DateTime EndDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 23, 59, 59);
        List<Task> taskRecord = [Select id, whoId,who.name, owner.name,ownerId, CreatedDate, Subject, Description, Activity_Date_Time__c, Activity_Type__c, Call_Duration__c, Email__c, wk_exo__call_start_time__c, wk_exo__call_end_time__c, wk_exo__Call_Description__c, wk_exo__call_sid__c, wk_exo__Total_Talk_Time__c, CallDurationInSeconds
                                 from task
                                 where (OwnerId = :UserId AND CreatedDate >= :startDT And CreatedDate <= :EndDT) and (Activity_Type__c != Null OR wk_exo__call_sid__c != NUll)];
        return taskRecord;
    }
    public static list<LeadHistory> GetLeadHistoryChange(String UserId, date DateTobeQuery){

        DateTime startDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 0, 0, 1);
        DateTime EndDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 23, 59, 59);
        list<LeadHistory> LeadHistoryRecord = [SELECT CreatedById, CreatedDate, DataType, Field, Id, IsDeleted, LeadId, NewValue, OldValue
                                               FROM LeadHistory
                                               Where lead.OwnerId = :UserId AND CreatedDate >= :startDT And CreatedDate <= :EndDT];
        return LeadHistoryRecord;
    }

    public static list<User_Tracking__c> GetUserTracking(String UserId, date DateTobeQuery){
                                             

        DateTime startDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 0, 0, 1);
        DateTime EndDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 23, 59, 59);
        //list<User_Tracking__History> userTrackingHistoryRecord = [SELECT Field,NewValue,OldValue,ParentId, CreatedDate, CreatedById
        //                                                          FROM User_Tracking__History
        //                                                          Where CreatedById = :userId AND CreatedDate >= :startDT And CreatedDate <= :EndDT
        //                                                          order by CreatedDate Asc];
        list<User_Tracking__c> UserTrackingRecord = [SELECT Call_Duration__c, Call_Time_in_Sec__c, Checkin_Detatime__c, Checkout_Datetime__c, Check_in_Date__c
                                                    FROM User_Tracking__c
                                                    Where CreatedById = :userId AND CreatedDate >= :startDT And CreatedDate <= :EndDT];
        return UserTrackingRecord;
    }

    public static List<EmailMessage> GetEmailSentList(String UserId, date DateTobeQuery){

        DateTime startDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 0, 0, 1);
        DateTime EndDT = DateTime.newInstance(DateTobeQuery.year(), DateTobeQuery.month(), DateTobeQuery.day(), 23, 59, 59);
        List<EmailMessage> emailMessage = [SELECT CreatedById, FromName, Status, Subject, MessageDate, ToAddress
                                           FROM EmailMessage
                                           Where CreatedById = :UserId AND MessageDate >= :startDT And MessageDate <= :EndDT];
        return emailMessage;
    }

    @AuraEnabled
    public static List<sObject> userList(String searchKeyWord, String ObjectName){
        List<sObject> returnList = new List<sObject>();

        try{
            system.debug('ObjectName-->' + ObjectName);
            system.debug('searchKeyWord-->' + searchKeyWord);
            String searchKey = '\'%' + searchKeyWord + '%\'';

            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
            String sQuery = 'select id,Name, LastName, FirstName, ProfileId,IsActive from ' + ObjectName + ' where Name LIKE ' + searchKey + ' AND ProfileId = ' + '\'00e5j000000N0we\'' + ' order by Name Asc limit 5';
            List<sObject> lstOfRecords = Database.query(sQuery);

            for (sObject obj : lstOfRecords){
                returnList.add(obj);
            }
        } catch (Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage() + ' at line Number : ' + e.getLineNumber());
        }
        return returnList;
    }
}