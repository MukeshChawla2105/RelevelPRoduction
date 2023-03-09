public class LeadAssignmentExecutionCriteria {
    
    public static void getLeadDAta(Map<Id,Lead> newMap, Map<Id, Lead> oldMap){
        system.debug('Inside RM Assignemnt');
        set<id> leadIds = new set<Id>();
        for(Lead ld :newMap.values()){
            if(ld.Is_Remarketing_Lead__c == false && !String.valueOf(ld.OwnerId).contains('00G')){
                system.debug('Rm Assignment is False');
                leadIds.add(ld.Id);
            }
        }
        if(!leadIds.isEmpty()){
            system.debug('Ids are not empty');
            //validateEntryCriteria(leadIds);
        }
    }
    
    public static void validateEntryCriteria(List<lead> leadList){
        system.debug('INside Criteria Checking');
        list<lead> newLeadListTemp = new list<lead>();
        map<string,list<Lead>> mapofExecutionIdByListLead = new map<String,List<Lead>>();
        map<String,integer> mapofExeIdByEntryCount = new map<string,Integer>();
        map<String,List<Lead>> mapofRMGroupNameByLeadList = new map<String,List<Lead>>();
        map<string,map<string,String>> expectedValuebyCriteria = new map<string,map<string,String>>();
        map<String,String> leadIdByMatchedCriterias = new  map<String,String>();
        map<string,Decimal> allotedMarksbySequence = new Map<String,Decimal>();
        map<string,String> criteriaNameById = new Map<String,String>();
        map<string,String> fieldByMatchingType = new Map<String,String>();
        map<string,String> fieldByFieldType = new Map<String,String>();
        map<string,String> leadValueForFields = new Map<String,String>();
        map<String,List<Lead>> mapofCriteriaIdByLeadList = new map<String,List<Lead>>();
        integer valueTobeMatch = 1;
        string executionCriteria = '';
        system.debug('leadList-->'+leadList.size());
        if(!leadList.isEmpty()){
            for(Lead leadRec: leadList){
                if(!leadRec.Is_Remarketing_Lead__c && !String.valueOf(leadRec.OwnerId).contains('00G')){
                    system.debug('Adding Leads----> '+leadRec.Id);
                    newLeadListTemp.add(leadRec);
                }
            }  
        }
        List<Execution_Criteria__c> AvailableCriterias = [SELECT Enabled__c,Evaluation_Expression_For_Execution__c,Id,Name ,(SELECT Execution_Criteria__c,Field_Name__c,Field_Type__c,Matching_Type__c,Matching_Value__c,Related_Object__c,Scorecard_Execution_Criteria_Name__c,Scorecard__c,Sequence__c FROM Execution_Criteria_Entry__r WHERE Execution_Criteria__c != null)FROM Execution_Criteria__c where Enabled__c = true];
        
        //Creating a map avilable criterias and available rules in that..
        
        for(Execution_Criteria__c exCriteria : AvailableCriterias){
            mapofExeIdByEntryCount.put(exCriteria.Id,exCriteria.Execution_Criteria_Entry__r.size());
        }
        system.debug('mapofExeIdByEntryCount-->'+mapofExeIdByEntryCount);
        
        //Filling all the maps with required information to fetch the data..
        
        for(Execution_Criteria__c scr : AvailableCriterias){
            map<string,string> fieldNameByMatchingValue = new Map<String,string>();
            system.debug('scr::'+scr);
            system.debug('scr::evaluation::'+scr.Evaluation_Expression_For_Execution__c);
            executionCriteria = scr.Evaluation_Expression_For_Execution__c;
            for(Execution_Criteria_Entry__c exe:scr.Execution_Criteria_Entry__R){
                fieldNameByMatchingValue.put(exe.Field_Name__c,exe.Matching_Value__c);
                fieldByMatchingType.put(exe.Field_Name__c,exe.Matching_Type__c);
                fieldByFieldType.put(exe.Field_Name__c,exe.Field_Type__c);
            }
            expectedValuebyCriteria.put(scr.Name,fieldNameByMatchingValue);
            criteriaNameById.put(scr.Name,scr.Id);
            system.debug('expectedValuebyCriteria-->'+expectedValuebyCriteria);
        }
        
        //Matching the leads with the Criterias and assignning criteria..
        /*
         
         */
        Integer count = 0;
        if(executionCriteria != ''){
            String substr = 'AND';
            String str = executionCriteria;
            Integer substrLen = substr.length();
            
            Integer index = str.indexOf(substr);
            while (index >= 0) {
                count++;
                str = str.substring(index+substrLen);
                index = str.indexOf(substr);
            }
        }
        system.debug('count::'+count);
        if(count > 0){
            valueTobeMatch = count + 1;
        }
        if(!newLeadListTemp.isEmpty()){
            for(Lead ld:newLeadListTemp){
                List<String> matchedCriteriasName = new List<String>();
                for(String criteriaName : expectedValuebyCriteria.keyset()){
                    system.debug('criteriaName::'+criteriaName);
                    integer matchedValues = 0;
                    for(String field:expectedValuebyCriteria.get(criteriaName).Keyset())  {
                        system.debug('Field = ' +field +' Comparer : '+fieldByMatchingType.get(field) +' Field Type :  '+fieldByFieldType.get(field) +' Expected Value : ' +expectedValuebyCriteria.get(criteriaName).get(field) + ' Lead Value : '+ld.get(field)) ;
                        
                        if(fieldByFieldType.get(field) == 'Date'){
                            if(fieldByMatchingType.get(field) == '<' || fieldByMatchingType.get(field) == '<='){
                                if(date.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) <= date.valueOf(ld.get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }else if(fieldByMatchingType.get(field) == '>' || fieldByMatchingType.get(field) == '>='){
                                if(date.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) >= date.valueOf(ld.get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }else{
                                if(date.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == date.valueOf(ld.get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }   
                        }else if(fieldByFieldType.get(field) == 'Number'){
                            if(fieldByMatchingType.get(field) == '<' || fieldByMatchingType.get(field) == '<='){
                                
                                if(fieldByMatchingType.get(field) == '<' && Integer.valueOf(ld.get(field)) < Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }else if(fieldByMatchingType.get(field) == '<=' && Integer.valueOf(ld.get(field)) <= Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }
                                
                            }else if(fieldByMatchingType.get(field) == '>' || fieldByMatchingType.get(field) == '>='){
                                
                                if(fieldByMatchingType.get(field) == '>' && Integer.valueOf(ld.get(field)) > Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                    matchedValues++; 
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }else if(fieldByMatchingType.get(field) == '>=' && Integer.valueOf(ld.get(field)) >= Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }
                            }else{
                                if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == Integer.valueOf(ld.get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }
                        }else{
                            if(fieldByMatchingType.get(field) == '=='){
                                system.debug(expectedValuebyCriteria.get(criteriaName).get(field));
                                if(expectedValuebyCriteria.get(criteriaName).get(field).contains(',')){
                                    List<String> commaSeparatedValues = expectedValuebyCriteria.get(criteriaName).get(field).split(',');
                                    for(String Str:commaSeparatedValues){
                                        if(Str == String.valueOf(ld.get(field))){
                                            matchedValues++;
                                            matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                        } 
                                    }
                                }else{
                                    if(expectedValuebyCriteria.get(criteriaName).get(field) == String.valueOf(ld.get(field))){
                                        matchedValues++;
                                        matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                    }   
                                }    
                            }else if(fieldByMatchingType.get(field) == '!='){
                                if(expectedValuebyCriteria.get(criteriaName).get(field) != String.valueOf(ld.get(field))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }else if(fieldByMatchingType.get(field) == 'CONTAINS'){
                                if(String.valueOf(ld.get(field)) != null){
                                    if(String.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)).contains(String.valueOf(ld.get(field)))){
                                        matchedValues++;
                                        matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                    }   
                                }
                                
                            }else if(fieldByMatchingType.get(field) == 'DOES NOT CONTAIN'){
                                if(!expectedValuebyCriteria.get(criteriaName).get(field).contains(String.valueOf(ld.get(field)))){
                                    matchedValues++;
                                    matchedCriteriasName.add(getLabelNameOfField(field)+' '+fieldByMatchingType.get(field)+' '+expectedValuebyCriteria.get(criteriaName).get(field));
                                }  
                            }
                        }
                        system.debug('Count for every Criteria Matched..'+matchedValues);
                    }
                    
                    allotedMarksbySequence.put(criteriaName,matchedValues);
                    system.debug('criteriaNameById.get(criteriaName)-->'+criteriaNameById.get(criteriaName));
                    system.debug('mapofExeIdByEntryCount.get(criteriaNameById.get(criteriaName))-->'+mapofExeIdByEntryCount.get(criteriaNameById.get(criteriaName)));
                    
                    system.debug('matchedValues-->'+matchedValues);
                    if(matchedValues == valueTobeMatch){
                        if(mapofExecutionIdByListLead.containsKey(criteriaNameById.get(criteriaName))){
                            mapofExecutionIdByListLead.get(criteriaNameById.get(criteriaName)).add(ld);
                        }else{
                            mapofExecutionIdByListLead.put(criteriaNameById.get(criteriaName),new list<lead>{ld});
                        }
                    }
                }
                String criterias='';
                for(String str : matchedCriteriasName){
                    criterias += str+' , ';
                }
                criterias= criterias.removeEnd(' , ');
                leadIdByMatchedCriterias.put(ld.Id,criterias);
                system.debug('leadIdByMatchedCriterias-->'+leadIdByMatchedCriterias);
                system.debug('mapofExecutionIdByListLead-->'+mapofExecutionIdByListLead.values().size());
            }
        }
        system.debug('mapofExecutionIdByListLead->'+mapofExecutionIdByListLead);
        if(!mapofExecutionIdByListLead.isEMpty())
            getGroupNameByLeads(mapofExecutionIdByListLead, leadIdByMatchedCriterias);
    }
    
    public static void getGroupNameByLeads(map<string,list<lead>> mapofExecutionIdByLeadList, map<String,String> leadIdByMatchedCriterias){
        list<Assignment_Group__c> agList = new list<Assignment_Group__c>();
        map<string,list<lead>> mapOfGroupNameByListLead = new map<string,list<lead>>();
        //string remarketing
        if(!mapofExecutionIdByLeadList.isEmpty())
            agList = [SELECT id,name,Lead_Assigning_Criteria__c from assignment_group__c where Lead_Assigning_Criteria__r.Id in: mapofExecutionIdByLeadList.keySet()];
        system.debug('agList-->'+agList);
        if(!agList.isEmpty()){
            for(assignment_group__c assGroup : agList){
                mapOfGroupNameByListLead.put(assGroup.name, mapofExecutionIdByLeadList.get(assGroup.Lead_Assigning_Criteria__c));
            }
            system.debug('mapOfGroupNameByListLead-->'+mapOfGroupNameByListLead);
            list<String> leadIdList = new list<String>();
            map<string,list<String>> mapofGroupnameByLeadIdList = new map<String,list<String>>();
            if(!mapOfGroupNameByListLead.isEMpty()){
                for(String mapKey : mapOfGroupNameByListLead.keySet()){
                    system.debug('mapKey-->'+mapKey);
                    if(mapOfGroupNameByListLead !=  null && mapOfGroupNameByListLead.containsKey(mapKey) && mapOfGroupNameByListLead.get(mapKey) != null){
                        for(lead ld : mapOfGroupNameByListLead.get(mapKey)){
                            if(mapofGroupnameByLeadIdList.containsKey(mapKey)){
                                mapofGroupnameByLeadIdList.get(mapKey).add(ld.Id);
                            }else{
                                mapofGroupnameByLeadIdList.put(mapKey,new list<String>{ld.Id});
                            }
                        }
                    }
                    Set<string> tempId = new Set<String>();
                    if(mapofGroupnameByLeadIdList.get(mapKey) != null)
                        tempId = new Set<String>(mapofGroupnameByLeadIdList.get(mapKey));
                    system.debug('mapKey-->'+mapKey);
                    RoundRobinLeadAssignmentForRM.assignLeadsToBDS(mapKey,tempId,leadIdByMatchedCriterias.keyset(),leadIdByMatchedCriterias.values());
                   // RoundRobinLeadAssignmentForRM.leadIdByMatchedCriterias = leadIdByMatchedCriterias;
                }
            }
        }
        
    }
    
    public static string getLabelNameOfField(string apiName){
        String type='Lead';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        return fieldMap.get(apiName).getDescribe().getLabel();
        
    }
}