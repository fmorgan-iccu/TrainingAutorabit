@IsTest
private without sharing class PdfUtilsTest {

    @IsTest
    private static void testGenerateXfdf() {
        Test.startTest();

        Map<String, String> fieldValues = new Map<String, String> { 'PDF_FIELD' => 'field_value' };
        String xfdf = PdfUtils.generateXfdf('PATH_TO_PDF', fieldValues);

        try {
            PdfUtils.generateXfdf(null, fieldValues);
            System.assert(false, 'Failed to validate that the path is required.');
        } catch (IllegalArgumentException e) {
            // This is expected
        }

        try {
            PdfUtils.generateXfdf('PATH_TO_PDF', null);
            System.assert(false, 'Failed to validate that the field values are required.');
        } catch (IllegalArgumentException e) {
            // This is expected
        }

        Test.stopTest();

        System.assert(xfdf.contains('<f href="PATH_TO_PDF"/>'));
        System.assert(xfdf.contains('<field name="PDF_FIELD"><value>field_value</value></field>'));
    }

}