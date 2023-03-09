public without sharing class AOAvalibilityModule {
    public AOAvalibilityModule() {

    }

    public static AO_Availability__c fetchAvailableAO(){
        try{
            List<AO_Availability__c> AOListTobeSend = new List<AO_Availability__c >();
            AO_Availability__c avilableAO = new AO_Availability__c();
            AOListTobeSend = [select id,Audited_Officer__c,Ideal_TIme__c,Meeting_Url__c,
                             Status__c,Meeting_Unique_Id__c	 from AO_Availability__c 
                             where createddate = today and status__c =: Constant.AVAILABLE_STATUS_TAG order by ideal_Time__c desc limit 1 ];
            avilableAO = [select id,Audited_Officer__c,Ideal_TIme__c,Meeting_Url__c,
                             Status__c,Meeting_Unique_Id__c	 from AO_Availability__c 
                             where createddate = today and status__c =: Constant.AVAILABLE_STATUS_TAG and Id =:AOListTobeSend[0].Id FOR UPDATE];
            if(!AOListTobeSend.isEmpty()){
                /*AOListTobeSend[0].status__c = 'In Meeting';
                update  AOListTobeSend;*/


                return avilableAO;
            }
            return null;
        }catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Interview__c currentInterviewStatus(String LeadId){
        List<Interview__c> InterviewRec= new List<Interview__c>();
        try {
            System.debug('LeadId =====> ' + LeadId);
            InterviewRec = [SELECT Active__c,Id,Interviewer_Email__c,Interviewer_Name__c,Interviewer__c,Lead__c,Meeting_URL__c,Name,Status__c 
                                                FROM Interview__c
                                                Where Lead__c =: LeadId and Active__c = true];
            System.debug('InterviewRec =====> ' + InterviewRec[0]);
            
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            System.debug('trace ======> ' + e.getStackTraceString());
        }
        return InterviewRec[0];
    }

    @AuraEnabled
    public static String UpdateInterviewStatus(String Buttonlabel, Interview__c interRec){
        string msg = '';
        try {
            System.debug('Buttonlabel ====> ' + Buttonlabel);
            System.debug('interRec ======> ' + interRec);
            if (Buttonlabel=='End Meeting' && interRec.Status__c != 'Completed') {
                interRec.Status__c = 'Completed';
                update interRec;
                msg = 'SUCCESS';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return msg;
    }
}