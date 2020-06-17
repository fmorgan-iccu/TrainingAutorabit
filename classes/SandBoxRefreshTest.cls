@isTest
public class SandBoxRefreshTest {

    @isTest   
    private static void testRefresh() {
        
        // Setup a test user to ensure that it is updated properly.
        Id sysAdminId = [SELECT id FROM Profile WHERE Name = 'System Administrator'][0].id;
        User adminUser = new User(
            alias='dbunique',
            email='dbarnett@iccu.com.invalid',
            emailEncodingKey='ISO-8859-1',
            isActive=false,
            lastName='Barnett',         
            languageLocaleKey='en_US', 
            localeSidKey='en_US',
            profileId=sysAdminId,
            timeZoneSidKey='America/Denver',
            username='dbarnett@iccu.com.sandbox'            
        );
        System.debug(adminUser);
        insert adminUser;
        
        
        Test.startTest();
        SandBoxRefresh sbr = new SandBoxRefresh();
        sbr.runApexClass(null);
        Test.stopTest();
        
        // Assert the behavior
        List<User> admins = [
            SELECT id,
                email,
                isActive
            FROM User
            WHERE username = 'dbarnett@iccu.com.sandbox'
        ];
        System.assertEquals(1, admins.size());
        //System.assertEquals('dbarnett@iccu.com', admins[0].email); // This can't be done because Salesforce requires email confirmation
        System.assertEquals(true, admins[0].isActive);
        
        // Query and assert that the Avoka delivery processor records have been created
        List<avoka__Transact_Delivery_Processor__c> deliveryProcessors = [
            SELECT id,
                avoka__Abandoned_Processor_Class__c,
                avoka__Completed_Processor_Class__c,
                avoka__Saved_Processor_Class__c,
                name
            FROM avoka__Transact_Delivery_Processor__c
        ];
        for (String formName : SandBoxRefresh.FORM_NAMES) {
            avoka__Transact_Delivery_Processor__c formProcessor = null; 
            for (avoka__Transact_Delivery_Processor__c processor : deliveryProcessors) {
                if (processor.name == formName) {
                    formProcessor = processor;
                    break;
                }
            }
            System.assert(formProcessor != null, 'A processor record for form ' + formName + ' was not found.');
            System.assertEquals(SandBoxRefresh.DELIVERY_PROCESSOR, formProcessor.avoka__Saved_Processor_Class__c);
            System.assertEquals(SandBoxRefresh.DELIVERY_PROCESSOR, formProcessor.avoka__Completed_Processor_Class__c);
            System.assertEquals(SandBoxRefresh.DELIVERY_PROCESSOR, formProcessor.avoka__Abandoned_Processor_Class__c);
        }
    }
    
}