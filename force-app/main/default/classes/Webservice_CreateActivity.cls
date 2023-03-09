@RestResource(urlMapping='/activity_creation_event/*')
global class Webservice_CreateActivity {
    global static list<object> ob = new list<object>();
    @HttpPost
    global static ActivityModel.ReponseWrapper createActivityAgainstLead(){
        
        system.debug('RestContext.request.requestBody.tostring()::'+RestContext.request.requestBody.tostring());
        
        map<string,string> mapofUseridByLeadid = new map<string,string>();
        Map<String,String> leadOwnerIdByLearnerUID = new Map<String,String>();
        map<string,ActivityModel.ActivityDetails> mapofUseridByUseractRec = new map<string,ActivityModel.ActivityDetails>();
        list<task> activityListTobeInsert = new list<task>();
        set<string> userUniqueId = new set<string>();
        list<lead> leadList = new list<lead>();
        List<Object> activityWithoutLeadRec = new list<object>();
        ActivityModel.ReponseWrapper responseData = new ActivityModel.ReponseWrapper();
        String JSONInput = RestContext.request.requestBody.tostring();
        List<Object> activityRequestList = (List<Object>) JSON.deserializeUntyped(JSONInput);
        list<ActivityModel.failuredata> failureList = new list<ActivityModel.failuredata>();
        try{
             if(!activityRequestList.isEmpty()){
                            for(object obj : activityRequestList){
                                map<string,object> temp = (map<string,object>)obj;
                                if(temp.get('search_by_value') != null){
                                    userUniqueId.add(String.valueOf(temp.get('search_by_value')));  
                                }
                            }
                            leadList = [select id,Learner_Uid__c,OwnerId,Owner_Email__c  from lead where Learner_Uid__c in: userUniqueId];
                            for(lead ld : leadList){
                                mapofUseridByLeadid.put(ld.Learner_Uid__c,ld.Id);
                                if(ld.Owner_Email__c != null){
                                    leadOwnerIdByLearnerUID.put(ld.Learner_Uid__c,ld.OwnerId);
                                }
                            }
                            for(object obj : activityRequestList){
                                map<string,object> temp = (map<string,object>)obj;
                                System.debug(mapofUseridByLeadid.get(String.valueOf(temp.get('search_by_value'))));
                                System.debug(String.valueOf(temp.get('search_by_value')));
                                if(mapofUseridByLeadid.get(String.valueOf(temp.get('search_by_value'))) == null){
                                    activityWithoutLeadRec.add(obj);
                                    continue;
                                }
                                /*if(mapofUseridByLeadid.get(String.valueOf(temp.get('search_by_value')) == null){
                                    /*do remove operation
                                }*/
                                task ts = new task();
                                if(temp.get('activity_type') != null)
                                    ts.Activity_Type__c = String.valueOf(temp.get('activity_type'));
                                if(temp.get('search_by_value') != null)
                                    ts.Search_By_Value__c = String.valueOf(temp.get('search_by_value'));
                                if(mapofUseridByLeadid.get(ts.Search_By_Value__c) != null)
                                    ts.whoId = mapofUseridByLeadid.get(ts.Search_By_Value__c);
                                if(temp.get('activity_type') != null)
                                    ts.subject  = String.valueOf(temp.get('activity_type'));
                                if(temp.get('activity_datetime') != null)
                                    ts.Activity_date_time__C = (DateTime)JSON.deserialize('"' + String.valueOf(temp.get('activity_datetime')) + '"', DateTime.class);
                                system.debug('ts.Activity_date_time__C-->'+ts.Activity_date_time__C);
                                if(temp.get('state') != null)
                                    ts.State__c = string.valueOf(temp.get('state'));
                                if(temp.get('email') != null)
                                    ts.Email__c = String.valueOf(temp.get('email'));
                                if(temp.get('exam_name') != null)
                                    ts.Exam_Name__c = String.valueOf(temp.get('exam_name'));
                                if(temp.get('exam_slug') != null)
                                    ts.Exam_Slug__c = String.valueOf(temp.get('exam_slug'));
                                if(temp.get('exam_date') != null)
                                    ts.Exam_Date__c = (DateTime)JSON.deserialize('"' + String.valueOf(temp.get('exam_date')) + '"', DateTime.class);
                                if(temp.get('exam_booked_date') != null)
                                    ts.Exam_Booked_Date__c = (DateTime)JSON.deserialize('"' + String.valueOf(temp.get('exam_booked_date')) + '"', DateTime.class);
                                if(temp.get('exam_score') != null)
                                  ts.Exam_Score__c = String.valueOf(String.valueOf(temp.get('exam_score')));
                                if(temp.get('skill_based_exam_score') != null)
                                  ts.Skill_Based_Exam_Score__c = String.valueOf(temp.get('skill_based_exam_score'));
                                if(temp.get('is_qualified_in_exam') != null)
                                    ts.Is_Qualified_in_Exam__c = Boolean.valueOf(temp.get('is_qualified_in_exam'));
                                if(temp.get('course_name') != null)
                                    ts.Course_Name__c = String.valueOf(temp.get('course_name'));
                                if(temp.get('course_id') != null)
                                    ts.Course_Id__c = String.valueOf(temp.get('course_id'));
                                if(temp.get('Course_Slug__c') != null)
                                    ts.Course_Slug__c = String.valueOf(temp.get('Course_Slug__c'));
                                if(temp.get('student_availability') != null)
                                    ts.Student_Availability__c = (DateTime)JSON.deserialize('"' + String.valueOf(temp.get('student_availability')) + '"', DateTime.class);
                                if(temp.get('payment_failure_reason') != null)
                                    ts.Payment_Failure_Reason__c = String.valueOf(temp.get('payment_failure_reason '));
                                if(temp.get('payment_type') != null)
                                    ts.Payment_type__c = String.valueOf(temp.get('payment_type'));
                                if(temp.get('payment_amount') != null)
                                    ts.Payment_Amount__c = Decimal.valueOf(String.valueOf(temp.get('payment_amount')));
                                if(temp.get('date_of_payment') != null)
                                    ts.Date_of_Payment__c = (DateTime)JSON.deserialize('"' + String.valueOf(temp.get('date_of_payment')) + '"', DateTime.class);
                                if(temp.get('revenue') != null)
                                    ts.Revenue__c = Decimal.valueOf(String.valueOf(temp.get('revenue')));
                                if(temp.get('mobile') != null)
                                    ts.Mobile__c = String.valueOf(temp.get('mobile'));
                                if(temp.get('user_id') != null)
                                    ts.User_Id__c = String.valueOf(temp.get('user_id'));
                                if(temp.get('redirect_url') != null)
                                    ts.Redirect_Url__c = String.valueOf(temp.get('redirect_url'));
                                if(temp.get('cohort_id') != null)
                                    ts.Cohort_Id__c = String.valueOf(temp.get('cohort_id'));
                                if(temp.get('cohort_name') != null)
                                    ts.Cohort_Name__c = String.valueOf(temp.get('cohort_name'));
                                if(temp.get('tier_info') != null)
                                    ts.Tier_Info__c = String.valueOf(temp.get('tier_info'));
                                
                                if(leadOwnerIdByLearnerUID.containsKey(String.valueOf(temp.get('search_by_value'))))
                                    ts.OwnerId = leadOwnerIdByLearnerUID.get(String.valueOf(temp.get('search_by_value')));
                                    ts.Status = 'Completed';
                                activitylisttobeInsert.add(ts);
                            }
                        }
    
                        System.debug('ActivitylistTobeinsert::'+activityListTobeInsert);
                        if(!activityListTobeInsert.isEmpty()){
                            responseData.success_activity = new list<task>();
                            //responseData.failed_activity = new list<task>();
                            responseData.failed_activity_list = new list<ActivityModel.failuredata>();
                            Database.saveResult[] results =  database.Insert(activityListTobeInsert,false);
                            for(Integer index = 0, size = results.size(); index < size; index++){
                                if(results[index].isSuccess()){
                                    responseData.success_activity.add(activityListTobeInsert[index]);
                                }else{
                                    list<Database.Error> err = results[index].getErrors(); 
                                    ActivityModel.failuredata error = new ActivityModel.failuredata();
                                    system.debug('errerrerr::'+err);
                                    //responseData.failed_activity.add(activityListTobeInsert[index]);
                                    error.failed_activity = activityListTobeInsert[index];
                                    error.error_reason = err[0].getMessage();
                                    failureList.add(error);
                                }
                            }
                        }
                        //ob = activityWithoutLeadRec;
                        system.debug('activityWithoutLeadRec::'+activityWithoutLeadRec);
                        if(!failureList.isEmpty()){
                            responseData.failed_activity_list = failureList;
                        }
                        responseData.activity_without_lead = JSON.serialize(activityWithoutLeadRec);
                        responseData.success_code = '200';
                        //responseData.success_message = 'Activity record has been created.';
                
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString()+'---'+e.getMessage());
            responseData.error_code = '400';
            responseData.error_message = e.getStackTraceString();
            
        }
        return responseData;
    }
    
}