@IsTest public with sharing class USStateUtilsTest {
    
    @IsTest
    private static void testHappyPath() {
        List<Map<String, Object>> usStates = USStateUtils.getStates();
        System.assert(usStates.size() > 0);

        Map<String, Object> firstState = usStates[0];
        System.assert(firstState.containsKey('name'));
        System.assert(firstState.containsKey('code'));

        USStateUtils.State idaho = USStateUtils.getState('ID');
        System.assertEquals('Idaho', idaho.name);
        System.assertEquals('ID', idaho.code);

        USStateUtils.State nullState = USStateUtils.getState(null);
        System.assertEquals(null, nullState);

        nullState = USStateUtils.getState('INVALID');
        System.assertEquals(null, nullState);
    }

}