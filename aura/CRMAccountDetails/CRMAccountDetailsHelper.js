({
	formatDates: function(component, event, helper) {
        if (!moment) {
            return;
        }
        
        var account = component.get('v.account');
        if (account && account.nextPaymentDate) {
            var formattedDate = moment(account.nextPaymentDate).format('M-D-YYYY');
            component.set('v.nextPaymentDate', formattedDate);
        }
    },
    
    formatAmounts: function(component, event, helper) {
        if (!numeral) {
            return;
        }
        
        var account = component.get('v.account');
        
        if (account) {
            var interestRate = numeral(account.interestRate).format('0.00%');
            component.set('v.interestRate', interestRate);

            var currencyFormat = "$0,000.00";
            
            if (account.availableBalance) {
                var availableBalance = numeral(account.availableBalance).format(currencyFormat);
                component.set('v.availableBalance', availableBalance);
            }
            
            if (account.currentBalance) {
                var currentBalance = numeral(account.currentBalance).format(currencyFormat);
                component.set('v.currentBalance', currentBalance);
            }
            
            if (account.nextPaymentAmount) {
                var nextPaymentAmount = numeral(account.nextPaymentAmount).format(currencyFormat);
                component.set('v.nextPaymentAmount', nextPaymentAmount);
            }
        }
    }
    
})