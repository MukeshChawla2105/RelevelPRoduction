public class QualityScoreTriggerHelper {
    
    public static void updateQualityScore(List<Quality_Score__c> qualityScoreList){
        Set<Id> leadIdForZeroScore = new Set<id>();
        List<lead> leadListTOBeUpdated  = new List<Lead>();
        system.debug('qualityScoreList-->'+qualityScoreList);
        Map<String, Integer> maxValByApiName = new Map<string, Integer>();
        Map<String, Decimal> percentageByLeadId = new Map<string, Decimal>();
        //List<Call_Audit_new_Parameters__c> CallAuditParams = [SELECT API_Name__c,Id,Name,Value__c FROM Call_Audit_new_Parameters__c];
        
        List<Call_Audit__c> callAuditDetails = [Select API_Name__c,Max_Val__c From Call_Audit__c];
        if(!callAuditDetails.isEmpty()){
            for(Call_Audit__c callAuditRec : callAuditDetails){
                maxValByApiName.put(callAuditRec.API_Name__c , integer.valueOf(callAuditRec.Max_Val__c));
            }
        }
        system.debug('maxValByApiName-->'+maxValByApiName);
        if(!maxValByApiName.isEmpty()){
            for(Quality_Score__c qualityScoreRec : qualityScoreList){
                
                
                decimal totalScore = 0;
                integer maxScore = 0;
                qualityScoreRec.Opening_Marks_Out_Of__c = 0;
                qualityScoreRec.Probing_Marks_Out_Of__c = 0;
                qualityScoreRec.Closure_Marks_Out_Of__c = 0;
                qualityScoreRec.Subjective_Marks_Out_Of__c = 0;
                qualityScoreRec.Need_Mapping_Marks_Out_Of__c = 0;
                system.debug('qualityScoreRec.Opening_Marks_Out_Of__c-->'+qualityScoreRec.Opening_Marks_Out_Of__c);
                ////Opening
                if(qualityScoreRec.Greeting__c != 'NA')
                {
                    qualityScoreRec.Opening__c = 0;
                    
                    if(qualityScoreRec.Greeting__c == null){
                        
                    }else{
                        qualityScoreRec.Opening__c += decimal.valueOf(qualityScoreRec.Greeting__c);
                    }
                    maxScore += maxValByApiName.get('Greeting__c');
                    qualityScoreRec.Opening_Marks_Out_Of__c += maxValByApiName.get('Greeting__c');
                } 
                system.debug('qualityScoreRec.Opening_Marks_Out_Of__c-->'+qualityScoreRec.Opening_Marks_Out_Of__c);
                if(qualityScoreRec.Introduction__c !='NA')
                {
                    
                    if(qualityScoreRec.Introduction__c == null){
                        
                    }else{
                        qualityScoreRec.Opening__c += decimal.valueOf(qualityScoreRec.Introduction__c);
                        
                    }  
                    maxScore += maxValByApiName.get('Introduction__c');
                    qualityScoreRec.Opening_Marks_Out_Of__c += maxValByApiName.get('Introduction__c');
                } 
                system.debug('qualityScoreRec.Opening_Marks_Out_Of__c-->'+qualityScoreRec.Opening_Marks_Out_Of__c);
                if(qualityScoreRec.Company__c !='NA')
                {
                    if(qualityScoreRec.Company__c == null){
                        
                    }else{
                        qualityScoreRec.Opening__c += decimal.valueOf(qualityScoreRec.Company__c) ;
                    }
                    maxScore += maxValByApiName.get('Company__c');
                    qualityScoreRec.Opening_Marks_Out_Of__c += maxValByApiName.get('Company__c');
                    
                } 
                system.debug('qualityScoreRec.Opening_Marks_Out_Of__c-->'+qualityScoreRec.Opening_Marks_Out_Of__c);
                if(qualityScoreRec.Context_Setting__c !='NA')
                {
                    if(qualityScoreRec.Context_Setting__c == null){
                        
                    }else{
                        qualityScoreRec.Opening__c += decimal.valueOf(qualityScoreRec.Context_Setting__c);
                    }
                    maxScore += maxValByApiName.get('Context_Setting__c');
                    qualityScoreRec.Opening_Marks_Out_Of__c += maxValByApiName.get('Context_Setting__c');
                }
                system.debug('qualityScoreRec.Opening_Marks_Out_Of__c-->'+qualityScoreRec.Opening_Marks_Out_Of__c);
                
                //Probing
                if(qualityScoreRec.Background__c != 'NA')
                {
                    qualityScoreRec.Probing__c = 0;
                    if(qualityScoreRec.Background__c == null){
                        
                    }else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Background__c);
                    }
                    maxScore += maxValByApiName.get('Background__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Background__c');
                } 
                
                if(qualityScoreRec.Intent__c !='NA')
                {
                    if(qualityScoreRec.Intent__c == null){
                        
                    }else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Intent__c);
                    }
                    maxScore += maxValByApiName.get('Intent__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Intent__c');
                    
                } 
                if(qualityScoreRec.Financial__c !='NA')
                {
                    if(qualityScoreRec.Financial__c == null){
                        
                    }else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Financial__c) ;
                    }
                    maxScore += maxValByApiName.get('Financial__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Financial__c');
                } 
                if(qualityScoreRec.Environment__c !='NA')
                {
                    if(qualityScoreRec.Environment__c == null){
                        
                    }else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Environment__c); 
                    }
                    maxScore += maxValByApiName.get('Environment__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Environment__c');
                }
                if(qualityScoreRec.Aspiration__c !='NA')
                {
                    if(qualityScoreRec.Aspiration__c == null){
                        
                    }
                    else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Aspiration__c) ;    
                    }
                    
                    maxScore += maxValByApiName.get('Aspiration__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Aspiration__c');
                } 
                if(qualityScoreRec.Awareness__c !='NA')
                {
                    if(qualityScoreRec.Awareness__c == null){
                        
                    }else{
                        qualityScoreRec.Probing__c += decimal.valueOf(qualityScoreRec.Awareness__c);
                    }
                    maxScore += maxValByApiName.get('Awareness__c');
                    qualityScoreRec.Probing_Marks_Out_Of__c += maxValByApiName.get('Awareness__c');
                }
                
                system.debug('qualityScoreRec.Probing__c-->'+qualityScoreRec.Probing__c);
                
                /////////Need Mapping
                if(qualityScoreRec.Live_Class_Top_Educators__c != 'NA')
                {
                    qualityScoreRec.Need_Mapping__c = 0;
                    if(qualityScoreRec.Live_Class_Top_Educators__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Live_Class_Top_Educators__c);
                    }
                    maxScore += maxValByApiName.get('Live_Class_Top_Educators__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Live_Class_Top_Educators__c');
                } 
                if(qualityScoreRec.Mentorship__c !='NA')
                {
                    if(qualityScoreRec.Mentorship__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Mentorship__c);
                    }
                    maxScore += maxValByApiName.get('Mentorship__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Mentorship__c');
                } 
                if(qualityScoreRec.Placement_Assistance__c !='NA')
                {
                    if(qualityScoreRec.Placement_Assistance__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Placement_Assistance__c) ;
                    }
                    maxScore += maxValByApiName.get('Placement_Assistance__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Placement_Assistance__c');
                } 
                if(qualityScoreRec.Guest_Lectures__c !='NA')
                {
                    if(qualityScoreRec.Guest_Lectures__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Guest_Lectures__c);
                        
                    }
                    maxScore += maxValByApiName.get('Guest_Lectures__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Guest_Lectures__c');
                }
                if(qualityScoreRec.Proctored_Test__c !='NA')
                {
                    if(qualityScoreRec.Proctored_Test__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Proctored_Test__c) ;
                    }
                    maxScore += maxValByApiName.get('Proctored_Test__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Proctored_Test__c');
                } 
                if(qualityScoreRec.Community_Access__c !='NA')
                {
                    if(qualityScoreRec.Community_Access__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Community_Access__c);
                    }
                    
                    maxScore += maxValByApiName.get('Community_Access__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Community_Access__c');
                }
                if(qualityScoreRec.Doubt_Support__c != 'NA')
                {
                    if(qualityScoreRec.Doubt_Support__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Doubt_Support__c); 
                    }
                    maxScore += maxValByApiName.get('Doubt_Support__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Doubt_Support__c');
                } 
                if(qualityScoreRec.Dedicated_Success_Manager__c !='NA')
                {
                    if(qualityScoreRec.Dedicated_Success_Manager__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Dedicated_Success_Manager__c);
                    }
                    maxScore += maxValByApiName.get('Dedicated_Success_Manager__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Dedicated_Success_Manager__c');
                } 
                system.debug('Salary_Offered_by_Relevel__c--------------'+qualityScoreRec.Salary_Offered_by_Relevel__c);
                if(qualityScoreRec.Salary_Offered_by_Relevel__c !='NA')
                {
                    if(qualityScoreRec.Salary_Offered_by_Relevel__c	 == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Salary_Offered_by_Relevel__c	) ;
                    }
                    maxScore += maxValByApiName.get('Salary_Offered_by_Relevel__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Salary_Offered_by_Relevel__c');
                } 
                if(qualityScoreRec.Class_Scheduled_Duration_of_Course__c !='NA')
                {
                    if(qualityScoreRec.Class_Scheduled_Duration_of_Course__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Class_Scheduled_Duration_of_Course__c) ;
                    }
                    maxScore += maxValByApiName.get('Class_Scheduled_Duration_of_Course__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Class_Scheduled_Duration_of_Course__c');
                } 
                if(qualityScoreRec.Certificates__c !='NA')
                {
                    if(qualityScoreRec.Certificates__c == null){
                        
                    }else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Certificates__c) ;
                    }
                    maxScore += maxValByApiName.get('Certificates__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Certificates__c');
                } 
                if(qualityScoreRec.Projects__c !='NA')
                {
                    if(qualityScoreRec.Projects__c == null){
                        
                    }
                    else{
                        qualityScoreRec.Need_Mapping__c += decimal.valueOf(qualityScoreRec.Projects__c);
                    }               
                    maxScore += maxValByApiName.get('Projects__c');
                    qualityScoreRec.Need_Mapping_Marks_Out_Of__c += maxValByApiName.get('Projects__c');
                }
                ///////CLosure
                system.debug('qualityScoreRec.Need_Mapping__c-->'+qualityScoreRec.Need_Mapping__c);
                if(qualityScoreRec.Reference__c !='NA')
                {
                    qualityScoreRec.Closure__c = 0;
                    if(qualityScoreRec.Reference__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Reference__c) ;
                    }
                    
                    maxScore += maxValByApiName.get('Reference__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Reference__c');
                } 
                if(qualityScoreRec.Opportunity_Cost__c !='NA')
                {
                    if(qualityScoreRec.Opportunity_Cost__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Opportunity_Cost__c);
                    }
                    maxScore += maxValByApiName.get('Opportunity_Cost__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Opportunity_Cost__c');
                }
                if(qualityScoreRec.Referrals__c !='NA')
                {
                    if(qualityScoreRec.Referrals__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Referrals__c);
                    }
                    maxScore += maxValByApiName.get('Referrals__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Referrals__c');
                }
                if(qualityScoreRec.Price_Breakdown__c !='NA')
                {
                    if(qualityScoreRec.Price_Breakdown__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Price_Breakdown__c);
                    }
                    maxScore += maxValByApiName.get('Price_Breakdown__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Price_Breakdown__c');
                }
                if(qualityScoreRec.SF_Hygiene__c !='NA')
                {
                    if(qualityScoreRec.SF_Hygiene__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.SF_Hygiene__c);
                    }
                    maxScore += maxValByApiName.get('SF_Hygiene__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('SF_Hygiene__c');
                }
                if(qualityScoreRec.Follow_up__c !='NA')
                {
                    if(qualityScoreRec.Follow_up__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Follow_up__c);
                    }
                    maxScore += maxValByApiName.get('Follow_up__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Follow_up__c');
                }
                if(qualityScoreRec.Pricing_and_Scholarships__c !='NA')
                {
                    if(qualityScoreRec.Pricing_and_Scholarships__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Pricing_and_Scholarships__c);
                    }
                    maxScore += maxValByApiName.get('Pricing_and_Scholarships__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Pricing_and_Scholarships__c');
                }
                /*if(qualityScoreRec.Anchoring_Questions_and_Follow_up__c !='NA')
{
if(qualityScoreRec.Anchoring_Questions_and_Follow_up__c == null){

}else{
qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Anchoring_Questions_and_Follow_up__c);
}
maxScore += maxValByApiName.get('Anchoring_Questions_and_Follow_up__c');
qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Anchoring_Questions_and_Follow_up__c');
}*/
                if(qualityScoreRec.Negotiation_and_Urgency__c !='NA')
                {
                    if(qualityScoreRec.Negotiation_and_Urgency__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Negotiation_and_Urgency__c);
                    }
                    maxScore += maxValByApiName.get('Negotiation_and_Urgency__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Negotiation_and_Urgency__c');
                }
                if(qualityScoreRec.Success_Stories__c !='NA')
                {
                    if(qualityScoreRec.Success_Stories__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Success_Stories__c);
                    }
                    maxScore += maxValByApiName.get('Success_Stories__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Success_Stories__c');
                }
                
                
                if(qualityScoreRec.Payment_Options_and_process__c !='NA')
                {
                    if(qualityScoreRec.Payment_Options_and_process__c == null){
                        
                    }else{
                        qualityScoreRec.Closure__c += decimal.valueOf(qualityScoreRec.Payment_Options_and_process__c);
                    }
                    maxScore += maxValByApiName.get('Payment_Options_and_process__c');
                    qualityScoreRec.Closure_Marks_Out_Of__c += maxValByApiName.get('Payment_Options_and_process__c');
                }
                
                ///////Subjective
                system.debug('qualityScoreRec.Closure__c-->'+qualityScoreRec.Closure__c);
                if(qualityScoreRec.Storytelling__c !='NA')
                {
                    qualityScoreRec.Subjective__c = 0;
                    if(qualityScoreRec.Storytelling__c == null){
                        
                    }else{              
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Storytelling__c) ;
                    }
                    maxScore += maxValByApiName.get('Storytelling__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Storytelling__c');
                } 
                if(qualityScoreRec.Empathy__c !='NA')
                {
                    if(qualityScoreRec.Empathy__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Empathy__c);
                    }
                    maxScore += maxValByApiName.get('Empathy__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Empathy__c');
                }
                if(qualityScoreRec.Listening_skills__c !='NA')
                {
                    if(qualityScoreRec.Listening_skills__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Listening_skills__c);
                    }
                    maxScore += maxValByApiName.get('Listening_skills__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Listening_skills__c');
                }
                if(qualityScoreRec.Confidence_Authority_Energy__c !='NA')
                {
                    if(qualityScoreRec.Confidence_Authority_Energy__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Confidence_Authority_Energy__c);
                    }
                    maxScore += maxValByApiName.get('Confidence_Authority_Energy__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Confidence_Authority_Energy__c');
                }
                if(qualityScoreRec.Voice_Modulation__c !='NA')
                {
                    if(qualityScoreRec.Voice_Modulation__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Voice_Modulation__c);
                    }     
                    maxScore += maxValByApiName.get('Voice_Modulation__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Voice_Modulation__c');
                }
                if(qualityScoreRec.Objections__c !='NA')
                {
                    if(qualityScoreRec.Objections__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Objections__c);
                    }
                    maxScore += maxValByApiName.get('Objections__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Objections__c');
                    
                }
                if(qualityScoreRec.Dream_Selling__c !='NA')
                {
                    if(qualityScoreRec.Dream_Selling__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Dream_Selling__c);
                    }
                    maxScore += maxValByApiName.get('Dream_Selling__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Dream_Selling__c');
                }
                if(qualityScoreRec.Counselling__c !='NA')
                {
                    if(qualityScoreRec.Counselling__c == null){
                        
                    }else{
                        qualityScoreRec.Subjective__c += decimal.valueOf(qualityScoreRec.Counselling__c);
                    }
                    maxScore += maxValByApiName.get('Counselling__c');
                    qualityScoreRec.Subjective_Marks_Out_Of__c += maxValByApiName.get('Counselling__c');
                }
                system.debug('qualityScoreRec.Subjective__c-->'+qualityScoreRec.Subjective__c);
                totalScore = qualityScoreRec.Subjective__c + qualityScoreRec.Opening__c + qualityScoreRec.Probing__c + qualityScoreRec.Need_Mapping__c + qualityScoreRec.Closure__c;
                system.debug('totalScore-->'+totalScore);
                system.debug('maxScore-->'+maxScore);
                if(totalScore != 0 ||  maxScore != 0)
                    qualityScoreRec.Quality_Score__c = (totalScore/maxScore)*100;
                else{
                    qualityScoreRec.Quality_Score__c = 0;
                }
                system.debug('qualityScoreRec.Quality_Score__c -->'+qualityScoreRec.Quality_Score__c);
                if(qualityScoreRec.Lead__c != null)
                    percentageByLeadId.put(qualityScoreRec.Lead__c , qualityScoreRec.Quality_Score__c);
            }
        }
        
        if(!percentageByLeadId.isEmpty()){
            for(Id leadId :  percentageByLeadId.keySet()){
                Lead leadRec =  new Lead();
                leadRec.Id = leadId;
                leadRec.Quality_Score__c = percentageByLeadId.get(leadId);
                leadRec.isQualityScoreUpdated__c = true;
                leadListTOBeUpdated.add(leadRec);
            }
            if(!leadListTOBeUpdated.isEmpty()){
                update leadListTOBeUpdated;
            }
        }
    }
    
    public static void UpdatedQualityScoreWithNewParams(List<Quality_Score__c> qualityScoreList){
        List<Lead> leadListTOBeUpdated = new List<Lead>();
        List<Quality_Score__c> QScoreTobeUpdateList = new List<Quality_Score__c>();
        map<String, decimal> mapofFieldWithvalue = new map<String, decimal>();
        Map<String, decimal> MapofMainFieldWithScorevalue = new map<String, decimal>();
        Map<String, Decimal> percentageByLeadId = new Map<string, Decimal>();
        
        List<Call_Audit_new_Parameters__c> CallAuditFieldsParams = [SELECT API_Name__c,Id,Name,Value__c FROM Call_Audit_new_Parameters__c];
        for(Call_Audit_new_Parameters__c CAud : CallAuditFieldsParams){
            mapofFieldWithvalue.put(CAud.Name, CAud.Value__c);
        }
        system.debug('mapofFieldWithvalue :: ' + mapofFieldWithvalue);
        
        List<Call_Audit_Main_Fields_Value__c> CallAuditMainFieldsWithValue = [SELECT API_Name__c,Field_Max_Value__c,Id,Name FROM Call_Audit_Main_Fields_Value__c];
        for(Call_Audit_Main_Fields_Value__c CallAuditWithvalue : CallAuditMainFieldsWithValue){
            MapofMainFieldWithScorevalue.put(CallAuditWithvalue.API_Name__c, CallAuditWithvalue.Field_Max_Value__c);
        }
        system.debug('MapofMainFieldWithScorevalue :: ' + MapofMainFieldWithScorevalue);
        
        
        
        if(!qualityScoreList.isEmpty() && !mapofFieldWithvalue.isempty() && !MapofMainFieldWithScorevalue.isempty()){
            for(Quality_Score__c QScore : qualityScoreList){
                Quality_Score__c updatedScore = new Quality_Score__c();
                updatedScore.Id = QScore.Id;
                updatedScore.Lead__c = QScore.Lead__c;
                
                /* ====================================== OPENING CODE ===================================================*/ 
                
                decimal openingScoreNumerator = 0;
                decimal OpeningScoreDenominator= 0;
                decimal openingScoreAverage = 0;
                
                if(QScore.Greeting__c != Null){
                    if(QScore.Greeting__c != 'NA'){
                        //updatedScore.Greeting__c = QScore.Greeting__c;
                        openingScoreNumerator += decimal.valueOf(QScore.Greeting__c);
                        //((MapofMainFieldWithScorevalue.get('Context_Setting_V1__c'))*4)
                        OpeningScoreDenominator += (MapofMainFieldWithScorevalue.get('Greeting__c'));
                    }
                    else if(QScore.Greeting__c == 'NA'){
                        //updatedScore.Greeting__c = QScore.Greeting__c;
                    }
                }
                
                if(QScore.Introduction__c != Null){
                    if(QScore.Introduction__c != 'NA'){
                        //updatedScore.Introduction__c = QScore.Introduction__c;
                        openingScoreNumerator += decimal.valueOf(QScore.Introduction__c);
                        OpeningScoreDenominator += (MapofMainFieldWithScorevalue.get('Introduction__c'));
                    }
                    else if(QScore.Greeting__c == 'NA'){
                        //updatedScore.Greeting__c = QScore.Greeting__c;
                    }
                }  
                if(QScore.Company__c != Null){
                    if(QScore.Company__c != 'NA'){
                        //updatedScore.Introduction__c = QScore.Introduction__c;
                        openingScoreNumerator += decimal.valueOf(QScore.Company__c);
                        OpeningScoreDenominator += (MapofMainFieldWithScorevalue.get('Company__c'));
                    }
                    else if(QScore.Company__c == 'NA'){
                        //updatedScore.Greeting__c = QScore.Greeting__c;
                    }
                }
                if(QScore.Context_Setting_V1__c != Null){
                    if(QScore.Context_Setting_V1__c != 'NA'){
                        decimal valueoffield = MapofMainFieldWithScorevalue.get('Context_Setting_V1__c');
                        system.debug('MapofMainFieldWithScorevalue.get(Context_Setting_V1__c) :: ' + valueoffield);
                        system.debug('QScore.Context_Setting_V1__c :: ' + QScore.Context_Setting_V1__c);
                        system.debug('mapofFieldWithvalue.get(QScore.Context_Setting_V1__c) :: ' + mapofFieldWithvalue.get(QScore.Context_Setting_V1__c));
                        updatedScore.Context_Setting_Value__c = (MapofMainFieldWithScorevalue.get('Context_Setting_V1__c'))*(mapofFieldWithvalue.get(QScore.Context_Setting_V1__c));
                        openingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Context_Setting_V1__c'))*(mapofFieldWithvalue.get(QScore.Context_Setting_V1__c)));
                        OpeningScoreDenominator += ((MapofMainFieldWithScorevalue.get('Context_Setting_V1__c'))*4);
                    }
                    else if(QScore.Context_Setting_V1__c == 'NA' ){
                        
                    }
                }
                system.debug('openingScoreNumerator :: ' + openingScoreNumerator);
                system.debug('OpeningScoreDenominator :: ' + OpeningScoreDenominator);
                
                if(openingScoreNumerator != 0 ||  OpeningScoreDenominator != 0){
                    openingScoreAverage = (openingScoreNumerator/OpeningScoreDenominator);
                	updatedScore.Opening__c = openingScoreNumerator;
                    updatedScore.Opening_Marks_Out_Of__c = OpeningScoreDenominator;
                }
                    
                else{
                    openingScoreAverage = 0;
                }
                system.debug('openingScoreAverage :: ' + openingScoreAverage);
                
                
                decimal openingScoreAveragePercentage = openingScoreAverage*100;
                
                /* ====================================== PROBING CODE ===================================================*/             
                
                decimal ProbingScoreNumerator = 0;
                decimal ProbingScoreDenominator = 0; //
                decimal ProbingScoreAverage = 0;
                
                if(QScore.Background_V1__c != Null){
                    if(QScore.Background_V1__c != 'NA'){
                        system.debug('QScore.Background_V1__c :: ' + QScore.Background_V1__c);
                        updatedScore.Background_V1_Value__c = (MapofMainFieldWithScorevalue.get('Background_V1__c'))*(mapofFieldWithvalue.get(QScore.Background_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Background_V1__c'))*(mapofFieldWithvalue.get(QScore.Background_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Background_V1__c'))*4);
                    }
                    else if(QScore.Background_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Intent_V1__c != Null){
                    if(QScore.Intent_V1__c != 'NA'){
                        system.debug('QScore.Intent_V1__c :: ' + QScore.Intent_V1__c);
                        updatedScore.Intent_V1_Value__c = (MapofMainFieldWithScorevalue.get('Intent_V1__c'))*(mapofFieldWithvalue.get(QScore.Intent_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Intent_V1__c'))*(mapofFieldWithvalue.get(QScore.Intent_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Intent_V1__c'))*4);
                    }
                    else if(QScore.Intent_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Financial_V1__c != Null){
                    if(QScore.Financial_V1__c != 'NA'){
                        system.debug('QScore.Financial_V1__c :: ' + QScore.Financial_V1__c);
                        updatedScore.Financial_V1_value__c = (MapofMainFieldWithScorevalue.get('Financial_V1__c'))*(mapofFieldWithvalue.get(QScore.Financial_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Financial_V1__c'))*(mapofFieldWithvalue.get(QScore.Financial_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Financial_V1__c'))*4);
                    }
                    else if(QScore.Financial_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Environment_V1__c != Null){
                    if(QScore.Environment_V1__c != 'NA'){
                        system.debug('QScore.Environment_V1__c :: ' + QScore.Environment_V1__c);
                        updatedScore.Environment_V1_Value__c = (MapofMainFieldWithScorevalue.get('Environment_V1__c'))*(mapofFieldWithvalue.get(QScore.Environment_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Environment_V1__c'))*(mapofFieldWithvalue.get(QScore.Environment_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Environment_V1__c'))*4);
                    }
                    else if(QScore.Environment_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Aspiration_V1__c != Null){
                    if(QScore.Aspiration_V1__c != 'NA'){
                        system.debug('QScore.Aspiration_V1__c :: ' + QScore.Aspiration_V1__c);
                        updatedScore.Aspiration_V1_Value__c = (MapofMainFieldWithScorevalue.get('Aspiration_V1__c'))*(mapofFieldWithvalue.get(QScore.Aspiration_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Aspiration_V1__c'))*(mapofFieldWithvalue.get(QScore.Aspiration_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Aspiration_V1__c'))*4);
                    }
                    else if(QScore.Aspiration_V1__c == 'NA' ){
                        
                    }
                    
                    
                }
                if(QScore.Domain_Awareness_V1__c != Null){
                    if(QScore.Domain_Awareness_V1__c != 'NA'){
                        system.debug('QScore.Domain_Awareness_V1__c :: ' + QScore.Domain_Awareness_V1__c);
                        updatedScore.Domain_Awareness_V1_Value__c = (MapofMainFieldWithScorevalue.get('Domain_Awareness_V1__c'))*(mapofFieldWithvalue.get(QScore.Domain_Awareness_V1__c));
                        ProbingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Domain_Awareness_V1__c'))*(mapofFieldWithvalue.get(QScore.Domain_Awareness_V1__c)));
                        ProbingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Domain_Awareness_V1__c'))*4);
                    }
                    else if(QScore.Domain_Awareness_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(ProbingScoreNumerator != 0 ||  ProbingScoreDenominator != 0){
                    ProbingScoreAverage = ProbingScoreNumerator/ProbingScoreDenominator;
                    updatedScore.Probing__c = ProbingScoreNumerator;
                    updatedScore.Probing_Marks_Out_Of__c = ProbingScoreDenominator;
                }
                    
                else{
                    ProbingScoreAverage = 0;
                }
                system.debug('ProbingScoreAverage :: ' + ProbingScoreAverage);
                decimal ProbingScoreAveragePercentage = ProbingScoreAverage*100;
                
                /* ====================================== NEED MAPPING CODE ===================================================*/           
                
                Decimal NeedMappingScoreNumerator = 0;  
                Decimal NeedmappingScoreDenominator = 0;
                Decimal NeedMappingScoreAverage = 0;
                
                
                if(QScore.Live_Class_Schedule_and_Duration_of_c__c != Null){
                    if(QScore.Live_Class_Schedule_and_Duration_of_c__c != 'NA'){
                        system.debug('QScore.Live_Class_Schedule_and_Duration_of_c__c :: ' + QScore.Live_Class_Schedule_and_Duration_of_c__c);
                        updatedScore.Live_Class_Schedule_Dua_V1_Value__c = (MapofMainFieldWithScorevalue.get('Live_Class_Schedule_and_Duration_of_c__c'))*(mapofFieldWithvalue.get(QScore.Live_Class_Schedule_and_Duration_of_c__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Live_Class_Schedule_and_Duration_of_c__c'))*(mapofFieldWithvalue.get(QScore.Live_Class_Schedule_and_Duration_of_c__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Live_Class_Schedule_and_Duration_of_c__c'))*4);
                    }
                    else if(QScore.Live_Class_Schedule_and_Duration_of_c__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Doubt_Support_TA_V1__c != Null){
                    if(QScore.Doubt_Support_TA_V1__c != 'NA'){
                        system.debug('QScore.Doubt_Support_TA_V1__c :: ' + QScore.Doubt_Support_TA_V1__c);
                        updatedScore.Doubt_Support_TA_V1_Value__c = (MapofMainFieldWithScorevalue.get('Doubt_Support_TA_V1__c'))*(mapofFieldWithvalue.get(QScore.Doubt_Support_TA_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Doubt_Support_TA_V1__c'))*(mapofFieldWithvalue.get(QScore.Doubt_Support_TA_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Doubt_Support_TA_V1__c'))*4);
                    }
                    else if(QScore.Doubt_Support_TA_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Placement_Assistance_and_Career_Support__c != Null){
                    if(QScore.Placement_Assistance_and_Career_Support__c != 'NA'){
                        system.debug('QScore.Placement_Assistance_and_Career_Support__c :: ' + QScore.Placement_Assistance_and_Career_Support__c);
                        updatedScore.Placement_Assis_and_Career_Sup_V1_Value__c	 = (MapofMainFieldWithScorevalue.get('Placement_Assistance_and_Career_Support__c'))*(mapofFieldWithvalue.get(QScore.Placement_Assistance_and_Career_Support__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Placement_Assistance_and_Career_Support__c'))*(mapofFieldWithvalue.get(QScore.Placement_Assistance_and_Career_Support__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Placement_Assistance_and_Career_Support__c'))*4);
                    }
                    else if(QScore.Placement_Assistance_and_Career_Support__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Guest_Lectures_V1__c != Null){
                    if(QScore.Guest_Lectures_V1__c != 'NA'){
                        system.debug('QScore.Guest_Lectures_V1__c :: ' + QScore.Guest_Lectures_V1__c);
                        updatedScore.Guest_Lectures_V1_Value__c = (MapofMainFieldWithScorevalue.get('Guest_Lectures_V1__c'))*(mapofFieldWithvalue.get(QScore.Guest_Lectures_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Guest_Lectures_V1__c'))*(mapofFieldWithvalue.get(QScore.Guest_Lectures_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Guest_Lectures_V1__c'))*4);
                    }
                    else if(QScore.Guest_Lectures_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Proctored_Test_V1__c != Null){
                    if(QScore.Proctored_Test_V1__c != 'NA'){
                        system.debug('QScore.Proctored_Test_V1__c :: ' + QScore.Proctored_Test_V1__c);
                        updatedScore.Proctored_Test_V1_Value__c = (MapofMainFieldWithScorevalue.get('Proctored_Test_V1__c'))*(mapofFieldWithvalue.get(QScore.Proctored_Test_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Proctored_Test_V1__c'))*(mapofFieldWithvalue.get(QScore.Proctored_Test_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Proctored_Test_V1__c'))*4);
                    }
                    else if(QScore.Proctored_Test_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Community_Access_V1__c != Null){
                    if(QScore.Community_Access_V1__c != 'NA'){
                        system.debug('QScore.Community_Access_V1__c :: ' + QScore.Community_Access_V1__c);
                        updatedScore.Community_Access_V1_Value__c = (MapofMainFieldWithScorevalue.get('Community_Access_V1__c'))*(mapofFieldWithvalue.get(QScore.Community_Access_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Community_Access_V1__c'))*(mapofFieldWithvalue.get(QScore.Community_Access_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Community_Access_V1__c'))*4);
                    }
                    else if(QScore.Community_Access_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Assignments_and_quizes_V1__c != Null){
                    if(QScore.Assignments_and_quizes_V1__c != 'NA'){
                        system.debug('QScore.Assignments_and_quizes_V1__c :: ' + QScore.Assignments_and_quizes_V1__c);
                        updatedScore.Assignments_and_quizes_V1_Value__c = (MapofMainFieldWithScorevalue.get('Assignments_and_quizes_V1__c'))*(mapofFieldWithvalue.get(QScore.Assignments_and_quizes_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Assignments_and_quizes_V1__c'))*(mapofFieldWithvalue.get(QScore.Assignments_and_quizes_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Assignments_and_quizes_V1__c'))*4);
                    }
                    else if(QScore.Assignments_and_quizes_V1__c == 'NA' ){
                        
                    }  
                }
                
                if(QScore.Educators_V1__c != Null){
                    if(QScore.Educators_V1__c != 'NA'){
                        system.debug('QScore.Educators_V1__c :: ' + QScore.Educators_V1__c);
                        updatedScore.Educators_V1_Value__c = (MapofMainFieldWithScorevalue.get('Educators_V1__c'))*(mapofFieldWithvalue.get(QScore.Educators_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Educators_V1__c'))*(mapofFieldWithvalue.get(QScore.Educators_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Educators_V1__c'))*4);
                    }
                    else if(QScore.Educators_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Dedicated_Success_Manager_V1__c != Null){
                    if(QScore.Dedicated_Success_Manager_V1__c != 'NA'){
                        system.debug('QScore.Dedicated_Success_Manager_V1__c :: ' + QScore.Dedicated_Success_Manager_V1__c);
                        updatedScore.Dedicated_Success_Manager_V1_Value__c = (MapofMainFieldWithScorevalue.get('Dedicated_Success_Manager_V1__c'))*(mapofFieldWithvalue.get(QScore.Dedicated_Success_Manager_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Dedicated_Success_Manager_V1__c'))*(mapofFieldWithvalue.get(QScore.Dedicated_Success_Manager_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Dedicated_Success_Manager_V1__c'))*4);
                    }
                    else if(QScore.Dedicated_Success_Manager_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Salary_band_V1__c != Null){
                    if(QScore.Salary_band_V1__c != 'NA'){
                        system.debug('QScore.Salary_band_V1__c :: ' + QScore.Salary_band_V1__c);
                        updatedScore.Salary_band_V1_Value__c = (MapofMainFieldWithScorevalue.get('Salary_band_V1__c'))*(mapofFieldWithvalue.get(QScore.Salary_band_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Salary_band_V1__c'))*(mapofFieldWithvalue.get(QScore.Salary_band_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Salary_band_V1__c'))*4);
                    }
                    else if(QScore.Salary_band_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Certificates_V1__c != Null){
                    if(QScore.Certificates_V1__c != 'NA'){
                        system.debug('QScore.Certificates_V1__c :: ' + QScore.Certificates_V1__c);
                        updatedScore.Certificates_V1_Value__c = (MapofMainFieldWithScorevalue.get('Certificates_V1__c'))*(mapofFieldWithvalue.get(QScore.Certificates_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Certificates_V1__c'))*(mapofFieldWithvalue.get(QScore.Certificates_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Certificates_V1__c'))*4);
                    }
                    else if(QScore.Certificates_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Projects_Create_prod_from_scratch_V1__c != Null){
                    if(QScore.Projects_Create_prod_from_scratch_V1__c != 'NA'){
                        system.debug('QScore.Projects_Create_prod_from_scratch_V1__c :: ' + QScore.Projects_Create_prod_from_scratch_V1__c);
                        updatedScore.Projects_Create_prod_from_scratch_V1_V__c = (MapofMainFieldWithScorevalue.get('Projects_Create_prod_from_scratch_V1__c'))*(mapofFieldWithvalue.get(QScore.Projects_Create_prod_from_scratch_V1__c));
                        NeedMappingScoreNumerator += ((MapofMainFieldWithScorevalue.get('Projects_Create_prod_from_scratch_V1__c'))*(mapofFieldWithvalue.get(QScore.Projects_Create_prod_from_scratch_V1__c)));
                        NeedmappingScoreDenominator += ((MapofMainFieldWithScorevalue.get('Projects_Create_prod_from_scratch_V1__c'))*4);
                    }
                    else if(QScore.Projects_Create_prod_from_scratch_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(NeedMappingScoreNumerator != 0 ||  NeedmappingScoreDenominator != 0){
                    NeedMappingScoreAverage = NeedMappingScoreNumerator/NeedmappingScoreDenominator;
                    updatedScore.Need_Mapping__c = NeedMappingScoreNumerator;
                    updatedScore.Need_Mapping_Marks_Out_Of__c = NeedmappingScoreDenominator;
                }
                    
                else{
                    NeedMappingScoreAverage = 0;
                }
                system.debug('NeedMappingScoreAverage :: ' + NeedMappingScoreAverage);
                
                
                decimal NeedMappingScoreAveragePercentage = NeedMappingScoreAverage*100;
                
                /* ====================================== CLOSURE CODE ===================================================*/              
                
                decimal ClosureScoreNumerator = 0;
                decimal ClosureScoreDenominator = 0;
                decimal ClosureScoreAverage = 0;
                
                if(QScore.Reference_Price_V1__c != Null){
                    if(QScore.Reference_Price_V1__c != 'NA'){
                        system.debug('QScore.Reference_Price_V1__c :: ' + QScore.Reference_Price_V1__c);
                        updatedScore.Reference_Price_V1_Value__c = (MapofMainFieldWithScorevalue.get('Reference_Price_V1__c'))*(mapofFieldWithvalue.get(QScore.Reference_Price_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Reference_Price_V1__c'))*(mapofFieldWithvalue.get(QScore.Reference_Price_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Reference_Price_V1__c'))*4);
                    }
                    else if(QScore.Reference_Price_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Opportunity_Cost_V1__c != Null){
                    if(QScore.Opportunity_Cost_V1__c != 'NA'){
                        system.debug('QScore.Opportunity_Cost_V1__c :: ' + QScore.Opportunity_Cost_V1__c);
                        updatedScore.Opportunity_Cost_V1_Value__c = (MapofMainFieldWithScorevalue.get('Opportunity_Cost_V1__c'))*(mapofFieldWithvalue.get(QScore.Opportunity_Cost_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Opportunity_Cost_V1__c'))*(mapofFieldWithvalue.get(QScore.Opportunity_Cost_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Opportunity_Cost_V1__c'))*4);
                    }
                    else if(QScore.Opportunity_Cost_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Referrals_V1__c != Null){
                    if(QScore.Referrals_V1__c != 'NA'){
                        system.debug('QScore.Referrals_V1__c :: ' + QScore.Referrals_V1__c);
                        updatedScore.Referrals_V1_Value__c = (MapofMainFieldWithScorevalue.get('Referrals_V1__c'))*(mapofFieldWithvalue.get(QScore.Referrals_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Referrals_V1__c'))*(mapofFieldWithvalue.get(QScore.Referrals_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Referrals_V1__c'))*4);
                    }
                    else if(QScore.Referrals_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Price_Breakdown_V1__c != Null){
                    if(QScore.Price_Breakdown_V1__c != 'NA'){
                        system.debug('QScore.Price_Breakdown_V1__c :: ' + QScore.Price_Breakdown_V1__c);
                        updatedScore.Price_Breakdown_V1_Value__c = (MapofMainFieldWithScorevalue.get('Price_Breakdown_V1__c'))*(mapofFieldWithvalue.get(QScore.Price_Breakdown_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Price_Breakdown_V1__c'))*(mapofFieldWithvalue.get(QScore.Price_Breakdown_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Price_Breakdown_V1__c'))*4);
                    }
                    else if(QScore.Price_Breakdown_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Disposable_income_V1__c != Null){
                    if(QScore.Disposable_income_V1__c != 'NA'){
                        system.debug('QScore.Disposable_income_V1__c :: ' + QScore.Disposable_income_V1__c);
                        updatedScore.Disposable_income_V1_Value__c = (MapofMainFieldWithScorevalue.get('Disposable_income_V1__c'))*(mapofFieldWithvalue.get(QScore.Disposable_income_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Disposable_income_V1__c'))*(mapofFieldWithvalue.get(QScore.Disposable_income_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Disposable_income_V1__c'))*4);
                    }
                    else if(QScore.Disposable_income_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Return_on_investment_ROI_V1__c != Null){
                    if(QScore.Return_on_investment_ROI_V1__c != 'NA'){
                        system.debug('QScore.Return_on_investment_ROI_V1__c :: ' + QScore.Return_on_investment_ROI_V1__c);
                        updatedScore.Return_on_investment_ROI_V1_Value__c = (MapofMainFieldWithScorevalue.get('Return_on_investment_ROI_V1__c'))*(mapofFieldWithvalue.get(QScore.Return_on_investment_ROI_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Return_on_investment_ROI_V1__c'))*(mapofFieldWithvalue.get(QScore.Return_on_investment_ROI_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Return_on_investment_ROI_V1__c'))*4);
                    }
                    else if(QScore.Return_on_investment_ROI_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Negotiation_and_Urgency_V1__c != Null){
                    if(QScore.Negotiation_and_Urgency_V1__c != 'NA'){
                        system.debug('QScore.Negotiation_and_Urgency_V1__c :: ' + QScore.Negotiation_and_Urgency_V1__c);
                        updatedScore.Negotiation_and_Urgency_V1_Value__c = (MapofMainFieldWithScorevalue.get('Negotiation_and_Urgency_V1__c'))*(mapofFieldWithvalue.get(QScore.Negotiation_and_Urgency_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Negotiation_and_Urgency_V1__c'))*(mapofFieldWithvalue.get(QScore.Negotiation_and_Urgency_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Negotiation_and_Urgency_V1__c'))*4);
                    }
                    else if(QScore.Negotiation_and_Urgency_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Payment_Options_and_process_V1__c != Null){
                    if(QScore.Payment_Options_and_process_V1__c != 'NA'){
                        system.debug('QScore.Payment_Options_and_process_V1__c :: ' + QScore.Payment_Options_and_process_V1__c);
                        updatedScore.Payment_Options_and_process_V1_Value__c = (MapofMainFieldWithScorevalue.get('Payment_Options_and_process_V1__c'))*(mapofFieldWithvalue.get(QScore.Payment_Options_and_process_V1__c));
                        ClosureScoreNumerator += ((MapofMainFieldWithScorevalue.get('Payment_Options_and_process_V1__c'))*(mapofFieldWithvalue.get(QScore.Payment_Options_and_process_V1__c)));
                        ClosureScoreDenominator += ((MapofMainFieldWithScorevalue.get('Payment_Options_and_process_V1__c'))*4);
                    }
                    else if(QScore.Payment_Options_and_process_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(ClosureScoreNumerator != 0 ||  ClosureScoreDenominator != 0){
                    ClosureScoreAverage = ClosureScoreNumerator/ClosureScoreDenominator; 
                    updatedScore.Closure__c = ClosureScoreNumerator;
                    updatedScore.Closure_Marks_Out_Of__c = ClosureScoreDenominator;
                }
                    
                else{
                    ClosureScoreAverage = 0;
                }
                system.debug('ClosureScoreAverage :: ' + ClosureScoreAverage);
                
                
                decimal ClosureScoreAveragePercentage = ClosureScoreAverage*100;
                
                /* ====================================== SUBJECTIVE CODE ===================================================*/                
                
                decimal SubjectiveScoreNumerator = 0;
                decimal SubjectiveScoreDenominator = 0;
                decimal SubjectiveScoreAverage = 0;
                
                
                if(QScore.Storytelling_Deam_selling_V1__c != Null){
                    if(QScore.Storytelling_Deam_selling_V1__c != 'NA'){
                        system.debug('QScore.Storytelling_Deam_selling_V1__c :: ' + QScore.Storytelling_Deam_selling_V1__c);
                        updatedScore.Storytelling_Deam_selling_V1_Value__c = (MapofMainFieldWithScorevalue.get('Storytelling_Deam_selling_V1__c'))*(mapofFieldWithvalue.get(QScore.Storytelling_Deam_selling_V1__c));
                        SubjectiveScoreNumerator += ((MapofMainFieldWithScorevalue.get('Storytelling_Deam_selling_V1__c'))*(mapofFieldWithvalue.get(QScore.Storytelling_Deam_selling_V1__c)));
                        SubjectiveScoreDenominator += ((MapofMainFieldWithScorevalue.get('Storytelling_Deam_selling_V1__c'))*4);
                    }
                    else if(QScore.Storytelling_Deam_selling_V1__c == 'NA' ){
                        
                    }
                    
                }
                if(QScore.Empathy_V1__c != Null){
                    if(QScore.Empathy_V1__c != 'NA'){
                        system.debug('QScore.Empathy_V1__c :: ' + QScore.Empathy_V1__c);
                        updatedScore.Empathy_V1_Value__c = (MapofMainFieldWithScorevalue.get('Empathy_V1__c'))*(mapofFieldWithvalue.get(QScore.Empathy_V1__c));
                        SubjectiveScoreNumerator += ((MapofMainFieldWithScorevalue.get('Empathy_V1__c'))*(mapofFieldWithvalue.get(QScore.Empathy_V1__c)));
                        SubjectiveScoreDenominator += ((MapofMainFieldWithScorevalue.get('Empathy_V1__c'))*4);
                    }
                    else if(QScore.Empathy_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Confidence_Autho_Eng_Voice_Mod_V1__c != Null){
                    if(QScore.Confidence_Autho_Eng_Voice_Mod_V1__c != 'NA'){
                        system.debug('QScore.Confidence_Autho_Eng_Voice_Mod_V1__c :: ' + QScore.Confidence_Autho_Eng_Voice_Mod_V1__c);
                        updatedScore.Confidence_Autho_Eng_Voice_Mod_V1_Value__c = (MapofMainFieldWithScorevalue.get('Confidence_Autho_Eng_Voice_Mod_V1__c'))*(mapofFieldWithvalue.get(QScore.Confidence_Autho_Eng_Voice_Mod_V1__c));
                        SubjectiveScoreNumerator += ((MapofMainFieldWithScorevalue.get('Confidence_Autho_Eng_Voice_Mod_V1__c'))*(mapofFieldWithvalue.get(QScore.Confidence_Autho_Eng_Voice_Mod_V1__c)));
                        SubjectiveScoreDenominator += ((MapofMainFieldWithScorevalue.get('Confidence_Autho_Eng_Voice_Mod_V1__c'))*4);
                    }
                    else if(QScore.Confidence_Autho_Eng_Voice_Mod_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(QScore.Objection_handling_V1__c != Null){
                    if(QScore.Objection_handling_V1__c != 'NA'){
                        system.debug('QScore.Objection_handling_V1__c :: ' + QScore.Objection_handling_V1__c);
                        updatedScore.Objection_handling_V1_Value__c = (MapofMainFieldWithScorevalue.get('Objection_handling_V1__c'))*(mapofFieldWithvalue.get(QScore.Objection_handling_V1__c));
                        SubjectiveScoreNumerator += ((MapofMainFieldWithScorevalue.get('Objection_handling_V1__c'))*(mapofFieldWithvalue.get(QScore.Objection_handling_V1__c)));
                        SubjectiveScoreDenominator += ((MapofMainFieldWithScorevalue.get('Objection_handling_V1__c'))*4);
                    }
                    else if(QScore.Objection_handling_V1__c == 'NA' ){
                        
                    }
                    
                }
                
                if(SubjectiveScoreNumerator != 0 ||  SubjectiveScoreDenominator != 0){
                    SubjectiveScoreAverage = SubjectiveScoreNumerator/SubjectiveScoreDenominator; 
                    updatedScore.Subjective__c = SubjectiveScoreNumerator;
                    updatedScore.Subjective_Marks_Out_Of__c = SubjectiveScoreDenominator;
                }
                    
                else{
                    SubjectiveScoreAverage = 0;
                }
                system.debug('SubjectiveScoreAverage :: ' + SubjectiveScoreAverage);
                
                Decimal SubjectiveScoreAveragePercentage = SubjectiveScoreAverage*100;
                
                Decimal TotalNumerator = (openingScoreNumerator+ ProbingScoreNumerator + NeedMappingScoreNumerator + ClosureScoreNumerator + SubjectiveScoreNumerator);
                Decimal TotalDenominator = (OpeningScoreDenominator + ProbingScoreDenominator+NeedmappingScoreDenominator+ClosureScoreDenominator+SubjectiveScoreDenominator);
                
                Decimal TotalPercentage = 0;
                if(TotalNumerator != 0 ||  TotalDenominator != 0){
                    TotalPercentage =  (TotalNumerator/TotalDenominator)*100;
                	updatedScore.Quality_Score__c = TotalPercentage;
                }
                    
                else{
                    TotalPercentage = 0;
                }
                
                QScoreTobeUpdateList.add(updatedScore);
                system.debug('QScore.Lead__c ::' + QScore.Lead__c);
                if(QScore.Lead__c != null){
                    system.debug('updatedScore.Quality_Score__c :: ' + updatedScore.Quality_Score__c);
                    percentageByLeadId.put(QScore.Lead__c , updatedScore.Quality_Score__c);
                }
                
                if(!percentageByLeadId.isEmpty()){
                    for(Id leadId :  percentageByLeadId.keySet()){
                        Lead leadRec =  new Lead();
                        leadRec.Id = leadId;
                        leadRec.Quality_Score__c = percentageByLeadId.get(leadId);
                        leadRec.isQualityScoreUpdated__c = true;
                        leadListTOBeUpdated.add(leadRec);
                    }
                    system.debug('leadListTOBeUpdated :: ' + leadListTOBeUpdated);
                    if(!leadListTOBeUpdated.isEmpty()){
                        update leadListTOBeUpdated;
                    }
                }
            }
            
            if(!QScoreTobeUpdateList.isEmpty()){
                system.debug('QScoreTobeUpdateList :: ' + QScoreTobeUpdateList);
                update QScoreTobeUpdateList;
            }
        }
        
    }
    
}