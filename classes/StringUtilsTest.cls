@isTest
private class StringUtilsTest {
	@isTest
    private static void testHappyPath() {
        String input = 'happy day';
        String expected = 'Happy Day';
            
		String output = StringUtils.toProperCase(input);
        System.assert(output.equals(expected), 'Expected: ' + expected + ' | Output was: ' + output);
    }
    
    @isTest
    private static void testUnhappyPath() {
        String output = StringUtils.toProperCase(null);
        System.assert(output == null);
        
        String emptyInput = '';
        output = StringUtils.toProperCase(emptyInput);
        System.assert(output.equals(emptyInput));
    }
}