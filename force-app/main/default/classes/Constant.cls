public without sharing class Constant{
    public static final String COMPLETED_OFFER = 'Completed';
    public static final String QUALIFIED_OFFER = 'Qualified';
    public static final String DISQUALIFIED_OFFER = 'Disqualified';
    public static final string REJECTED_OFFER = 'Rejected';
    public static final string ACCEPTED_OFFER = 'Accepted';
    public static final string SKIPPED_INTERVIEW = 'Skipped';
    public static final string AVAILABLE_STATUS_TAG = 'Available';
    public static final string IdLeadNewFlowRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('New Flow').getRecordTypeId();
    public static final string IdLeadOldFlowRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Old Flow').getRecordTypeId();
    public static string noShowQueueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'NO Show Queue' limit 1].Id;

    // ============================================ Interview Object Fields Constant =================================================
    public static final String INTERVIEW_STATUS_INTERVIEW_MISSED = 'Interviewer Missed';
    public static final String INTERVIEW_STATUS_MISSED = 'Missed';
}