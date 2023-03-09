public class LeadAuditForm {
    
    
    @AuraEnabled public static List<Lead> GetQualityScoreDetails(Id RecordId){
        List<Lead> LeadListWithQScore = [Select Id, name, Phone, Email, Company,isQualityScoreUpdated__c,
                                         (SELECT Abrupt_Call_Disconnections__c,Adherence_Process_Effectiveness__c,Anchoring_Questions_and_Follow_up__c,Asking_Personal_Info__c,
                                          Aspiration_V1_Value__c,Aspiration_V1__c,Aspiration__c,Assignments_and_quizes_V1_Value__c,Assignments_and_quizes_V1__c,Awareness__c,Background_V1_Value__c,
                                          Background_V1__c,Background__c,BDA__c,Certificates_V1_Value__c,Certificates_V1__c,Certificates__c,Class_Scheduled_Duration_of_Course__c,Closure_Marks_Out_Of__c,
                                          Closure_Max__c,Closure__c,Community_Access_V1_Value__c,Community_Access_V1__c,Community_Access__c,Company__c,Confidence_Authority_Energy__c,Confidence_Autho_Eng_Voice_Mod_V1_Value__c,
                                          Confidence_Autho_Eng_Voice_Mod_V1__c,Context_Setting_V1__c,Context_Setting_Value__c,Context_Setting__c,Could_not_be_determined_reason__c,Counselling__c,CreatedById,CreatedDate,
                                          CRM_Etiquette__c,Dedicated_Success_Manager_V1_Value__c,Dedicated_Success_Manager_V1__c,Dedicated_Success_Manager__c,Deliberate_malpractice__c,Disposable_income_V1_Value__c,
                                          Disposable_income_V1__c,Domain_Awareness_V1_Value__c,Domain_Awareness_V1__c,Doubt_Support_TA_V1_Value__c,Doubt_Support_TA_V1__c,Doubt_Support__c,Dream_Selling__c,Educators_V1_Value__c,
                                          Educators_V1__c,Empathy_V1_Value__c,Empathy_V1__c,Empathy__c,Environment_V1_Value__c,Environment_V1__c,Environment__c,Financial_fraud__c,Financial_V1_value__c,Financial_V1__c,Financial__c,
                                          Follow_up_adherence_effectiveness__c,Follow_up__c,Greeting__c,Guest_Lectures_V1_Value__c,Guest_Lectures_V1__c,Guest_Lectures__c,Hateful_messages__c,Id,Incomplete_calls__c,Incorrect_Information__c,
                                          Intent_V1_Value__c,Intent_V1__c,Intent__c,Introduction__c,Invalid_Reason__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Link__c,Lead__c,
                                          Listening_skills__c,Live_Class_Schedule_and_Duration_of_c__c,Live_Class_Schedule_Dua_V1_Value__c,Live_Class_Top_Educators__c,LS_Hygiene__c,Mentorship__c,Name,Need_Mapping_Marks_Out_Of__c,
                                          Need_Mapping_Max__c,Need_Mapping__c,Negotiation_and_Urgency_V1_Value__c,Negotiation_and_Urgency_V1__c,Negotiation_and_Urgency__c,No_proper_efforts__c,Objections__c,Objection_handling_V1_Value__c,
                                          Objection_handling_V1__c,Opening_Marks_Out_Of__c,Opening_Max__c,Opening__c,Opportunity_Cost_V1_Value__c,Opportunity_Cost_V1__c,Opportunity_Cost__c,OwnerId,Payment_Options_and_process_V1_Value__c,
                                          Payment_Options_and_process_V1__c,Payment_Options_and_process__c,Placement_Assistance_and_Career_Support__c,Placement_Assistance__c,Placement_Assis_and_Career_Sup_V1_Value__c,Price_Breakdown_V1_Value__c,
                                          Price_Breakdown_V1__c,Price_Breakdown__c,Pricing_and_Scholarships__c,Privacy_Violation__c,Probing_Marks_Out_Of__c,Probing_Max__c,Probing__c,Proctored_Test_V1_Value__c,Proctored_Test_V1__c,Proctored_Test__c,
                                          Projects_Create_prod_from_scratch_V1_V__c,Projects_Create_prod_from_scratch_V1__c,Projects__c,Quality_Score__c,Reason_for_Invalid__c,Reference_Price_V1_Value__c,Reference_Price_V1__c,Reference__c,
                                          Referrals_V1_Value__c,Referrals_V1__c,Referrals__c,Remarks__c,Return_on_investment_ROI_V1_Value__c,Return_on_investment_ROI_V1__c,Rudeness__c,Salary_band_V1_Value__c,Salary_band_V1__c,Salary_Offered_by_Relevel__c,
                                          Sale_Validity__c,Serious_unprofessionalism__c,SF_Hygiene__c,SM__c,Storytelling_Deam_selling_V1_Value__c,Storytelling_Deam_selling_V1__c,Storytelling__c,Subjective_Marks_Out_Of__c,Subjective_Max__c,Subjective__c,
                                          Success_Stories__c,SystemModstamp,Updating_incorrect_details__c,Voice_Modulation__c 
                                          FROM Quality_Score__r)
                                         From Lead Where id =: RecordId];
        return LeadListWithQScore;
    }
    
    @AuraEnabled public static String SaveQualityScoreDetails(Quality_Score__c QualityScore){
        //Quality_Score__c QS = QualityScore.put(Quality_Score__c , leadId);
        system.debug('QualityScore--> '+QualityScore);
        insert QualityScore;
        return 'Success';
    }
    
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){
        
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());
        }
        return lstPickvals;
    }
    
    @AuraEnabled public static wrapperList getPickValues(Id RecordId){
        
        wrapperList WL = new wrapperList();
        
        Map<String,List<String>> pickValByField = new Map<String,List<String>>();
        
        pickValByField.put('Greeting__c',getPicklistValues('Quality_Score__c','Greeting__c'));
        pickValByField.put('Introduction__c',getPicklistValues('Quality_Score__c','Introduction__c'));
        pickValByField.put('Company__c',getPicklistValues('Quality_Score__c','Company__c'));
        pickValByField.put('Context_Setting__c',getPicklistValues('Quality_Score__c','Context_Setting__c'));
        pickValByField.put('Background__c',getPicklistValues('Quality_Score__c','Background__c'));
        pickValByField.put('Intent__c',getPicklistValues('Quality_Score__c','Intent__c'));
        pickValByField.put('Environment__c',getPicklistValues('Quality_Score__c','Environment__c'));
        pickValByField.put('Aspiration__c',getPicklistValues('Quality_Score__c','Aspiration__c'));
        pickValByField.put('Financial__c',getPicklistValues('Quality_Score__c','Financial__c'));
        pickValByField.put('Awareness__c',getPicklistValues('Quality_Score__c','Awareness__c'));
        pickValByField.put('Live_Class_Top_Educators__c',getPicklistValues('Quality_Score__c','Live_Class_Top_Educators__c'));
        pickValByField.put('Mentorship__c',getPicklistValues('Quality_Score__c','Mentorship__c'));
        pickValByField.put('Placement_Assistance__c',getPicklistValues('Quality_Score__c','Placement_Assistance__c'));
        pickValByField.put('Guest_Lectures__c',getPicklistValues('Quality_Score__c','Guest_Lectures__c'));
        pickValByField.put('Certificates__c',getPicklistValues('Quality_Score__c','Certificates__c'));
        pickValByField.put('Community_Access__c',getPicklistValues('Quality_Score__c','Community_Access__c'));
        pickValByField.put('Dedicated_Success_Manager__c',getPicklistValues('Quality_Score__c','Dedicated_Success_Manager__c'));
        pickValByField.put('Doubt_Support__c',getPicklistValues('Quality_Score__c','Doubt_Support__c'));
        pickValByField.put('Empathy__c',getPicklistValues('Quality_Score__c','Empathy__c'));
        pickValByField.put('Follow_up__c',getPicklistValues('Quality_Score__c','Follow_up__c'));
        pickValByField.put('Listening_skills__c',getPicklistValues('Quality_Score__c','Listening_skills__c'));
        pickValByField.put('LS_Hygiene__c',getPicklistValues('Quality_Score__c','LS_Hygiene__c'));
        pickValByField.put('Mentorship__c',getPicklistValues('Quality_Score__c','Mentorship__c'));
        pickValByField.put('Negotiation_and_Urgency__c',getPicklistValues('Quality_Score__c','Negotiation_and_Urgency__c'));
        pickValByField.put('Placement_Assistance__c',getPicklistValues('Quality_Score__c','Placement_Assistance__c'));
        pickValByField.put('Objections__c',getPicklistValues('Quality_Score__c','Objections__c'));
        pickValByField.put('Pricing_and_Scholarships__c',getPicklistValues('Quality_Score__c','Pricing_and_Scholarships__c'));
        pickValByField.put('Proctored_Test__c',getPicklistValues('Quality_Score__c','Proctored_Test__c'));
        pickValByField.put('Projects__c',getPicklistValues('Quality_Score__c','Projects__c'));
        pickValByField.put('Reference__c',getPicklistValues('Quality_Score__c','Reference__c'));
        pickValByField.put('Storytelling__c',getPicklistValues('Quality_Score__c','Storytelling__c'));
        pickValByField.put('Opportunity_Cost__c',getPicklistValues('Quality_Score__c','Opportunity_Cost__c'));
        pickValByField.put('Confidence_Authority_Energy__c',getPicklistValues('Quality_Score__c','Confidence_Authority_Energy__c'));
        pickValByField.put('Referrals__c',getPicklistValues('Quality_Score__c','Referrals__c'));
        pickValByField.put('Price_Breakdown__c',getPicklistValues('Quality_Score__c','Price_Breakdown__c'));
        pickValByField.put('SF_Hygiene__c',getPicklistValues('Quality_Score__c','SF_Hygiene__c'));
        pickValByField.put('Voice_Modulation__c',getPicklistValues('Quality_Score__c','Voice_Modulation__c'));
        pickValByField.put('Dream_Selling__c',getPicklistValues('Quality_Score__c','Dream_Selling__c'));
        pickValByField.put('Counselling__c',getPicklistValues('Quality_Score__c','Counselling__c'));
        pickValByField.put('Anchoring_Questions_and_Follow_up__c',getPicklistValues('Quality_Score__c','Anchoring_Questions_and_Follow_up__c'));
        pickValByField.put('Adherence_Process_Effectiveness__c',getPicklistValues('Quality_Score__c','Adherence_Process_Effectiveness__c'));
        pickValByField.put('Payment_Options_and_process__c',getPicklistValues('Quality_Score__c','Payment_Options_and_process__c'));
        pickValByField.put('Sale_Validity__c',getPicklistValues('Quality_Score__c','Sale_Validity__c'));
        pickValByField.put('Reason_for_Invalid__c',getPicklistValues('Quality_Score__c','Reason_for_Invalid__c'));
        pickValByField.put('Salary_Offered_by_Relevel__c',getPicklistValues('Quality_Score__c','Salary_Offered_by_Relevel__c'));
        pickValByField.put('Class_Scheduled_Duration_of_Course__c',getPicklistValues('Quality_Score__c','Class_Scheduled_Duration_of_Course__c'));

        pickValByField.put('Success_Stories__c',getPicklistValues('Quality_Score__c','Success_Stories__c'));
        pickValByField.put('Payment_Options_and_process__c',getPicklistValues('Quality_Score__c','Payment_Options_and_process__c'));
        
        Map<String,decimal> CAuditMap = new Map<String,decimal>();
        List<Call_Audit_new_Parameters__c> CAUditParameters = [SELECT API_Name__c,Id,Name,Value__c FROM Call_Audit_new_Parameters__c];
        for(Call_Audit_new_Parameters__c CAuditPara : CAUditParameters){
            CAuditMap.put(CAuditPara.Name, CAuditPara.Value__c);
        }
        system.debug('CAuditMap :: '+ CAuditMap);
        WL.MapofCAuditFieldbyValue = CAuditMap;

        WL.MapofPickListbyValue = pickValByField;
        List<Lead> LeadListWithQScore = [Select Id, name, Phone, Email, Company,isQualityScoreUpdated__c,
                                         (SELECT Abrupt_Call_Disconnections__c,Adherence_Process_Effectiveness__c,Anchoring_Questions_and_Follow_up__c,Asking_Personal_Info__c,
                                          Aspiration_V1_Value__c,Aspiration_V1__c,Aspiration__c,Assignments_and_quizes_V1_Value__c,Assignments_and_quizes_V1__c,Awareness__c,Background_V1_Value__c,
                                          Background_V1__c,Background__c,BDA__c,Certificates_V1_Value__c,Certificates_V1__c,Certificates__c,Class_Scheduled_Duration_of_Course__c,Closure_Marks_Out_Of__c,
                                          Closure_Max__c,Closure__c,Community_Access_V1_Value__c,Community_Access_V1__c,Community_Access__c,Company__c,Confidence_Authority_Energy__c,Confidence_Autho_Eng_Voice_Mod_V1_Value__c,
                                          Confidence_Autho_Eng_Voice_Mod_V1__c,Context_Setting_V1__c,Context_Setting_Value__c,Context_Setting__c,Could_not_be_determined_reason__c,Counselling__c,CreatedById,CreatedDate,
                                          CRM_Etiquette__c,Dedicated_Success_Manager_V1_Value__c,Dedicated_Success_Manager_V1__c,Dedicated_Success_Manager__c,Deliberate_malpractice__c,Disposable_income_V1_Value__c,
                                          Disposable_income_V1__c,Domain_Awareness_V1_Value__c,Domain_Awareness_V1__c,Doubt_Support_TA_V1_Value__c,Doubt_Support_TA_V1__c,Doubt_Support__c,Dream_Selling__c,Educators_V1_Value__c,
                                          Educators_V1__c,Empathy_V1_Value__c,Empathy_V1__c,Empathy__c,Environment_V1_Value__c,Environment_V1__c,Environment__c,Financial_fraud__c,Financial_V1_value__c,Financial_V1__c,Financial__c,
                                          Follow_up_adherence_effectiveness__c,Follow_up__c,Greeting__c,Guest_Lectures_V1_Value__c,Guest_Lectures_V1__c,Guest_Lectures__c,Hateful_messages__c,Id,Incomplete_calls__c,Incorrect_Information__c,
                                          Intent_V1_Value__c,Intent_V1__c,Intent__c,Introduction__c,Invalid_Reason__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Link__c,Lead__c,
                                          Listening_skills__c,Live_Class_Schedule_and_Duration_of_c__c,Live_Class_Schedule_Dua_V1_Value__c,Live_Class_Top_Educators__c,LS_Hygiene__c,Mentorship__c,Name,Need_Mapping_Marks_Out_Of__c,
                                          Need_Mapping_Max__c,Need_Mapping__c,Negotiation_and_Urgency_V1_Value__c,Negotiation_and_Urgency_V1__c,Negotiation_and_Urgency__c,No_proper_efforts__c,Objections__c,Objection_handling_V1_Value__c,
                                          Objection_handling_V1__c,Opening_Marks_Out_Of__c,Opening_Max__c,Opening__c,Opportunity_Cost_V1_Value__c,Opportunity_Cost_V1__c,Opportunity_Cost__c,OwnerId,Payment_Options_and_process_V1_Value__c,
                                          Payment_Options_and_process_V1__c,Payment_Options_and_process__c,Placement_Assistance_and_Career_Support__c,Placement_Assistance__c,Placement_Assis_and_Career_Sup_V1_Value__c,Price_Breakdown_V1_Value__c,
                                          Price_Breakdown_V1__c,Price_Breakdown__c,Pricing_and_Scholarships__c,Privacy_Violation__c,Probing_Marks_Out_Of__c,Probing_Max__c,Probing__c,Proctored_Test_V1_Value__c,Proctored_Test_V1__c,Proctored_Test__c,
                                          Projects_Create_prod_from_scratch_V1_V__c,Projects_Create_prod_from_scratch_V1__c,Projects__c,Quality_Score__c,Reason_for_Invalid__c,Reference_Price_V1_Value__c,Reference_Price_V1__c,Reference__c,
                                          Referrals_V1_Value__c,Referrals_V1__c,Referrals__c,Remarks__c,Return_on_investment_ROI_V1_Value__c,Return_on_investment_ROI_V1__c,Rudeness__c,Salary_band_V1_Value__c,Salary_band_V1__c,Salary_Offered_by_Relevel__c,
                                          Sale_Validity__c,Serious_unprofessionalism__c,SF_Hygiene__c,SM__c,Storytelling_Deam_selling_V1_Value__c,Storytelling_Deam_selling_V1__c,Storytelling__c,Subjective_Marks_Out_Of__c,Subjective_Max__c,Subjective__c,
                                          Success_Stories__c,SystemModstamp,Updating_incorrect_details__c,Voice_Modulation__c 
                                          FROM Quality_Score__r)
                                         From Lead Where id =: RecordId];
        WL.leadRecWithQualityScore = LeadListWithQScore;
        WL.qualityScore = LeadListWithQScore[0].Quality_Score__c;
        WL.isCallAuditDone = LeadListWithQScore[0].isQualityScoreUpdated__c;
        return WL;
    }
    
    public class wrapperList{
        @AuraEnabled
        public List<Lead> leadRecWithQualityScore{get;set;}
        @AuraEnabled
        public Map<String,List<String>> MapofPickListbyValue{get;set;}
        @AuraEnabled
        public Map<String,decimal> MapofCAuditFieldbyValue{get;set;}
        @AuraEnabled
        public decimal qualityScore {get;set;}
        @AuraEnabled
        public boolean isCallAuditDone {get;set;}
    }
    
}