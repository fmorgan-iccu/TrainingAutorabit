({
    formatDates: function(component, event, helper) {
        if (!moment) {
            return;
        }

        var account = component.get('v.account');
        if (account && account.nextPaymentDate) {
            var formattedDate = moment(account.nextPaymentDate).format('M/D/YYYY');
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
    },

    setSelectedTransaction: function(component, transaction) {
        let newTransaction = Object.assign({}, transaction);

        //set classes for selected transaction
        let balanceSign = newTransaction.balance < 0 ? 'negative' : '';
        component.set('v.selectedTransactionBalanceSign', balanceSign);

        // Format the date and currency fields.
        if (moment) {
            if (newTransaction.effectiveDate) {
                newTransaction.effectiveDate = moment(newTransaction.effectiveDate).format('M/D/YYYY');
            }
            if (newTransaction.postDate) {
                newTransaction.postDate = moment(newTransaction.postDate).format('M/D/YYYY');
            }
        }
        if (numeral) {
            if (newTransaction.amount) {
                newTransaction.amount = numeral(newTransaction.amount).format('$0,000.00');
            }
            if (newTransaction.balance) {
                newTransaction.balance = numeral(newTransaction.balance).format('$0,000.00');
            }
        }
        component.set('v.selectedTransaction', newTransaction);
    },

    updateTransactionState: function(component, helper, transactions) {
        let selectedTransactionNumber = component.get('v.selectedTransactionNumber');
        let newTransactions = [];
        for (let t of transactions) {
            // Clone the transaction
            let newTransaction = Object.assign({}, t);

            // When a transaction is selected, all of the transactions are considered to be in detail view which
            // displays a compact view.
            newTransaction.transactionDetailView = selectedTransactionNumber && selectedTransactionNumber.length > 0;

            // Ensure that only one transaction is selected and save this for the detail view.
            newTransaction.selected = t.transactionNumber === selectedTransactionNumber;
            if (newTransaction.selected) {
                helper.setSelectedTransaction(component, newTransaction);
            }

            // Finally add the new transaction object to the list.
            newTransactions.push(newTransaction);
        }
        component.set('v.transactions', newTransactions); // Update the transactions to force a re-render.
    }

})