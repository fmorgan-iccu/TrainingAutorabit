({
	formatAmounts: function(component, event, helper) {
        if (!numeral) {
            return;
        }

        var account = component.get('v.account');

        if (account) {
            var currencyFormat = "$0,000.00";

            var availableBalance = numeral(account.availableBalance).format(currencyFormat);
            component.set('v.availableBalance', availableBalance);

            var currentBalance = numeral(account.currentBalance).format(currencyFormat);
            component.set('v.currentBalance', currentBalance);
        }
    }
})