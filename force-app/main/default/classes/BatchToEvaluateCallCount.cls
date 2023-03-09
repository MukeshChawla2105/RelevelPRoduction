public class BatchToEvaluateCallCount implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date augDate = date.newInstance(2022, 08, 23);
        Date todaydate = system.today();
        String query = system.label.CallCountQuery;// 'Select id,Send_Admission_Letter_Yes_Date_Time__c,Send_Admission_Letter_No_DAte_Time__c,(select Id,wk_exo__Total_Talk_Time__c,CallDurationInSeconds,Activity_Date_Time__c from Tasks Where Status = \'Completed\' AND wk_exo__call_sid__c!= null )  From Lead where id = \'00Q0w000005lnb4EAA\''; //Last_Connected_Date__c >=: augDate';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList){
        system.debug('leadList::' + leadList);
        List<Lead> leadlistToBeUpdated = new List<Lead>();
        if (!leadList.isEmpty()){
            for (Lead ld : leadList){
                lead leadToBeUpdated = new lead();
                leadToBeUpdated.id = ld.Id;
                
                integer callTime = 0;
                integer talkTime = 0;
                integer totalCall = 0;
                integer connectedCallCount = 0;
                integer preTotalCount = 0, preCallDuaration = 0, preConnectedCall = 0;
                integer postTotalCount = 0, postCallDuration = 0, postConnectedCall = 0;
                
                for (Task taskRec : ld.Tasks){
                    //Total Call
                    totalCall += 1;
                    //CAll duration
                    callTime += integer.valueOf(taskrec.CallDurationInSeconds) > 0 ? integer.valueOf(taskrec.CallDurationInSeconds) : 0;
                    //connected CAll
                    if (taskRec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                        connectedCallCount += 1;
                        //Connected Call Duration
                        talkTime += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                    }
                    // Pre calls
                    if (taskRec.Activity_Date_Time__c < ld.Send_Admission_Letter_Yes_Date_Time__c || taskRec.Activity_Date_Time__c < ld.Send_Admission_Letter_No_DAte_Time__c ||(ld.Send_Admission_Letter_Yes_Date_Time__c == null && ld.Send_Admission_Letter_No_DAte_Time__c == null ) ){
                        //Pre Total Call
                        preTotalCount +=1;
                        if(taskRec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                            //Pre Connected Call
                            preConnectedCall += 1;
                            //Pre connected call duration
                            preCallDuaration += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                        }
                        
                    }
                    // Post Call
                    if (taskRec.Activity_Date_Time__c > ld.Send_Admission_Letter_Yes_Date_Time__c || taskRec.Activity_Date_Time__c > ld.Send_Admission_Letter_No_DAte_Time__c){
                        //POst Total Call
                        postTotalCount += 1;
                        if(taskRec.wk_exo__Total_Talk_Time__c != null && integer.valueOf(taskRec.wk_exo__Total_Talk_Time__c) > 0){
                            //Post Connected Call
                            postConnectedCall += 1;
                            //Post ConnectedCall duration
                            postCallDuration += integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) > 0 ? integer.valueOf(taskrec.wk_exo__Total_Talk_Time__c) : 0;
                        }
                    }
                }
                
                leadToBeUpdated.Talk_Time__c = callTime ;
                leadToBeUpdated.Connected_Call_Time_in_Seconds__c = talkTime ;
                leadToBeUpdated.Total_Call_Count__c = totalCall ;
                leadToBeUpdated.Call_Count__c = connectedCallCount;
                leadToBeUpdated.Total_Calls_after_assigned__c = preTotalCount;
                leadToBeUpdated.Connected_calls_After_Assigned__c =  preConnectedCall;
                leadToBeUpdated.Total_call_Duration_After_assigned__c =  preCallDuaration;
                leadToBeUpdated.Total_Calls_After_Admission__c =  postTotalCount;
                leadToBeUpdated.Connected_calls_After_Admission__c =  postConnectedCall;
                leadToBeUpdated.Total_call_Duration_After_admission__c =  postCallDuration;
                leadlistToBeUpdated.add(leadToBeUpdated);
            }
        }
        update leadlistToBeUpdated;
    }
    
    public void finish(Database.BatchableContext BC){
        // execute any post-processing operations like sending email
    }
    
}