public class NumberUtils {
    public static String formatCurrency(double amount) {
        if (amount == null) {
            return null;
        }
        
        List<String> currencyFormat = new String[]{'0', 'number', '###,###,##0.00'};
       	String formattedAmount = String.format(amount.format(), currencyFormat);
        
        if (formattedAmount.indexOf('-') == 0) { // Need to insert a $
            String truncatedAmount = formattedAmount.substring(1); // APEX doesn't have a proper insertAtIndex method, so...
            formattedAmount = '-$' + truncatedAmount;
        } else {
            formattedAmount = '$' + formattedAmount;
        }

        integer decimalLocation = formattedAmount.indexOf('.');

        if (decimalLocation == formattedAmount.length() - 3) { // Decimal in right place
            // DO NOTHING
        } else if (decimalLocation == formattedAmount.length() - 2) { // Missing a 0            
            formattedAmount += '0';
        } else { // Missing a decimal altogether
            formattedAmount += '.00';
        }

        return formattedAmount;
    }
}