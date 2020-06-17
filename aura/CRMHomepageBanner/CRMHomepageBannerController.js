({
    
    doInit : function(component, event, helper) {
        // grab the current contact data from SF
        var action = component.get('c.getFormData');
        $A.enqueueAction(action);
    },
    getFormData: function(component, event, helper) {
        var refreshContactAction = component.get("c.fetchFormData");

        // call method async
        refreshContactAction.setCallback(this, function(response) {
            var state = response.getState();

            var displayError = function (error) {
                component.set('v.errorMessage', error);
            };
            
            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var currentUserName = responseData.currentUserName;
                var userFirstName = responseData.userFirstName;
                
                // update our component contact with the updated info from system of record
                component.set("v.currentUserName", currentUserName);
                component.set("v.userFirstName", userFirstName);
            } else {
                displayError('Failed to get user info.')
            }
        });
        
        refreshContactAction.setBackground();
        // fire off the action
        $A.enqueueAction(refreshContactAction);
    }
})