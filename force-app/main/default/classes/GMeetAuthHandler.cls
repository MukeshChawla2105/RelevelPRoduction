public class GMeetAuthHandler {
	private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    private static final String GOOGLESERVICEACCOUNT = 'test-sf-relevel@testapisf.iam.gserviceaccount.com';
    private static final String AUDIENCE_CLAIM = 'https://www.googleapis.com/oauth2/v4/token';
    private static final String CERTIFICATE = 'googlecalendarcertificate'; // this is the name/label of the jks certificate we uplodaded in salesforce
    private static final String SCOPE = 'https://www.googleapis.com/auth/calendar';
    
    private static final String REPORTENDPOINT = 'https://admin.googleapis.com/admin/reports/v1';
    private static final String REPORTSCOPE = 'https://www.googleapis.com/auth/admin.reports.audit.readonly';
    
    
    
    
    public static String getAccessToken(String subId) {
    	Auth.JWT jwt = new Auth.JWT();
        jwt.setAud(AUDIENCE_CLAIM);
        jwt.setIss(GOOGLESERVICEACCOUNT);
        jwt.setSub(subId); //'harmanpreet.singh@relevel.com'
        jwt.setAdditionalClaims(new Map<String, Object>{ 'scope' => SCOPE });
      
        Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE);
      
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
          jwt.getAud(),
          jws
        );
      
        return bearer.getAccessToken();
  	}
    
    public static String getReportAccessToken(String subId) {
    	Auth.JWT jwt = new Auth.JWT();
        jwt.setAud(AUDIENCE_CLAIM);
        jwt.setIss(GOOGLESERVICEACCOUNT);
        jwt.setSub(subId); //'harmanpreet.singh@relevel.com'
        jwt.setAdditionalClaims(new Map<String, Object>{ 'scope' => REPORTSCOPE });
      
        Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE);
      
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
          jwt.getAud(),
          jws
        );
      
        return bearer.getAccessToken();
  	}
}