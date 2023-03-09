@isTest
public class BatchToTransferLeadFromDeactUserTest {
    
    @testSetup
    static void setup() {
        List<Lead> LeadList = new List<Lead>();
        for(integer i=0; i<10; i++){
            Lead newLeadRec = new Lead();		//Company,LastName,status, Goal_Interested_In__c, Source_Intent__c
            newLeadRec.Company = 'Utilab '+i;
            newLeadRec.LastName = 'Jackson ' +i; 
            newLeadRec.Status = 'Follow-up';
            newLeadRec.Source_Intent__c = 'Business-Development';
            newLeadRec.Goal_Interested_In__c = 'Frontend-Development';
            LeadList.add(newLeadRec);
        }
        insert LeadList;
    }
    
    @isTest static void test() {
        Test.startTest();
        BatchToTransferLeadFromDeactivatedUser uca = new BatchToTransferLeadFromDeactivatedUser();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }

}