({

    doInit : function(component, event, helper) {
        helper.formatDates(component, event, helper);
        helper.formatNumbers(component, event, helper);

        var transaction = component.get('v.Transaction');
        var creditDebit = (transaction.isCredit ? 'Credit' : 'Debit');
        component.set('v.creditDebitHeader', creditDebit);
    },
    
    formatDates : function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },
    
    formatNumbers : function(component, event, helper) {
        helper.formatNumbers(component, event, helper);
    },

    transactionSelected : function(component, event, helper) {
        component.set('v.selected', true);
        component.set('v.transactionDetailView', true);
    },

})