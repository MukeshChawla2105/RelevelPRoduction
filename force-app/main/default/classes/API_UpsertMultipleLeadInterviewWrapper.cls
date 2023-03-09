public without sharing class API_UpsertMultipleLeadInterviewWrapper {

    public String relevel_interview_id;
	public String lead_id;
    public string lead_version;
    //public string status;

    public static API_UpsertMultipleLeadInterviewWrapper parse(String json) {
		return (API_UpsertMultipleLeadInterviewWrapper) System.JSON.deserialize(json, API_UpsertMultipleLeadInterviewWrapper.class);
	}
}