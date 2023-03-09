public class RedirectToMeetingHelper {
    @AuraEnabled
    public static string captureMeetingClickTime(string recordId){
        Task taskRec = new Task();
        Event eventRec = new Event();
        string meetingURL ='';
        
        if(string.valueOf(recordId).startsWith('00T')){
            taskRec = [Select Id,Meeting_URL__c,Meeting_URL_Click_Time__c From Task where Id =: recordId];
            taskRec.Meeting_URL_Click_Time__c = system.now();
            meetingURL = taskRec.Meeting_URL__c;
            update taskRec;
            
        }else if(string.valueOf(recordId).startsWith('00U')){
            eventRec = [Select Id,Meeting_URL__c,Meeting_URL_Click_Time__c From Event where Id =: recordId];
            eventRec.Meeting_URL_Click_Time__c = system.now();
            meetingURL = eventRec.Meeting_URL__c;
            update eventRec;
        }
        
        return meetingURL;
    }
}