({
	doInit : function(component, event, helper) {
		var action = component.get('c.refreshCards');
        $A.enqueueAction(action);
	},
    
    handleSystemOfRecordLogin : function(component, event, helper) {
        var action = component.get('c.refreshCards');      
        $A.enqueueAction(action);
	},
    
    refreshCards : function(component, event, helper) {

        component.set('v.isLoading', true);
        helper.displayError('', component);

		var action = component.get("c.fetchCardData");

        action.setParams({
            "contactId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.isLoading', false);

            if (component.isValid() && state === "SUCCESS") {
				var payload = response.getReturnValue();

                var error = payload.error;

                if (error) {
                    helper.displayError(error, component);
                    return;
                } else {
                    helper.displayError('', component);
                }

                var debit = payload.debit;
                var credit = payload.credit;

                component.set('v.debitCards', debit);
                component.set('v.creditCards', credit);
            } else {
                helper.displayError('There was an unknown error loading card data.', component);
            }
        });

        $A.enqueueAction(action);
	},
    
    authenticate : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.displayError('', component);
        
        var action = component.get("c.authenticateWithCreditCardProvider");
        
        var usernameField = component.find('username');
        var passwordField = component.find('password');
        var username = usernameField.get('v.value');
        var password = passwordField.get('v.value');
        
        action.setParams({
            "username": username,
            "password": password
        });
        
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            
            var state = response.getState();
            component.set('v.isLoading', false);

            if (component.isValid() && state === "SUCCESS") {
				var payload = response.getReturnValue();

                var error = payload.error;

                if (error) {
                    helper.displayError(error, component);
                    return;
                }

                // Refresh the cards
                var action = component.get('c.refreshCards');      
                $A.enqueueAction(action);
            } else {
                helper.displayError('There was an unknown error authenticating.', component);
            }
        });

        $A.enqueueAction(action);
    },
    
    cardNeedsUpdate : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.displayError('', component);

        let requests = event.getParam('request');
        let requestJSON = JSON.stringify([requests]);
        let contactId = component.get("v.recordId");

        var action = component.get("c.updateCardStatuses");

        action.setParams({
            contactId: contactId,
            requestJSON: requestJSON
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.isLoading', false);

            if (component.isValid() && state === "SUCCESS") {
				var payload = response.getReturnValue();

                var error = payload.error;

                if (error) {
                    helper.displayError(error, component);
                    return;
                } else {
                    helper.displayError('', component);
                }

                var action = component.get('c.refreshCards');
                $A.enqueueAction(action);
            } else {
                helper.displayError('There was an unknown error updating card data.', component);
            }
        });
        
        $A.enqueueAction(action);
    }
})