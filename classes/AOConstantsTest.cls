@IsTest
private class AOConstantsTest {

    @IsTest
    private static void testFormXmlVersion() {
        AOConstants.FormXmlVersion version = AOConstants.getFormXmlVersion(null);
        System.assertEquals(AOConstants.FormXmlVersion.NONE, version);

        version = AOConstants.getFormXmlVersion('V1');
        System.assertEquals(AOConstants.FormXmlVersion.V1, version);

        version = AOConstants.getFormXmlVersion('2');
        System.assertEquals(AOConstants.FormXmlVersion.V2, version);

        version = AOConstants.getFormXmlVersion('invalid');
        System.assertEquals(AOConstants.FormXmlVersion.NONE, version);
    }

}