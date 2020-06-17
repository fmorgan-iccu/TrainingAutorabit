@IsTest
private class TestCSA_LookupkeyGeneratorController {
    static testMethod void setupPicklist() {
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.getAvailbleObjects();

        Test.stopTest();
    }

    static testMethod void findResultsPlatform() {
        LLC_BI__Field_Map__c testFieldMap = createFieldMap();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'LLC_BI__Field_Map__c';
        LGC.findRecords();

        system.assertEquals(1, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void findResultsNforce() {
        nFORCE__Group__c testGroup = createGroup();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nFORCE__Group__c';
        LGC.findRecords();

        system.assertEquals(1, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void findResultsNdesign() {
        nDESIGN__Screen__c testScreen = createScreen();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nDESIGN__Screen__c';
        LGC.findRecords();

        system.assertEquals(1, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeyIndividualPlatform() {
        LLC_BI__Field_Map__c testFieldMap = createFieldMap();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'LLC_BI__Field_Map__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.record_id = testFieldMap.Id;
        LGC.buildKey();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeyIndividualNforce() {
        nFORCE__Group__c testGroup = createGroup();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nFORCE__Group__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.record_id = testGroup.Id;
        LGC.buildKey();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeyIndividualNdesign() {
        nDESIGN__Screen__c testScreen = createScreen();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nDESIGN__Screen__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.record_id = testScreen.Id;
        LGC.buildKey();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeyIndividualNdesignError() {
        nDESIGN__Screen__c testScreen = createScreen();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nDESIGN__Screen__c';
        LGC.record_id = testScreen.Id;
        LGC.buildKey();

        Test.stopTest();
    }

    static testMethod void buildKeysPlatform() {
        LLC_BI__Field_Map__c testFieldMap = createFieldMap();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'LLC_BI__Field_Map__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.buildAllKeys();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeysNforce() {
        nFORCE__Group__c testGroup = createGroup();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nFORCE__Group__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.buildAllKeys();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    static testMethod void buildKeysNdesign() {
        nDESIGN__Screen__c testScreen = createScreen();
        CSA_LookupkeyGeneratorController LGC = new CSA_LookupkeyGeneratorController();

        Test.startTest();

        LGC.object_api = 'nDESIGN__Screen__c';
        LGC.findRecords();
        system.assertEquals(1, LGC.records.size());
        LGC.buildAllKeys();
        system.assertEquals(0, LGC.records.size());

        Test.stopTest();
    }

    private static LLC_BI__Field_Map__c createFieldMap() {
        LLC_BI__Field_Map__c newFM = new LLC_BI__Field_Map__c(Name = 'Test');

        Database.insert(newFM);
        return newFM;
    }

    private static nFORCE__Group__c createGroup() {
        nFORCE__Group__c newG = new nFORCE__Group__c(Name = 'Test Groups', nFORCE__App__c = 'test1234567890');

        Database.insert(newG);
        return newG;
    }

    private static nDESIGN__Screen__c createScreen() {
        nDESIGN__Screen__c newS = new nDESIGN__Screen__c(Name = 'Test Screen');

        Database.insert(newS);
        return newS;
    }
}