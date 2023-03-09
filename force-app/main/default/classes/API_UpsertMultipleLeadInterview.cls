@RestResource(urlMapping = '/inteview_mapping/*')
global without sharing class API_UpsertMultipleLeadInterview{
    @httpPost
    global static responseWrapper LeadInterviewCreation(){
        List<Interview__c> interviewList = new List<Interview__c>();
        responseWrapper response = new responseWrapper();
        
        API_UpsertMultipleLeadInterviewWrapper interviewDetails_relevel = API_UpsertMultipleLeadInterviewWrapper.parse(RestContext.request.requestBody.tostring());
        
        string respo = Utility.getAoDetails(interviewDetails_relevel.lead_id, interviewDetails_relevel.relevel_interview_id);
        
        system.debug('respo-->'+respo);
        
        if(respo == 'success'){
            AO_Availability__c aoDetails = AOAvalibilityModule.fetchAvailableAO();
            
            try{
                if ( aoDetails == null ){
                    response.message = 'User Not Found';
                    response.status_code = '404';
                    response.relevel_interview_id = interviewDetails_relevel.relevel_interview_id;
                    response.LeadId = interviewDetails_relevel.lead_id;
                    Lead ld = new lead();
                    ld.Interview_Request_Generated__c = true;
                    ld.Id = interviewDetails_relevel.lead_id;
                    update ld;
                }
                else{
                    if (interviewDetails_relevel.lead_id != null){
                        Lead Ld = new Lead();
                        ld.Interview_Id__c = interviewDetails_relevel.relevel_interview_id;
                        Ld.Id = interviewDetails_relevel.lead_id;
                        Ld.Lead_Version__c = 'V1';
                        ld.OwnerId = aoDetails.Audited_Officer__c;
                        ld.Audit_Officer__c = aoDetails.Audited_Officer__c;
                        ld.Lead_Stage__c = 'Unassigned';
                        ld.Intent__c = null;
                        ld.Communication__c = null;
                        ld.Financials__c = null;
                        ld.AO_Interview_Status_Manual__c = null;
                        ld.Relevance_Experience__c = null;
                        ld.Interview_Feedback_Notes_AO__c = null;
                        ld.Admission_Letter_Sent__c = null;
                        ld.Book_Later_Flow__c = false;
                        ld.Interview_Request_Generated__c = true;
                        update Ld;
                    }
                    Interview__c interviewRec = new Interview__c();
                    interviewRec.Lead__c = interviewDetails_relevel.lead_id;
                    interviewRec.Relevel_Interview_Id__c = interviewDetails_relevel.relevel_interview_id;
                    interviewRec.Interviewer__c = aoDetails.Audited_Officer__c;
                    interviewRec.Active__c = true;
                    interviewRec.Meeting_URL__c = aoDetails.Meeting_Url__c;
                    interviewRec.Meeting_Unique_Id__c = aoDetails.Meeting_Unique_Id__c;
                    interviewRec.OwnerId = aoDetails.Audited_Officer__c;
                    if ( aoDetails == null ){
                        interviewRec.Status__c = 'Interviewer Not Found';
                    }
                    else{
                        interviewRec.Status__c = 'Started';
                    }
                    Database.SaveResult successRespo = Database.insert ( interviewRec, false );
                    System.debug('successRespo =====> ' + successRespo);
                    if ( successRespo.isSuccess() ){
                        Interview__c interviewRecordInserted = [Select Id, Interviewer__c, Interviewer_Name__c, Interviewer_Email__c, Lead__c, Meeting_URL__c, Relevel_Interview_Id__c, Status__c
                                                                From Interview__c
                                                                where Id = :successRespo.getId()];
                        
                        response.interviewer_id = interviewRecordInserted.Interviewer__c;
                        response.interviewer_name = interviewRecordInserted.Interviewer_Name__c;
                        response.interviewer_email = interviewRecordInserted.Interviewer_Email__c;
                        response.meeting_url = aoDetails.Meeting_Url__c;
                        response.relevel_interview_id = interviewRecordInserted.Relevel_Interview_Id__c;
                        response.status = interviewRecordInserted.Status__c;
                        response.LeadId = interviewRecordInserted.Lead__c;
                        response.message = 'Inserted';
                        response.status_code = '200';
                        System.debug('Successfully inserted Invoice. Invoice ID: ' + successRespo.getId());
                    }
                    else{
                        for ( Database.Error objErr : successRespo.getErrors() ){
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('error:' + objErr.getFields());
                            response.message = 'Error Code' + objErr.getStatusCode() + ' Error Msg ' + objErr.getMessage();
                            response.status_code = '400';
                        }
                    }
                }
            } catch ( Exception e ){
                system.debug(e.getMessage());
                System.debug('at Line number =====> ' + e.getLineNumber());
                response.status_code = '400';
                response.message = e.getMessage();
            }
        }
        return response;
    }
    
    global class responseWrapper{
        global String interviewer_id;            //message string
        global String interviewer_name;        // Success String
        global String interviewer_email;
        global string meeting_url;
        global string relevel_interview_id;
        global String status;
        global String LeadId;
        global String message;
        global String status_code;
        
    }
    
}