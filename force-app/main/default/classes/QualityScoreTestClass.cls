@isTest public class QualityScoreTestClass {
    @isTest(SeeAllData=true)
    public static void insertQualityScoreRec(){
        Quality_Score__c qaRec = new Quality_Score__c();
        qaRec.Greeting__c = string.valueOf('0');
        insert qaRec;
    }
}