public without sharing class SMAuditFormController {
    
    @AuraEnabled
    Public Static SMAUditWrapper getRecordOnDoint(String recId){
        system.debug('recId :: ' + recId);
        
        SMAUditWrapper AuditWrap = new SMAUditWrapper();
        Map<String,List<String>> pickValByField = new Map<String,List<String>>();
        try{
            
            List<Task> TaskCountOfDialledCall = [SELECT Id FROM Task where whoId =: recId AND wk_exo__call_recording_url__c != null];
            List<SM_Call_Audit_Form__c> SMAudForm = [SELECT Closure_Area_of_Improvement__c,Closure_Audited_by__c,Closure_Call_Number__c,Closure_End_Date__c,
															Closure_End_Time_in_min__c,Closure_End_Time_in_sec__c,Closure_Positive_Points__c,Closure_Score__c,Closure_Start_Date__c,
                                                     		Closure_Start_Time_in_min__c,Closure_Start_Time_in_sec__c,CreatedById,CreatedDate,Customer_profile_details__c,
                                                     		Email_Sent__c,Final_Total_Score__c,Follow_up_adherenece__c,Follow_up_created__c,Id,IsDeleted,LastActivityDate,
                                                     		LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Stages__c,Lead__c,Name,Need_Mapping_Area_of_Improvement__c,
                                                     		Need_Mapping_Audited_By__c,Need_Mapping_Call_Number__c,Need_Mapping_End_Date__c,Need_Mapping_End_Time_in_min__c,Need_Mapping_End_Time_in_sec__c,
                                                     		Need_Mapping_Positive_points__c,Need_Mapping_Score__c,Need_Mapping_Start_Date__c,Need_mapping_Start_Time_in_min__c,Need_mapping_Start_Time_in_sec__c,
                                                     		Notes__c,Opening_Area_Of_Improvement__c,Opening_Audited_By__c,Opening_Call_Number__c,Opening_End_Date__c,Opening_End_Time_in_min__c,
                                                     		Opening_End_Time_in_sec__c,Opening_Positive_Points__c,Opening_Score__c,Opening_Start_Date__c,Opening_Start_Time_in_min__c,Opening_Start_Time_in_sec__c,OwnerId,
                                                     		Probing_Area_of_Improvement__c,Probing_Audited_by__c,Probing_Call_Number__c,Probing_End_Date__c,Probing_End_Time_in_min__c,Probing_End_Time_in_sec__c,
                                                     		Probing_Positive_Points__c,Probing_Score__c,Probing_Start_Date__c,Probing_Start_Time_in_min__c,Probing_Start_Time_in_sec__c,Referral_Area_of_Improvement__c,
                                                     		Referral_Audited_by__c,Referral_Call_Number__c,Referral_End_Date__c,Referral_End_Time_in_min__c,Referral_End_Time_in_sec__c,Referral_Positive_Points__c,
                                                     		Referral_Score__c,Referral_Start_Date__c,Referral_Start_Time_in_min__c,Referral_Start_Time_in_sec__c,Subjective_Area_of_Improvement__c,Subjective_Audited_by__c,
                                                     		Subjective_Call_Number__c,Subjective_End_Date__c,Subjective_End_Time_in_min__c,Subjective_End_Time_in_sec__c,Subjective_Positive_Points__c,Subjective_Score__c,
                                                     		Subjective_Start_Date__c,Subjective_Start_Time_in_min__c,Subjective_Start_Time_in_sec__c,SystemModstamp,Temperature_Type__c,Temperature__c 
                                                     		FROM SM_Call_Audit_Form__c Where Lead__c =:recId];
            
            pickValByField.put('Customer_profile_details__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Customer_profile_details__c'));
            pickValByField.put('Email_Sent__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Email_Sent__c'));
            pickValByField.put('Follow_up_adherenece__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Follow_up_adherenece__c'));
            pickValByField.put('Follow_up_created__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Follow_up_created__c'));
            pickValByField.put('Lead_Stages__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Lead_Stages__c'));
            pickValByField.put('Notes__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Notes__c'));
            pickValByField.put('Temperature__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Temperature__c'));
            pickValByField.put('Temperature_Type__c',LeadAuditForm.getPicklistValues('SM_Call_Audit_Form__c','Temperature_Type__c'));
            
            if(!TaskCountOfDialledCall.isEmpty()){
                AuditWrap.tasklist = TaskCountOfDialledCall;
                AuditWrap.taskSize = TaskCountOfDialledCall.size();
            }
            else if(TaskCountOfDialledCall.isEmpty()){
                AuditWrap.tasklist = null;
                AuditWrap.taskSize = TaskCountOfDialledCall.size();
            }
            if(SMAudForm.size() >0){
                AuditWrap.isAuditFormFilled = true;
                AuditWrap.SMCallAuditRec = SMAudForm[0];
            }
            else{
                AuditWrap.isAuditFormFilled = false;
            }
            
            if(!pickValByField.isEmpty()){
                AuditWrap.MapofPickListbyValue = pickValByField;
            }
            system.debug('AuditWrap :: ' + AuditWrap);
            return AuditWrap;
        }
        catch(Exception e){
            System.debug('The following exception has occurred:: ' + e.getMessage() + ' @@@@@ at Line Number :: ' + e.getLineNumber());
        } 
        return AuditWrap;
    }
    
    @AuraEnabled 
    Public static string SaveSMAuditFormRec(SM_Call_Audit_Form__c SMAuditRecord, String recId){
        if(SMAuditRecord !=null && recId != null){
            SMAuditRecord.Lead__c = recId;
        	insert SMAuditRecord;
        }
        
        return 'success';
    }
    
    public class SMAUditWrapper{
    @auraEnabled
    public List<Task> tasklist{get; set;}
    @auraEnabled
    public Boolean isAuditFormFilled  {get; set;}
    @AuraEnabled
    public Map<String,List<String>> MapofPickListbyValue{get;set;}
    @AuraEnabled
    public SM_Call_Audit_Form__c SMCallAuditRec {get;set;}
    @AuraEnabled
    public decimal taskSize {get;set;}
    
    }
}