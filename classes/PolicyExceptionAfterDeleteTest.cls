@isTest 
public class PolicyExceptionAfterDeleteTest {
 
    @isTest static void testPolicyExceptionAfterDeleteTrigger()
    { 
        System.debug('Creating test Loan...');
        LLC_BI__Loan__c testLoan = new LLC_BI__Loan__c(Name = 'testLoanForPolicyExceptionAfterDeleteTrigger');
        insert testLoan;
        String testLoanId = testLoan.Id;
        System.debug('Test Loan id = ' + testLoanId);
        
        System.debug('Creating test Loan policy exception record...');
        LLC_BI__Policy_Exception__c testPERecord = new LLC_BI__Policy_Exception__c();
        insert testPERecord;
        String testPERecordId = testPERecord.Id;
        System.debug('Policy Exception Id = ' + testPERecordId);
        
        System.debug('Deleting policy exception...'); 
        //fires trigger
        Database.DeleteResult deleteResult = Database.delete(testPERecord, true);
        System.assert(deleteResult.isSuccess());
    
     }
 
}