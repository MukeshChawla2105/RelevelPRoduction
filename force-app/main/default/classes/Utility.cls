public class Utility {

    public Static string getAoDetails(String leadId,String interviewId){
        try{
            /*system.debug('Admission officer ');
            system.debug('leadId-->'+leadId);
            system.debug('interviewId-->'+interviewId);
*/
            List<AO_Availability__c> AOAvailableList = new List<AO_Availability__c>();
            List<Interview__c> getInterviewList = new  List<Interview__c>();
            List<Audit_Officer__c> auditOfficerList = new List<Audit_Officer__c>();
            List<Admission_Officer_Tracking__c> AOTList = new List<Admission_Officer_Tracking__c>();
            Set<Id> InterviewIdSet = new Set<Id>();
            set<Id> AOOfficerIds = new set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            Integer AoAvailable =0;
            Integer AOOnBreak =0;
            Integer AOOnMeeting = 0;
            Integer NotAvailableAO = 0;
            Integer TotalAONumber = 0;
            
            AOAvailableList = [SELECT Id,Name,Status__c FROM AO_Availability__c WHERE CreatedDate =TODAY];
            auditOfficerList = [Select Id,AO__c From Audit_Officer__c];
            if(!auditOfficerList.isEmpty()){
                for(Audit_Officer__c AO_Rec: auditOfficerList){
                    AOOfficerIds.add(AO_Rec.AO__c);
                }
            }
            if(!AOAvailableList.isEmpty()){
                for(AO_Availability__c av: AOAvailableList){
                    if(av.Status__c =='Available'){
                        AoAvailable = AoAvailable +1;
                    }else if(av.Status__c == 'On Break'){
                        AOOnBreak = AOOnBreak +1;
                    }else if(av.Status__c == 'In Meeting'){
                        AOOnMeeting = AOOnMeeting + 1;
                    }else if(av.Status__c == 'Not Available'){
                        NotAvailableAO = NotAvailableAO + 1;
                    }
                }
                TotalAONumber = AOAvailableList.size();
            }
            
         /*   System.debug('AoAvailable Today :::'+AoAvailable);
            System.debug('AOOnBreak Today :::'+AOOnBreak);
            System.debug('AOOnMeeting Today :::'+AOOnMeeting);
            System.debug('NotAvailableAO Today :::'+NotAvailableAO);
            System.debug('TotalAONumber Today :::'+TotalAONumber);
            */
            //getInterviewList = [SELECT Id,Lead__c FROM Interview__c WHERE Id=:interviewId AND Lead__c=:leadId];
            
            Admission_Officer_Tracking__c AOT = new Admission_Officer_Tracking__c();
            AOT.AO_Available__c = Double.valueOf(AoAvailable);
            AOT.AO_On_Break__c = Double.valueOf(AOOnBreak);
            AOT.AO_On_Meeting__c = Double.valueOf(AOOnMeeting);
            AOT.Not_Available_AO__c = Double.valueOf(AOOfficerIds.size()) - Double.valueOf(TotalAONumber);
            AOT.Total_AO_Number__c = Double.valueOf(AOOfficerIds.size());
            AOT.AO_s_Checked_In__c = Double.valueOf(TotalAONumber);
            AOT.Interview_Id__c = interviewId;
            AOT.Lead__c = leadId;
            insert AOT;
            return 'success';
        }Catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());   
            return 'error';
        }
    }
}