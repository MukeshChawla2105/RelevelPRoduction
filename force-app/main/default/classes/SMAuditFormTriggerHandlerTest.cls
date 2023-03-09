@isTest
public class SMAuditFormTriggerHandlerTest {
    
    @isTest static void SMAuditFormTest(){
        SM_Call_Audit_Form__c SMAud = new SM_Call_Audit_Form__c();
        SMAud.Closure_Score__c = 6;
        SMAud.Closure_Area_of_Improvement__c = 'Need improvement';
        SMAud.Closure_Call_Number__c = 'Call 1';
        
        Test.startTest();
        insert SMAud; 
        Test.stopTest();
    }

}