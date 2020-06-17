({
	doInit : function(component, event, helper) {
        var action = component.get('c.fetchTransactions');
        $A.enqueueAction(action);
	},
    fetchTransactions : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.errorMessage', '');
        
        var params = {
            status: component.get('v.status')
        }

        var action = component.get('c.fetchApplicationsByStatus');
        action.setParams(params);
        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
                component.set('v.errorMessage', error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var transactionGroups = responseData.groups;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!transactionGroups) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }
                
                component.set('v.transactionGroups', transactionGroups);
            } else {
                showError('An unknown error occured.');
            }
            
        });

        action.setBackground();
        $A.enqueueAction(action);
        
    }
})