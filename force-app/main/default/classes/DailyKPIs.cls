public with sharing class DailyKPIs {
    public DailyKPIs() {
        
    }
    
    public static void calculateDailyKPIs(){
        calculateKPIByCourseIntrestedIn();
    }
    @auraEnabled
    public static void calculateKPIByCourseIntrestedIn(){
        
        List<String> courseValueList = new list<String>();
        list<lead> leadList = new list<lead>();
        list<lead> payedLeadList = new list<lead>();
        List<task> calledLeads = new list<task>();
        List<task> connectedLeads = new list<task>();
        String strObjectName = 'Lead';
        String strPicklistField = 'Goal_Interested_In__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        map<String,task> mapofLeadidByCalledtask = new map<String,task>();
        map<String,task> mapofLeadisByConnectedTask = new map<String,task>();
        map<string,Decimal> mapofLeadidByAVGTalk = new map<String,Decimal>();
        map<string,Decimal> mapofLeadidByAVGTalkETT = new map<String,Decimal>();
        map<string,Decimal> mapofLeadidByAVGTalkAHT = new map<String,Decimal>();
        map<string,decimal> mapofLeadoweIdByconnectCount = new map<string,decimal>();
        map<string,list<lead>> mapofCourseByLeads = new map<string,list<lead>>();
        map<string,list<lead>> mapofCourseByTodaysPayedLeads = new map<string,list<lead>>();
        
        list<Assignment_Group_Member__c> activeAGMList = new list<Assignment_Group_Member__c>();
        list<Daily_KPIs_By_Course__c> dkcListtobeInsert = new list<Daily_KPIs_By_Course__c>();
        list<User_Tracking__c>  userTracking = new list<User_Tracking__c>();
        set<string> attPerDay = new set<string>();
        set<string> ettPerDay = new set<string>();
        set<string> ahtPerday = new set<string>();
        set<string> activeBDAId = new set<String>();
        integer newLeadsCreatedToday;
        integer loggedInUser = 0;
        integer loggeroutUser = 0;
        integer loggedOutbefore = 0;
        integer noConnectAfterLoggedin = 0;
        decimal orderProjection = 0;
        decimal revenueProjection = 0;
        decimal effectiveETT = 0;
        decimal effectiveAHT = 0;
        String queueId ='';
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            courseValueList.add(objPickList.getValue());
        }
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = task.wk_exo__Exotel_Call_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Relevel Default Queue' limit 1].Id;
        userTracking = [select id,Member__c,Duration__c from User_Tracking__c where createddate = today];
        activeAGMList = [select id,Out_Of_Office__c,active__c,Group_Member__c from Assignment_Group_Member__c where active__c =true AND Out_Of_Office__c = False ];
        calledLeads = [select id,Call_Duration__c,wk_exo__Total_Talk_Time__c,wk_exo__Exotel_Call_Type__c,whoId,wk_exo__exotel_dial_status__c from task where wk_exo__Exotel_Call_Type__c in : pickListValuesList and whoId != null AND createddate = today AND CallDurationInSeconds >0 limit 50000 ];
        connectedLeads = [select id,Call_Duration__c,wk_exo__Total_Talk_Time__c,wk_exo__Exotel_Call_Type__c,whoId,wk_exo__exotel_dial_status__c from task where whoId != null and wk_exo__Total_Talk_Time__c != '0' and wk_exo__Total_Talk_Time__c != null AND createddate = today limit 50000] ;
        leadList = [select id,lead_stage__c,ownerId,Goal_Interested_In__c,Call_Count__c,Total_Call_Count__c,Payment_details__c,Temperature__c from lead where First_Activity_Date__c = today AND OwnerId != : queueId limit 50000];
        payedLeadList = [select id,lead_stage__c,ownerId,Goal_Interested_In__c,Call_Count__c,Total_Call_Count__c,Payment_details__c,Temperature__c from lead where Payment_Date__c = today AND Payment_details__c>0 limit 50000];
        newLeadsCreatedToday = [Select count() From lead where First_Activity_Date__c = today AND OwnerId != : queueId AND lead_stage__c = 'New' limit 50000];
        
        system.debug('leadList>>'+leadList.size());
        list<Daily_KPIs__c> dailyKPIs = new list<Daily_KPIs__c>();
        dailyKPIs = [select id,(select id,ATT_Day__c,Avg_talk_Time_Per_BD__c,Called_Conversion__c,Called_Leads__c,
                                Called_Percentage__c,Connect_Conversion__c,Connected_Leads__c,Connected_Percentage__c,Course_Interested_In__c,Early_Logged_Out__c,Effective_AHT__c,
                                Effective_ETT__c,Effective_Talk_Time__c,Effective_Talk_Time_AHT__c,Effective_Talk_Time_ETT__c,Lead_Conversion__c,Not_Checkedin__c,Not_Connected_After_Logged_In__c,
                                Order_Projection__c,Orders__c,Revenue__c,Revenue_Projection__c,Revenue_BD__c,Total_Leads__c from Daily_KPIs_By_Course__r) from Daily_KPIs__c where createddate =today limit 1];
        map<string,string> mapofDKCNameyDKCId = new map<string,string>();
        if(!dailyKPIs.isEmpty()){
            for(Daily_KPIs_By_Course__c DKPByCourse : dailyKPIs[0].Daily_KPIs_By_Course__r){
                mapofDKCNameyDKCId.put(DKPByCourse.Course_Interested_In__c,DKPByCourse.Id);
            }
        }
        
        if(!leadList.isEmpty()){
            for(lead ld : leadList){
                ahtPerday.add(ld.id);
                if(ld.ownerId != null){
                    if(mapofLeadoweIdByconnectCount.containsKey(ld.ownerId)){
                        decimal count = mapofLeadoweIdByconnectCount.get(ld.ownerId) + ld.Call_Count__c;
                        mapofLeadoweIdByconnectCount.put(ld.ownerId,count);
                    }else{ 
                        mapofLeadoweIdByconnectCount.put(ld.ownerId,ld.Call_Count__c);
                    }   
                }
                if(ld.lead_stage__c != 'Closed Won' && ld.lead_stage__c != 'Closed Lost' && ld.Goal_Interested_In__c != null){
                    attPerDay.add(ld.id);
                }
                if(ld.Goal_Interested_In__c != null){
                    if(mapofCourseByLeads.containsKey(ld.Goal_Interested_In__c)){
                        mapofCourseByLeads.get(ld.Goal_Interested_In__c).add(ld);
                    }else{
                        mapofCourseByLeads.put(ld.Goal_Interested_In__c,new list<lead>{ld});
                    }
                }
                if(ld.lead_stage__c != 'Closed Won' && ld.lead_stage__c != 'Closed Lost' && (ld.Temperature__c == 'Warm' || ld.Temperature__c == 'Hot')){
                    ettPerDay.add(ld.id);
                }
            }
        }
        if(!payedLeadList.isEmpty()){
            system.debug('payedLeadList>>'+payedLeadList.size());
            for(Lead ld : payedLeadList){
                if(ld.Goal_Interested_In__c != null){
                    if(mapofCourseByTodaysPayedLeads.containskey(ld.Goal_Interested_In__c)){
                        mapofCourseByTodaysPayedLeads.get(ld.Goal_Interested_In__c).add(ld);
                    }else{
                        mapofCourseByTodaysPayedLeads.put(ld.Goal_Interested_In__c,new list<lead>{ld});
                    }
                }
            }
        }
        system.debug('mapofCourseByTodaysPayedLeads>>'+mapofCourseByTodaysPayedLeads.size());
        if(!activeAGMList.isEmpty()){
            for(Assignment_Group_Member__c agm : activeAGMList){
                activeBDAId.add(agm.Group_Member__c);
            }
            
            if(!activeBDAId.isEmpty() && !userTracking.isEmpty()){
                loggeroutUser = activeBDAId.size() - userTracking.size();
                loggedInUser = userTracking.size();
            }
            
            if(!userTracking.isEmpty()){
                for(User_Tracking__c usTrc : userTracking){
                    // user loggedout in 2.5 hours only
                    if(usTrc.Duration__c != null && usTrc.Duration__c > 0 && usTrc.Duration__c < 2.50){
                        loggedOutbefore =+ 1;
                    }
                    if(mapofLeadoweIdByconnectCount.get(usTrc.Member__c) != null && mapofLeadoweIdByconnectCount.get(usTrc.Member__c) == 0){
                        noConnectAfterLoggedin =+ 1;
                    }
                }
            }
        }
        
        if(!calledLeads.isEmpty()){
            for(task ts : calledLeads){
                mapofLeadidByCalledtask.put(ts.whoId,ts);
            }
        }
        if(!connectedLeads.isEmpty()){
            for(task ts : connectedLeads){
                mapofLeadisByConnectedTask.put(ts.whoId,ts);
                
                if(attPerDay.contains(ts.whoId) && mapofLeadidByAVGTalk.containsKey(ts.whoId)){
                    decimal res = mapofLeadidByAVGTalk.get(ts.whoId) + Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c);
                    mapofLeadidByAVGTalk.put(ts.whoId,res);
                }else if(attPerDay.contains(ts.whoId)){
                    mapofLeadidByAVGTalk.put(ts.whoId,Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c));
                }
                if(ahtPerday.contains(ts.whoId) && mapofLeadidByAVGTalkAHT.containsKey(ts.whoId)){
                    decimal res = mapofLeadidByAVGTalkAHT.get(ts.whoId) + Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c);
                    mapofLeadidByAVGTalkAHT.put(ts.whoId,res);
                }else if(ahtPerday.contains(ts.whoId)){
                    mapofLeadidByAVGTalkAHT.put(ts.whoId,Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c));
                }
                if(ettPerDay.contains(ts.whoId) && mapofLeadidByAVGTalkETT.containsKey(ts.whoId)){
                    decimal res = mapofLeadidByAVGTalkETT.get(ts.whoId) + Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c);
                    mapofLeadidByAVGTalkETT.put(ts.whoId,res);
                }else if(ettPerDay.contains(ts.whoId)){
                    mapofLeadidByAVGTalkETT.put(ts.whoId,Decimal.valueOf(ts.wk_exo__Total_Talk_Time__c));
                }
            }
        }
        
        Decimal totalEffectiveSec = 0;
        Decimal totalEffectiveAHTSec = 0;
        Decimal totalEffectiveETTSec = 0;
        if(!courseValueList.isEmpty()){
            for(string course : courseValueList){
                system.debug('course::'+course);
                if(mapofCourseByLeads.get(course) != null){
                    Daily_KPIs_By_Course__c DKC = new Daily_KPIs_By_Course__c();
                    DKC.Course_Interested_In__c = course;
                    system.debug('course>>'+course);
                    for(lead ld : mapofCourseByLeads.get(course)){
                        system.debug('inside lead');
                        if(DKC.Total_Leads__c == null)
                            DKC.Total_Leads__c = 0;
                        //mapofCourseByLeads.get(course).size() -> outside this for loop
                        DKC.Total_Leads__c += 1;
                        
                        if(DKC.Called_Leads__c == null)
                            DKC.Called_Leads__c = 0;
                        if(mapofLeadidByCalledtask.get(ld.Id) != null)
                            DKC.Called_Leads__c += 1;//mapofLeadidByCalledtask.get(ld.Id).size();
                        system.debug('adas');
                        if(mapofLeadisByConnectedTask.get(ld.Id) != null){
                            if(DKC.Connected_Leads__c == null)
                                DKC.Connected_Leads__c = 0;
                            DKC.Connected_Leads__c += 1;//mapofLeadisByConnectedTask.get(ld.Id).size();
                        }
                        
                        if(DKC.Called_Leads__c != null && DKC.Total_Leads__c != null && DKC.Total_Leads__c != null)
                            DKC.Called_Percentage__c = (DKC.Called_Leads__c * 100)/ DKC.Total_Leads__c;
                        if(DKC.Connected_Leads__c != null && DKC.Called_Leads__c != null && DKC.Called_Leads__c != 0 && DKC.Connected_Leads__c != 0)
                            DKC.Connected_Percentage__c = (DKC.Connected_Leads__c * 100) / DKC.Called_Leads__c;
                        if(mapofLeadidByAVGTalk.get(ld.Id) != null && userTracking.size() > 0){
                            if(DKC.ATT_Day__c == null)
                                DKC.ATT_Day__c = 0;
                            DKC.ATT_Day__c += mapofLeadidByAVGTalk.get(ld.Id)/userTracking.size();
                        }
                        if(mapofLeadidByAVGTalkAHT.get(ld.Id) != null && userTracking.size() > 0){
                            if(DKC.Effective_AHT__c == null)
                                DKC.Effective_AHT__c = 0;
                            DKC.Effective_AHT__c += mapofLeadidByAVGTalkAHT.get(ld.Id)/userTracking.size();
                        }
                        if(mapofLeadidByAVGTalkETT.get(ld.Id) != null && userTracking.size() > 0){
                            if(DKC.Effective_ETT__c == null)
                                DKC.Effective_ETT__c = 0;
                            DKC.Effective_ETT__c += mapofLeadidByAVGTalkETT.get(ld.Id)/userTracking.size();
                        }
                        if(ld.Payment_details__c != null && ld.Payment_details__c > 0){
                            if(DKC.Orders__c == null){
                                DKC.Orders__c = 0;
                            }
                            DKC.Orders__c += 1;
                            if(DKC.Revenue__c == null){
                                DKC.Revenue__c = 0;
                            }
                            DKC.Revenue__c += ld.Payment_details__c;
                        }
                    }
                    if(mapofCourseByTodaysPayedLeads.get(course) != null){
                        system.debug('Payed List');
                        for(Lead leadRec : mapofCourseByTodaysPayedLeads.get(course)){
                            if(leadRec.Payment_details__c != null && leadRec.Payment_details__c > 0){
                                if(DKC.Order_made_Today__c == null){
                                    DKC.Order_made_Today__c = 0;
                                }
                                DKC.Order_made_Today__c += 1;
                                if(DKC.Revenue_Generated_Today__c == null){
                                    DKC.Revenue_Generated_Today__c = 0;
                                }
                                
                                DKC.Revenue_Generated_Today__c += leadRec.Payment_details__c;
                                
                            }
                            if(DKC.Orders__c >0  && DKC.Total_Leads__c >0)
                                DKC.Lead_Conversion__c =  (DKC.Orders__c* 100)/DKC.Total_Leads__c;
                            if(DKC.Called_Leads__c != null && DKC.Called_Leads__c > 0 && DKC.Orders__c >0)
                                DKC.Called_Conversion__c = (DKC.Orders__c * 100)/DKC.Called_Leads__c;
                            if(DKC.Connected_Leads__c != null && DKC.Connected_Leads__c > 0 && DKC.Orders__c >0)
                                DKC.Connect_Conversion__c = DKC.Orders__c * 100/DKC.Connected_Leads__c;
                            if(!userTracking.isEmpty() && DKC.Revenue__c != null)
                                DKC.Revenue_BD__c = DKC.Revenue__c/userTracking.size();
                            if(DKC.Order_Projection__c == null){
                                DKC.Order_Projection__c = 0;
                            }
                            if(DKC.Orders__c != null){
                                DKC.Order_Projection__c = DKC.Orders__c * 30;
                            }
                            
                            if(DKC.Revenue_Projection__c == null){
                                DKC.Revenue_Projection__c = 0;
                            }
                            if(DKC.Revenue__c != null){
                                DKC.Revenue_Projection__c = DKC.Revenue__c * 30;
                            }
                        }
                    }
                    if(DKC.ATT_Day__c != null && DKC.ATT_Day__c > 0){
                        DKC.Effective_Talk_Time__c = DateTime.valueOf(Integer.valueOf(DKC.ATT_Day__c*1000)).formatGMT('HH:mm:ss');
                    }
                    if(DKC.Effective_AHT__c != null && DKC.Effective_AHT__c > 0){
                        DKC.Effective_Talk_Time_AHT__c = DateTime.valueOf(Integer.valueOf(DKC.Effective_AHT__c*1000)).formatGMT('HH:mm:ss');
                    }
                    if(DKC.Effective_ETT__c != null && DKC.Effective_ETT__c > 0){
                        DKC.Effective_Talk_Time_ETT__c = DateTime.valueOf(Integer.valueOf(DKC.Effective_ETT__c*1000)).formatGMT('HH:mm:ss');
                    }
                    if(!dailyKPIs.isEmpty()){
                        dkc.Daily_KPIs__c = dailyKPIs[0].Id;
                        if(mapofDKCNameyDKCId.get(course) != null)
                            DKC.Id = mapofDKCNameyDKCId.get(course);
                    }
                    if(DKC.ATT_Day__c != null){
                        totalEffectiveSec = totalEffectiveSec + DKC.ATT_Day__c;
                    }
                    if(DKC.Effective_AHT__c != null){
                        totalEffectiveAHTSec = totalEffectiveAHTSec + DKC.Effective_AHT__c;
                    }
                    if(DKC.Effective_ETT__c != null){
                        totalEffectiveETTSec = totalEffectiveETTSec + DKC.Effective_ETT__c;
                    }
                    
                    dkcListtobeInsert.add(DKC);
                }
            }  
        }
        
        
        if(dailyKPIs.isEmpty() && !dkcListtobeInsert.isEmpty()){
            Daily_KPIs__c DK = new Daily_KPIs__c();
            if(loggeroutUser < 0){
                loggeroutUser = loggeroutUser* (-1);
            }
            DK.Not_Checkedin__c = loggeroutUser;
            DK.Early_Logged_Out__c = loggedOutbefore;
            DK.Not_Connected_After_Logged_In__c = noConnectAfterLoggedin;
            DK.Effective_Talk_Time__c = DateTime.valueOf(Integer.valueOf(totalEffectiveSec*1000)).formatGMT('HH:mm:ss'); 
            DK.Effective_Talk_Time_AHT__c = DateTime.valueOf(Integer.valueOf(totalEffectiveAHTSec*1000)).formatGMT('HH:mm:ss');
            DK.Effective_Talk_Time_ETT__c = DateTime.valueOf(Integer.valueOf(totalEffectiveETTSec*1000)).formatGMT('HH:mm:ss');
            DK.New_Leads__c = newLeadsCreatedToday;
            list<Daily_KPIs__c> DdkListTobeInsert = new list<Daily_KPIs__c>();
            DdkListTobeInsert.add(DK);
            Database.UpsertResult [] results = Database.upsert(DdkListTobeInsert, false);
            
            for(Integer index = 0, size = results.size(); index < size; index++){
                if(results[index].isSuccess()){
                    system.debug('result::'+DdkListTobeInsert[index].Id);
                    for(Daily_KPIs_By_Course__c dkcObj : dkcListtobeInsert){
                        dkcObj.Daily_KPIs__c = DdkListTobeInsert[index].Id;
                    }
                    
                }
            }
        }else if(!dailyKPIs.isEmpty()){
            Daily_KPIs__c DK = new Daily_KPIs__c();
            dk.Id = dailyKPIs[0].Id;
            if(loggeroutUser < 0){
                loggeroutUser = loggeroutUser* (-1);
            }
            DK.New_Leads__c = newLeadsCreatedToday;
            DK.Not_Checkedin__c = loggeroutUser;
            DK.Early_Logged_Out__c = loggedOutbefore;
            DK.Not_Connected_After_Logged_In__c = noConnectAfterLoggedin;
            DK.Effective_Talk_Time__c = DateTime.valueOf(Integer.valueOf(totalEffectiveSec*1000)).formatGMT('HH:mm:ss'); 
            DK.Effective_Talk_Time_AHT__c = DateTime.valueOf(Integer.valueOf(totalEffectiveAHTSec*1000)).formatGMT('HH:mm:ss');
            DK.Effective_Talk_Time_ETT__c = DateTime.valueOf(Integer.valueOf(totalEffectiveETTSec*1000)).formatGMT('HH:mm:ss');
            
            upsert DK;
        }
        
        upsert dkcListtobeInsert;
    }
}