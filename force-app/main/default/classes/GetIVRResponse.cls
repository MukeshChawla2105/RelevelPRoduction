global class GetIVRResponse implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        DateTime systemNow = System.now();
        
        String query = 'SELECT id,wk_exo__call_sid__c,wk_exo__exotel_dial_status__c,status FROM Task WHERE Activity_Type__c = \'IVR Call\' AND Status = \'Open\' AND wk_exo__call_sid__c != null limit 49000';
        List<Task> taskList =  Database.query(query);
        
         if(!taskList.isEmpty()){
            System.enqueueJob(new AsyncHelperForIVRResponse(taskList,0,1));
        }
       
    }
}