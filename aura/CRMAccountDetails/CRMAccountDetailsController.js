({
    doInit: function(component, event, helper) {
        let myPageRef = component.get('v.pageReference');
        let recordId = myPageRef.state.c__recordId;
        let accountNumber = myPageRef.state.c__accountNumber;
        component.set('v.recordId', recordId);
        component.set('v.accountNumber', accountNumber);

        var action = component.get('c.fetchAccountInfo');
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },

    closeTransaction: function(component, event, helper) {
        component.set('v.selectedTransactionNumber', '');
        component.set('v.viewDetail', '');

        let transactions = component.get('v.transactions');
        helper.updateTransactionState(component, helper, transactions);
    },

    fetchAccountInfo: function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.getAccountWithTransactions");

        // Setup the parameters for the controller function call
        var recordId = component.get("v.recordId");
        var accountNumber = component.get("v.accountNumber")
        var endDate = new Date();
        var startDate = new Date();
        startDate.setDate(endDate.getDate() - 60);
        action.setParams({
            "recordId": recordId,
            "accountNumber": accountNumber,
            "startDate" : startDate,
            "endDate" : endDate
        });

        action.setCallback(this, function(response) {
            component.set('v.errorMessage', '');
            component.set('v.isLoading', false);

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();

                // Check for error conditions
                if (responseData.error) {
                    component.set('v.errorMessage', responseData.error);
                    return;
                }
                if (!responseData.account || !responseData.transactions) {
                    component.set('v.errorMessage', 'An unexpected error occurred while retrieving the account information.');
                    return;
                }

                if (responseData.contact) {
                    // Determine the person's preferred name
                    var contact = responseData.contact;
                    var name = contact.FirstName;
                    if (contact.PreferredName__c !== name) {
                        name = contact.PreferredName__c;
                    }

                    // Set the component values from the response
                    component.set('v.contactName', name);
                } else {
                    component.set('v.isBusiness', true);
                }

                // Show the account and transaction information.
                component.set('v.account', responseData.account);
                helper.updateTransactionState(component, helper, responseData.transactions);

                // Determine which external form "actions" should be displayed.
                if (responseData.account.accountType === 'auto') {
                    component.set('v.formActions', 'auto-payoff,title-release,gap-cancellation,subsequent-action,skip-a-pay');
                }
                if (responseData.account.accountType === 'deposit') {
                    component.set('v.formActions', 'ach-dispute,visa-dispute');
                }
                if (responseData.account.accountType === 'creditcard') {
                    component.set('v.formActions', 'skip-a-pay,visa-dispute');
                }
                if (responseData.account.accountType === 'signature') {
                    component.set('v.formActions', 'skip-a-pay');
                }
                var externalFormsComp = component.find('externalForms');
                externalFormsComp.refresh();

                // Format the data
                helper.formatDates(component, event, helper);
                helper.formatAmounts(component, event, helper);
            } else {
                let errors = response.getError();
                let message = 'An unknown error occured.'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message += ' ' + errors[0].message;
                }
                component.set('v.errorMessage', message);
            }
        });

        $A.enqueueAction(action);
    },

    formatDates: function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },

    formatAmounts: function(component, event, helper) {
        helper.formatAmounts(component, event, helper);
    },

    handleTransactionClick: function(component, event, helper) {
        let transactionNumber = event.getParam('transactionNumber');
        component.set('v.selectedTransactionNumber', transactionNumber);

        let viewDetail = transactionNumber && transactionNumber.length > 0 ? 'viewDetail' : '';
        component.set('v.viewDetail', viewDetail);

        let transactions = component.get('v.transactions');
        helper.updateTransactionState(component, helper, transactions);
    }
})