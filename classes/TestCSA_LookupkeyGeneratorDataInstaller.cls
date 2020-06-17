@IsTest
private class TestCSA_LookupkeyGeneratorDataInstaller {
    static testMethod void install() {
        nFORCE__Group__c testGroup = createGroup('nCino Administration', 'admin');
        Test.testInstall(new CSA_LookupkeyGeneratorDataInstaller(), null);
    }

    static testMethod void uninstall() {
        Id UninstallerId = UserInfo.getUserId();
        nFORCE__Group__c testGroup = createGroup('nCino Administration', 'admin');
        nFORCE__Route__c testRoute = createRoute('LookupKey Generator', 'c__CSA_LookupkeyGenerator', 'lookupkey-generator');
        nFORCE__Route_Group__c testRouteGroup1 = createRouteGroup(testGroup.Id, testRoute.Id, null, 100);
        nFORCE__Route_Group__c testRouteGroup2 = createRouteGroup(testGroup.Id, testRoute.Id, testRoute.Id, 101);
        nFORCE__System_Properties__c testSystemProperty = createSystemProperty();
        Test.testUninstall(new CSA_LookupkeyGeneratorDataInstaller());

    }

    private static nForce__Group__c createGroup(String nam, String app) {
        nForce__Group__c newG = new nForce__Group__c(
                Name = nam,
                nFORCE__App__c = app);

        Database.insert(newG);
        return newG;
    }

    private static nForce__Route__c createRoute(String nam, String body, String app) {
        nForce__Route__c newR = new nForce__Route__c(
                Name = nam,
                nFORCE__Body__c = body,
                nForce__App__c = app,
                nFORCE__Navigation__c = 'nforce__navigation',
                nFORCE__Sub_Navigation__c = 'nforce__sub_navigation',
                nFORCE__Topbar__c = 'nforce__topbar');

        Database.insert(newR);
        return newR;
    }

    private static nFORCE__Route_Group__c createRouteGroup(Id groupId, Id routeId, Id parentRouteId, Decimal display) {
        nFORCE__Route_Group__c newRG = new nFORCE__Route_Group__c(
                nFORCE__Group__c = groupId,
                nFORCE__Route__c = routeId,
                nFORCE__Parent_Route__c = parentRouteId,
                nFORCE__Order__c = display);

        Database.insert(newRG);
        return newRG;
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