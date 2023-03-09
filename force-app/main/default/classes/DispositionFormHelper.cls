public class DispositionFormHelper {
    @auraEnabled
    public static Lead fetchLead(String leadId){
        Lead leadRec = new Lead();
        
        if(!string.isBlank(leadId)){
           // leadRec = [ Select Id,Goal_Interested_In__c,Notes__c,Goal_Name__c,Follow_Up_Date__c,Loan_Pitched__c,Branch__c,Loan_Link_Sent__c From Lead Where Id =: leadId];
            system.debug('leadRec::'+leadRec);
            return leadRec;
        }else{
            return null;
        }      
    }
    @auraEnabled
    public static void updateLeadData(Lead leadRec){
        try{
            update leadRec;
        }catch(Exception ex){
            system.debug('Error::>'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }    
    }
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String strObjectName, String strPicklistField){
        system.debug('strObjectName::'+strObjectName);
        system.debug('strPicklistField::'+strPicklistField);
        List<String> pickListValuesList= new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for( Schema.PicklistEntry pickListVal : lstPickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        system.debug('pickListValuesList::>'+pickListValuesList);
        return pickListValuesList;
    }
    
    @auraEnabled 
    public static Map<String,List<String>> getAllPickValues(string objectName){
       
        Map<String,Map<String,List<String>>> pickListValuesByFieldNameByObjName = new Map<String,Map<String,List<String>>>();
        Map<String , Schema.SObjectType> schemaGlobalDescription = Schema.getGlobalDescribe();
        Map<String , Schema.SObjectField> mapFieldList = new Map<String , Schema.SObjectField>();
        Map<String,List<String>> picklistValuesByFieldName = new Map<String,List<String>>();
       
            SObjectType sObjType = ((SObject) Type.forName(objectName).newInstance()).getSObjectType();
            Map <String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
            
            system.debug('fieldMap::'+fieldMap);
            for(string fieldName : fieldMap.keySet()){ //FieldName
                
                String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                
                if(fielddataType == Schema.DisplayType.Picklist){ //DataType of field
                    
                    List<Schema.PicklistEntry> pick_list_values = sObjType.getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues(); // picklist values of field
                    List<String> picklistValues = new List<String>();
                    
                    for (Schema.PicklistEntry aPickListValue : pick_list_values) {                   
                        picklistValues.add(aPickListValue.getValue()); 
                    }
                    picklistValuesByFieldName.put(fieldMap.get(fieldName).getDescribe().getLabel(),picklistValues);                 
                }               
            }
        system.debug('picklistValuesByFieldName::'+picklistValuesByFieldName);
        return picklistValuesByFieldName;
    }
}