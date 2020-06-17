({
    doInit: function(component, event, helper) {
		var action = component.get('c.fetchTransactions');      
        $A.enqueueAction(action);
        
        var action = component.get('c.updateContact');      
        $A.enqueueAction(action);

        helper.formatDates(component, event, helper);
        helper.formatAmounts(component, event, helper);
    },
    
    closeModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    fetchTransactions : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        var action = component.get("c.getAccountTransactions");
        var account = component.get("v.account");

        var endDate = new Date(); // Right now
 		var startDate = new Date();
        startDate.setDate(endDate.getDate() - 30);

        action.setParams({
            "accountMap": account,
            "startDate" : startDate,
            "endDate" : endDate
        });

        action.setCallback(this, function(response) {
            component.set('v.errorMessage', '');
            component.set('v.isLoading', false);

            var showError = function(error) {
                console.log(error);
                component.set('v.errorMessage', error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var transactions = responseData.transactions;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!transactions) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                component.set('v.transactions', transactions);
            }
        });

        $A.enqueueAction(action);
    },

    updateContact: function(component, event, helper) {
        var action = component.get("c.getContact");
        var contactId = component.get("v.recordId");

        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var contact = responseData.contact;
                var name = contact.FirstName;

                if (contact.PreferredName__c !== name) {
                    name = contact.PreferredName__c;
                }

                component.set('v.contactName', name);
            }
        });

        $A.enqueueAction(action);
    },
    
    formatDates: function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },
    
    formatAmounts: function(component, event, helper) {
        helper.formatAmounts(component, event, helper);
    }
})