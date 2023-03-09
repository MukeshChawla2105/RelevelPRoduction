global class ActivityModel {
    public list<ActivityDetails> activity_details;
    public class ActivityDetails{
        public string activity_type;
        public string search_by_value;
        public datetime activity_datetime;
        public string activity_note;//Description
        public string exam_name;
        public string exam_slug;
        public datetime exam_date;
        public datetime exam_booked_date;
        public decimal exam_score;
        public string skill_based_exam_score;
        public boolean is_qualified_in_exam;
        public datetime student_availability;
        public string payment_failure_reason;
        public string payment_type;
        public datetime date_of_payment;
        public decimal payment_amount;
        public string cohort_name;
        public string cohort_id;
        public string course_name;
        public string course_id;
        public string course_slug;
        public string email;
        public string revenue;
        public string state;
        public string user_id ;
        public string mobile;
        public string redirect_url;
        public string tier_info;
        //public string activity_event;
    }

    global class ReponseWrapper{
        global string success_code;
        global string error_code;
        global string error_message;
        global string activity_without_lead;
        global list<task> success_activity;
        global list<failuredata> failed_activity_list;
        global string activity_error_reason;
    }
    global class failuredata{
        global   task failed_activity;
        global   String error_reason;
    }
    public static ActivityModel parse(String json){
        return (ActivityModel) System.JSON.deserialize(json, ActivityModel.class);
    }
}