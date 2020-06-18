@IsTest
private with sharing class ExternalFormsControllerTest {

    @IsTest
    private static void testHappyPath() {
        List<String> permissionSets = new List<String> { 'Helix_Common_Forms' };
        User testUser = TestDataFactory.createUser('Member Contact Center Agent', 'RUL - MCC', permissionSets);

        Test.startTest();

        List<Map<String, Object>> formDefinitions = null;
        Boolean hasAccessToForms = false;
        System.runAs(testUser) {
            formDefinitions = ExternalFormsController.getFormDefinitions('all');
            hasAccessToForms = ExternalFormsController.hasAccessToForms();
        }

        Test.stopTest();

        System.assert(formDefinitions.size() > 0);
        System.assertEquals(true, hasAccessToForms);

        Map<String, Object> autoPayoffDef = null;
        for (Map<String, Object> formDef : formDefinitions) {
            if (formDef.get('id') == 'auto-payoff') {
                autoPayoffDef = formDef;
                break;
            }
        }
        System.assertNotEquals(null, autoPayoffDef);
        System.assertEquals('c__CRMAutoPayoffFormWrapper', autoPayoffDef.get('tabComponentName'));

        // TODO:  Need to assert the user doesn't have access to forms that are not allowed.
        // This can be done once an advanced form is added.
    }

}