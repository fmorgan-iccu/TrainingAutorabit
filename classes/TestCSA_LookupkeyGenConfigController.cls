@IsTest
private class TestCSA_LookupkeyGenConfigController {
    static testMethod void isInstalledFalse() {
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.getIsInstalled();

        Test.stopTest();
    }

    static testMethod void isInstalledTrue() {
        nFORCE__System_Properties__c testSystemProperty = createSystemProperty();
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.getIsInstalled();

        Test.stopTest();
    }

    static testMethod void install() {
        nFORCE__Group__c testGroup = createGroup('nCino Administration', 'admin');
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.install();

        Test.stopTest();
    }
    
    static testMethod void installFail() {
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.install();

        Test.stopTest();
    }

    static testMethod void uninstall() {
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.uninstall();

        Test.stopTest();
    }

    static testMethod void finish() {
        CSA_LookupkeyGeneratorConfigController LGC = new CSA_LookupkeyGeneratorConfigController();

        Test.startTest();

        LGC.finish();

        Test.stopTest();
    }
    
    private static nForce__Group__c createGroup(String nam, String app) {
        nForce__Group__c newG = new nForce__Group__c(
                Name = nam,
                nFORCE__App__c = app);

        Database.insert(newG);
        return newG;
    }

    private static nFORCE__System_Properties__c createSystemProperty() {
        nFORCE__System_Properties__c newSP = new nFORCE__System_Properties__c(
                Name = '123456789987645321132',
                nFORCE__Category_Name__c = 'CSA Lookupkey Generator',
                nFORCE__Is_Active__c = true,
                nFORCE__Key__c = 'Lookupkey Generator Data Installer',
                nFORCE__Value__c = 'true');

        Database.insert(newSP);
        return newSP;
    }
}