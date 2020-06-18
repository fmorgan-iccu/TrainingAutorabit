({
    // on component load 
	doInit : function(component, event, helper) {
		var updateOfferingAction = component.get("c.updateOfferings");
        $A.enqueueAction(updateOfferingAction);
        
        var updatePromotionsAction = component.get("c.updatePromotions");
        $A.enqueueAction(updatePromotionsAction);
	},
    updateOfferings : function(component, event, helper) {
        var action = component.get("c.getProductOfferings");
        action.setParams({
            "contactId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();  

            var displayError = function(error) {
                console.log(error);
                // TODO update the UI with the error.
            };

            if (component.isValid() && state === "SUCCESS") {
                console.log('success: got offerings response from server');

                var responseData = response.getReturnValue();

                if (!responseData) {
                    displayError('An unknown error occurred getting offerings. Please try again later.');
                    return;
                }

                if (responseData.error) {
                    displayError(responseData.error);
                    return;
                }

                var offeringGroups = responseData.offeringGroups;
                component.set("v.productOfferings", offeringGroups);
            } else {
                displayError('There was an error getting offerings. Please try again later');
            }
        });

        action.setBackground();
        // fire off the action 		
        $A.enqueueAction(action);
    },
    updatePromotions : function(component, event, helper) {
        component.set('v.isLoading', true);
        var action = component.get("c.getMarketingPromotions");
        action.setParams({
            "contactId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();  

            var displayError = function(error) {
                console.log(error);
                // TODO update the UI with the error.
            };

            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();

                if (!responseData) {
                    displayError('An unknown error occurred getting offerings. Please try again later.');
                    return;
                }

                component.set("v.promotions", responseData);
            } else {
                displayError('There was an error getting promotions. Please try again later.');
            }
        });
        
        action.setBackground();
        // fire off the action 		
        $A.enqueueAction(action);
    },
    handleContactRefresh : function(component, event, helper) {
        var updateOfferingAction = component.get("c.updateOfferings");
        $A.enqueueAction(updateOfferingAction);
    },
    handleSystemOfRecordLogin : function(component, event, helper) {
        var updateOfferingAction = component.get("c.updateOfferings");
        $A.enqueueAction(updateOfferingAction);
    }
})