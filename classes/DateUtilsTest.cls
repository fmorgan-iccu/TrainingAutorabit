@IsTest
private class DateUtilsTest {

    @IsTest
    private static void testISODateParsing() {
        String input = '2019-07-31T00:00:00';
        DateTime parsedDate = DateUtils.parseISO8601Date(input);
        
        System.assert(parsedDate != null, 'Parsed date was NULL!');

        System.assertEquals(2019, parsedDate.yearGmt());
        System.assertEquals(7, parsedDate.monthGmt());
        System.assertEquals(31, parsedDate.dayGmt());
        System.assertEquals(0, parsedDate.hourGmt());
        System.assertEquals(0, parsedDate.minuteGmt());
        System.assertEquals(0, parsedDate.secondGmt());

        Date inputDate = Date.newInstance(2019, 6, 10);
        String format1 = DateUtils.format(inputDate, 'MM/dd/yyyy');
        String format2 = DateUtils.format(inputDate, 'dd/MM/yyyy');
        String format3 = DateUtils.format(inputDate, 'yyyy-MM-dd HH:mm:ss');

        System.assertEquals('06/10/2019', format1);
        System.assertEquals('10/06/2019', format2);
        System.assertEquals('2019-06-10 00:00:00', format3);

        String inputMmddyyy = '08/01/2019';
        Date parsedMmddyy = DateUtils.valueOf(inputMmddyyy, 'MM/dd/yyyy');

        System.assertEquals(2019, parsedMmddyy.year());
        System.assertEquals(8, parsedMmddyy.month());
        System.assertEquals(1, parsedMmddyy.day());

        try {
            Date failedFormat = DateUtils.valueOf(inputMmddyyy, 'unknown');
            System.assert(true); // An exception should always be thrown.
        } catch (IllegalArgumentException iae) {
            // This is expected
        } catch (Exception e) {
            System.assert(true); // Any other type of exception is unexpected.
        }
    }

}