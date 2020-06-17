@isTest
private class QuickLinksControllerTest {
    @isTest
    private static void testHappyPath() {
        QuickLink__c[] links = QuickLinksController.getQuickLinks();

        System.assert(links != null);

        // Iterate through the links to make sure that they are sorted 
        // by Order__c.
        for (integer i = 0; i < links.size(); i++) {
            if (i > 0) {
                QuickLink__c previous = links[i-1];
                QuickLink__c current = links[i];

                System.assert(previous.Order__c <= current.Order__c);
            }
        }
    }
}