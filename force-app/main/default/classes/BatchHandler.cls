public class BatchHandler {
	
    public static void updateLeadRecord(Map<Id,Task> newTaskMap){
        try{
            system.debug('newTaskMap::'+newTaskMap);
            List<Lead> LeadListToUpdate = New List<Lead>();
            List<Lead> leadList = new list<Lead>();
            set<string> leadIdset = New set<string>();
            
            for(task task:newTaskMap.values()){
                    leadIdset.add(task.WhoId);
            }
            system.debug('leadIdset::'+leadIdset);
            if(leadIdset.size() > 0){
                leadList = [select id,Talk_Time__c,Talk_Time_Last_30_Days__c,Call_Count__c,Total_Calls_Last_30_Days__c,(select id,wk_exo__Total_Talk_Time__c,Call_Duration__c,wk_exo__Exotel_Call_Type__c,wk_exo__exotel_dial_status__c ,Status,wk_exo__call_end_time__c,wk_exo__call_start_time__c,CreatedDate from tasks) from lead where id IN :leadIdset];
                system.debug('leadList::'+leadList);
                system.debug('size::'+leadList.size());
                if(!leadList.isEmpty()){
                    for(lead ld:leadList){
                        double totalConnectedTime = 0;
                        double totalTime = 0;
                        double totalTimeLastMonth = 0;
                        Integer totalConnectedTask = 0;
                        Integer totalTask = 0;
                        Integer totalTaskLastMonth = 0;
                        Integer totalTaskIn30Days;
                        Integer totalTimeIn30Days;
                        for(task tsk:ld.tasks){
                            
                            if(tsk.wk_exo__exotel_dial_status__c != null && tsk.wk_exo__Total_Talk_Time__c != null){   
                                totalTask += 1;
                                if(tsk.Call_Duration__c == null)
                                    tsk.Call_Duration__c = 0;
                                totalTime += tsk.Call_Duration__c;
                                if(tsk.CreatedDate > date.today().adddays(-30)){
                                    totalTimeLastMonth += integer.valueOf(tsk.wk_exo__Total_Talk_Time__c);
                                    totalTaskLastMonth += 1;
                                }
                                system.debug('tsk.wk_exo__exotel_dial_status__c::'+tsk.wk_exo__exotel_dial_status__c);
                                system.debug('tsk.wk_exo__Exotel_Call_Type__c::'+tsk.wk_exo__Exotel_Call_Type__c);
                                if(integer.valueOf(tsk.wk_exo__Total_Talk_Time__c) > 0){
                                    totalConnectedTask += 1;
                                    system.debug(totalConnectedTask);
                                    totalConnectedTime += integer.valueOf(tsk.wk_exo__Total_Talk_Time__c);
                                    //totalTime += tsk.Call_Duration__c;
                                }
                            }
                        }
                        ld.Connected_Call_Time_in_Seconds__c = totalConnectedTime;
                        ld.Call_Count__c = totalConnectedTask;
                        ld.Total_Call_Count__c = totalTask;
                        //ld.Last_Connected_Date__c = Date.today();
                        ld.Total_Calls_Last_30_Days__c = totalTaskLastMonth;
                        ld.Talk_Time_Last_30_Days__c = totalTimeLastMonth;
                        ld.Talk_Time__c = totalTime;
                        LeadListToUpdate.add(ld);
                    }
                    system.debug('LeadListToUpdate::'+LeadListToUpdate);
                    if(LeadListToUpdate.size() > 0)
                        update LeadListToUpdate;
                } 
            }
        }
        catch(exception ex ){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>@@'+ex.getLineNumber());
        }
    }
}