public class BDADailyKPI {
    
    public static void bdsKPICalculation(){
        list<BDA_KPI_Details__c> bdaKPIDetailsList = new list<BDA_KPI_Details__c>();
        list<BDA_KPI_Details__c> bdakpilist = new list<BDA_KPI_Details__c>();
        set<string> bdakpiIdSet = new set<string>();
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = task.wk_exo__Exotel_Call_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        map<string,BDA_KPI_Details__c> mapofUseridByKPICal = new map<String,BDA_KPI_Details__c>();
        map<string,list<lead>> mapofLeadidByLeadRec = new map<string,list<lead>>();
        map<string,integer> mapofLeadidByCalledCount = new map<string,integer>();
        map<string,integer> mapofLeadidByConnectCount = new map<string,integer>();
        map<string,integer> mapofLeadidByCallDuration = new map<string,integer>();
        Map<string,string> mapofUserIdByRecId = new map<String,String>();
        
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Relevel Default Queue' limit 1].Id;
        //Lead_Assigned_Date__c
        list<lead> leadList = [select id,lead_stage__c,ownerId,Goal_Interested_In__c,Call_Count__c,Payment_details__c,Temperature__c from lead where Lead_Assigned_Date__c = today and ownerid !=: queueId limit 50000];
        //activity_date_Time
        list<task> taskList = [select id,Call_Duration__c,wk_exo__Total_Talk_Time__c,wk_exo__Exotel_Call_Type__c,whoId,wk_exo__exotel_dial_status__c from task where wk_exo__Exotel_Call_Type__c in : pickListValuesList and whoId != null AND createddate = today limit 50000];
        if(!taskList.isEmpty()){
            for(task ts : taskList){
                mapofLeadidByCalledCount.put(ts.whoId,1);
                if(ts.wk_exo__Total_Talk_Time__c != '0' && ts.wk_exo__Total_Talk_Time__c != null){
                    if(mapofLeadidByCallDuration.containsKey(ts.whoId)){
                        integer connectDuration = mapofLeadidByCallDuration.get(ts.whoId) + Integer.valueOf(ts.wk_exo__Total_Talk_Time__c);
                        mapofLeadidByCallDuration.put(ts.whoId,connectDuration);
                    }else{
                        mapofLeadidByConnectCount.put(ts.whoId,1);
                        mapofLeadidByCallDuration.put(ts.whoId,Integer.valueOf(ts.wk_exo__Total_Talk_Time__c));
                    }
                }
            }
        }
        if(!leadList.isEmpty()){
            for(lead ld : leadList){
                bdakpiIdSet.add(ld.ownerId);
                if(mapofLeadidByLeadRec.containsKey(ld.ownerId)){
                    mapofLeadidByLeadRec.get(ld.ownerId).add(ld);
                }else{
                    mapofLeadidByLeadRec.put(ld.ownerId,new list<lead>{ld}); 
                }
            }
            
            if(!bdakpiIdSet.isEmpty())
                bdakpilist = [select Id,User__c from BDA_KPI_Details__c where User__c in: bdakpiIdSet and createddate = today];
            if(!bdakpilist.isEmpty()){
                for(BDA_KPI_Details__c bdaKPI : bdakpilist){
                    mapofUserIdByRecId.put(bdaKPI.User__c,bdaKPI.Id);
                }
            }
            if(!mapofLeadidByLeadRec.isEmpty()){
                for(string ownerId : mapofLeadidByLeadRec.keySet()){
                    integer newLeadCount = 0;
                    BDA_KPI_Details__c bdaKPIDetail = new BDA_KPI_Details__c();
                    bdaKPIDetail.User__c = ownerId;
                    if(mapofLeadidByLeadRec.containsKey(ownerId))
                        if(mapofLeadidByLeadRec.get(ownerId) != null && mapofLeadidByLeadRec.get(ownerId).size() != null )
                        bdaKPIDetail.Total_Leads__c = mapofLeadidByLeadRec.get(ownerId).size();
                    for(lead ld : mapofLeadidByLeadRec.get(ownerId)){
                        if(ld.Lead_Stage__c == 'New'){
                            newLeadCount++;
                        }
                        if(bdaKPIDetail.New_Leads_Count__c == null)
                            bdaKPIDetail.New_Leads_Count__c = 0;
                        bdaKPIDetail.New_Leads_Count__c = bdaKPIDetail.New_Leads_Count__c + newLeadCount;
                        if(bdaKPIDetail.Called_Leads__c == null)
                            bdaKPIDetail.Called_Leads__c = 0;
                        if(mapofLeadidByCalledCount.get(ld.Id) != null)
                            bdaKPIDetail.Called_Leads__c = bdaKPIDetail.Called_Leads__c + mapofLeadidByCalledCount.get(ld.Id);
                        if(bdaKPIDetail.Connected_Calls__c == null)
                            bdaKPIDetail.Connected_Calls__c = 0;
                        if(mapofLeadidByConnectCount.get(ld.Id) != null)
                            bdaKPIDetail.Connected_Calls__c = bdaKPIDetail.Connected_Calls__c + mapofLeadidByConnectCount.get(ld.Id);
                        if(bdaKPIDetail.Called_Leads__c != 0 && bdaKPIDetail.Called_Leads__c != null)
                            bdaKPIDetail.Called_Percentage__c =  bdaKPIDetail.Called_Leads__c * 100/bdaKPIDetail.Total_Leads__c;
                        if(bdaKPIDetail.Connected_Calls__c != 0 && bdaKPIDetail.Connected_Calls__c != null){
                            bdaKPIDetail.Connected_Percentage__c = bdaKPIDetail.Connected_Calls__c * 100 / bdaKPIDetail.Called_Leads__c;// Changed bdaKPIDetail.Total_Leads__c => bdaKPIDetail.Called_Leads__c
                        }
                        if(ld.Payment_details__c != null && ld.Payment_details__c > 0){
                            if(bdaKPIDetail.Revenue__c == null)
                                bdaKPIDetail.Revenue__c = 0;
                            bdaKPIDetail.Revenue__c = bdaKPIDetail.Revenue__c + ld.Payment_details__c;
                            if(bdaKPIDetail.Order__c == null)
                                bdaKPIDetail.Order__c = 0;
                            bdaKPIDetail.Order__c = bdaKPIDetail.Order__c + 1;
                            if(bdaKPIDetail.Called_Leads__c != 0)
                                bdaKPIDetail.Called_Conversion__c = bdaKPIDetail.Order__c * 100 / bdaKPIDetail.Called_Leads__c;
                            if(bdaKPIDetail.Connected_Calls__c != 0)
                                bdaKPIDetail.Connect_Conversion__c = bdaKPIDetail.Order__c * 100 / bdaKPIDetail.Connected_Calls__c;
                            if(bdaKPIDetail.Order__c != 0)
                                bdaKPIDetail.Lead_Conversion__c = bdaKPIDetail.Total_Leads__c * 100 /bdaKPIDetail.Order__c;
                            if(bdaKPIDetail.Order__c != 0 && bdaKPIDetail.Revenue__c  != 0){
                                bdaKPIDetail.AOV__c = bdaKPIDetail.Revenue__c / bdaKPIDetail.Order__c;
                            }
                        }
                        if(mapofLeadidByCallDuration.get(ld.Id) != null){
                            if(bdaKPIDetail.Talktime_In_Second__c == null)
                                bdaKPIDetail.Talktime_In_Second__c = 0;
                            bdaKPIDetail.Talktime_In_Second__c = mapofLeadidByCallDuration.get(ld.Id)*1000;
                            bdaKPIDetail.ATT_Day__c = DateTime.valueOf(mapofLeadidByCallDuration.get(ld.Id)*1000).formatGMT('HH:mm:ss');
                        }
                        
                        if(mapofUserIdByRecId.containsKey(ownerId)){
                            bdaKPIDetail.Id = mapofUserIdByRecId.get(ownerId);
                        }
                    }
                    bdaKPIDetailsList.add(bdaKPIDetail);
                }
                upsert bdaKPIDetailsList;
            }
        }
        
    }
    
}