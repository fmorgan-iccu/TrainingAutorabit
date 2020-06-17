({
    doInit : function(component, event, helper) {
        // grab the current account data from SF
        var action = component.get('c.refreshFromSF');
        $A.enqueueAction(action);
    },
    
    refreshFromSF :  function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        
        // call method async
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var account = response.getReturnValue();

                component.set("v.headerAccount", account);
                
                // now that we have loaded the initial data, go out and refresh it from the system of record
                var refreshAction = component.get("c.refreshFromSystemOfRecord");
                $A.enqueueAction(refreshAction);
            }
            
        });
        
        action.setBackground();
        // fire off the action
        $A.enqueueAction(action);
    },
    
    refreshFromSystemOfRecord : function(component, event, helper) {
        component.set('v.errorMessage', '');
        // create action to call our APEX controller method refreshContent
        var refreshAccountAction = component.get("c.refreshContent");
        
        // pass our loaded sf account id to the refresh method
        refreshAccountAction.setParams({
            "orgNumber": component.get("v.headerAccount.OrganizationNumber__c")
        });
        
        // call method async
        refreshAccountAction.setCallback(this, function(response) {
            var state = response.getState();
            
            var displayError = function (error) {
                component.set('v.errorMessage', error);
            };
            
            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var account = responseData.account;
                var error = responseData.error;
                
                if (!account) {
                    displayError(error);
                    var action = component.get('c.notifyRequireSystemOfRecordLogin');
                    $A.enqueueAction(action);
                    return;
                }
                
                // update our component account with the updated info from system of record
                component.set("v.headerAccount", account);

                var action = component.get('c.notifyAccountRefresh');
                $A.enqueueAction(action);
            } else {
                displayError('Failed to refresh from system of record.')
            }
        });
        
        refreshAccountAction.setBackground();
        // fire off the action
        $A.enqueueAction(refreshAccountAction);
    },
    
    notifyAccountRefresh : function(component, event, helper) {
        var myEvent = $A.get("e.c:AccountRefresh");
        myEvent.setParams({"account": component.get("v.headerAccount")});
        myEvent.fire();
    },
    
    notifyRequireSystemOfRecordLogin : function(component, event, helper) {
        var myEvent = $A.get("e.c:RequireSystemOfRecordLogin");
        myEvent.setParam('system', 'cCRMDnaLogin');
        myEvent.fire();
    },

    handleSystemOfRecordLogin: function(component, event, helper) {
        var action = component.get('c.refreshFromSystemOfRecord');
        $A.enqueueAction(action);
    }

})