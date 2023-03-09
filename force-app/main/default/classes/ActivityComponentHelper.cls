public class ActivityComponentHelper{
    @auraEnabled
    public static List<Task> fetchTasks(String leadId){
        List<Task> taskList = new List<Task>();
        if (!string.isBlank(leadId)){
            try{
                taskList = [SELECT Activity_Date_Time__c, Activity_Type__c, Stage_Changed__c, Subject, Status, Description, Id, Owner.Name, Is_Remarketing_Activity__c, Recording_Available__c, wk_exo__call_recording_url__c
                            FROM Task
                            WHERE WhoId = :leadId
                            ORDER BY CreatedDate DESC
                            NULLS LAST];
            } catch (exception ex){
                system.debug('Error==>' + ex.getMessage());
                system.debug('Error==>' + ex.getLineNumber());
            }
        }
        return taskList;
    }

    @auraEnabled
    public static List<Event> fetchEvents(String leadId){
        List<Event> EventList = new List<Event>();
        if (!string.isBlank(leadId)){
            try{
                EventList = [SELECT CreatedDate, EndDateTime, Id, Meeting_URL__c, StartDateTime, Subject, WhoId, type, Event_Status__c, Owner.Name
                             FROM Event
                             WHERE WhoId = :leadId
                             ORDER BY CreatedDate DESC
                             NULLS LAST];
            } catch (exception ex){
                system.debug('Error==>' + ex.getMessage());
                system.debug('Error==>' + ex.getLineNumber());
            }
        }
        return EventList;
    }

    @auraEnabled
    public static void updatetaskRecord(Task taskRec){
        try{
            update taskRec;
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>' + ex.getLineNumber());
        }
    }

    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String strObjectName, String strPicklistField){
        system.debug('strObjectName::' + strObjectName);
        system.debug('strPicklistField::' + strPicklistField);
        List<String> pickListValuesList = new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickListVal : lstPickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }
        system.debug('pickListValuesList::>' + pickListValuesList);
        return pickListValuesList;
    }

    @AuraEnabled
    public static List<task> fetchTask(String leadId){
        return [SELECT Activity_Date_Time__c, Activity_Type__c, Is_Remarketing_Activity__c, Subject, Status, Description, Id, Who.Name, Owner.Name
                FROM Task
                WHERE WhoId = :leadId];
    }

}