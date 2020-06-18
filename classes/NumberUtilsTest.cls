@isTest
private class NumberUtilsTest {
    @isTest
    private static void testFormatting() {
        double positiveAmount = (double)11.45;
        double evenDollarAmount = (double)11.00;
        double evenTensAmount = (double)11.40;
        double negativeAmount = (double)-11.45;
        double subDollarAmount = (double)0.45;
        double subDollarNegativeAmount = (double)-0.45;
        
        String positiveResult = NumberUtils.formatCurrency(positiveAmount);
        String evenDollarResult = NumberUtils.formatCurrency(evenDollarAmount);
        String evenTensResult = NumberUtils.formatCurrency(evenTensAmount);
        String negativeResult = NumberUtils.formatCurrency(negativeAmount);
        String subDollarResult = NumberUtils.formatCurrency(subDollarAmount);
        String subDollarnegativeResult = NumberUtils.formatCurrency(subDollarNegativeAmount);
        
        System.assert(positiveResult.equals('$11.45'), positiveResult);
        System.assert(evenDollarResult.equals('$11.00'), evenDollarResult);
        System.assert(evenTensResult.equals('$11.40'), evenTensResult);
        System.assert(negativeResult.equals('-$11.45'), negativeResult);
        System.assert(subDollarResult.equals('$0.45'), subDollarResult);
        System.assert(subDollarnegativeResult.equals('-$0.45'), subDollarnegativeResult);

        double nullAmount = null;
        String nullResult = NumberUtils.formatCurrency(nullAmount);
        System.assert(nullResult == null, subDollarResult);
    }
}