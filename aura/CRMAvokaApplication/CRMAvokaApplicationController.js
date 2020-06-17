({
	doInit: function(component, event, helper) {
        helper.formatDates(component, event, helper);

        var transaction = component.get('v.transaction');
		
        if (transaction && transaction.caseId) {
            component.set('v.caseId', transaction.caseId);
        }
	},
    
    viewCase: function(component, event, helper) {
        var recordId = event.getSource().get("v.value");
        helper.openCase(recordId);
	},
    
    createCase: function(component, event, helper) {
        component.set('v.isLoading', true);
        
        var transaction = component.get('v.transaction');
        var action = component.get("c.createCaseForAppplication");

        action.setParams({
            "application": transaction,
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
                var caseId = responseData.caseId;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!caseId) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                component.set('v.caseId', caseId);
                
                helper.openCase(caseId);
            }
        });

        $A.enqueueAction(action);
    }
    
})