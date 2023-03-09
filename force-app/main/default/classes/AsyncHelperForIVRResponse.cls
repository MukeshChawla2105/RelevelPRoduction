public class AsyncHelperForIVRResponse implements Queueable,Database.AllowsCallOuts{
    List<Task> taskList = New List<Task>();
    List<Task> taskListTobeUpdate = new List<Task>();
    integer startIndex;
    integer endIndex;
    
    public AsyncHelperForIVRResponse(List<Task> taskList,integer startIndex,integer endIndex){
        this.taskList = taskList;
        this.startIndex = startIndex;
        this.endIndex = endIndex;
    }
    
    public void execute(QueueableContext context){
       for(integer i = startIndex;i< endIndex;i++){
           Http http = new Http();
           HttpRequest request = new HttpRequest(); 
           request.setEndpoint('https://8cf47d160c162af8050e7961f3bf92939511de56f5f7d112:4f67d50f93b01c505019335fb12b5892d23c2b8f880fdc2e@api.exotel.com/v1/Accounts/relevel2/Calls/'+taskList[i].wk_exo__call_sid__c+'.json');
           request.setMethod('GET');
           
           request.setHeader('Authorization','Basic  '+'OGNmNDdkMTYwYzE2MmFmODA1MGU3OTYxZjNiZjkyOTM5NTExZGU1NmY1ZjdkMTEyOjRmNjdkNTBmOTNiMDFjNTA1MDE5MzM1ZmIxMmI1ODkyZDIzYzJiOGY4ODBmZGMyZQ==');
           HttpResponse response = http.send(request);
           
           if (response.getStatusCode() != 201) {
               System.debug('The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus());
           }
           if(response.getStatusCode() == 200){
               
               System.debug('Response Body 1 ::'+response.getBody());
               string ResponseString = string.valueOf(response.getBody());
               Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(ResponseString);
               system.debug('m-->'+m);
               Map<String,Object> callDetails = (Map<String,Object>)m.get('Call');
               String status  = (String) callDetails.get('Status');
               if(status != 'in-progress'){
                   Task taskRecToUpdate = new Task();
                   taskRecToUpdate.Id = taskList[i].Id;
                   taskRecToUpdate.wk_exo__exotel_dial_status__c = status;
                   taskRecToUpdate.status = 'Completed';
                   taskListTobeUpdate.add(taskRecToUpdate);
                   update taskListTobeUpdate;
               }
           }
        }
        startIndex = endIndex;
        endIndex = endIndex + 1;
        system.debug('taskListTobeUpdate-->'+taskListTobeUpdate);

        if(startIndex < taskList.size()){
            system.debug('Enqueue Job');
            System.enqueueJob(new AsyncHelperForIVRResponse(taskList,startIndex,endIndex));
        }
    } 
}