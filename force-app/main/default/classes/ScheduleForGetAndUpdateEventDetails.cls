global class ScheduleForGetAndUpdateEventDetails implements Schedulable {
    // Every 15 Minute
    // '0 15 * * * *'
    global void execute(SchedulableContext ctx) {
        
        String query = 'Select Id, Description, Event_Description__c, GMeet_Event_Id__c, Attendees__c, Recording_URL__c, whoId, meeting_Url_Charcter__c From Event Where Type = \'Google Meet\' AND Event_Status__c = \'Open\' limit 150';
        List<Event> eventList =  Database.query(query);
        system.debug('eventList-->'+eventList.size());
        if(!eventList.isEmpty()){
            System.enqueueJob(new AsyncHelperForGmeetTask(eventList,0,1));
        }
        
    }
}