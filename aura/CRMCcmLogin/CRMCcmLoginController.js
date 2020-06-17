({
    doInit: function(component, event, helper) {
    },

    getIsAuthenticated : function(component, event, helper) {
        return component.get('v.isAuthedCcm');
    },

    handleCcmLogin: function (component, event, helper) {
        helper.setIsAuthedCcmVars(component, helper);
    },

    handleCcmLogout: function (component, event, helper) {
        helper.resetIsAuthedCcmVars(component, helper);
    },

    handlePasswordKeyPress: function(component, event, helper) {
        // When the user presses the enter key...
        if (event.which == 13) {
            var loginAction = component.get("c.processLogin");
            $A.enqueueAction(loginAction);
        }
    },

    hideLogin: function(component, event, helper) {
        component.set('v.showLogin', false);
    },

    processLogin : function(component, event, helper) {
        // Block multiple login attempts from occuring; prevent locking a user out.
        if (component.get('v.isAuthenticating') == true) {
            return;
        }
        component.set('v.isAuthenticating', true);

        // clear out any old errors
        helper.showError(component, '');

        // Retrieve all of the form values needed for authentication.
        var usernameInput = component.find('ccmUsername');
        var username = usernameInput.get('v.value');
                
        var passwordInput = component.find('ccmPassword');
        var password = passwordInput.get('v.value');

        var isMissingUsername = !username || username.length == 0;
        var isMissingPassword = !password || password.length == 0;

        // TODO:  Consider using standard field validation:
        // passwordInput.set('v.errors', [{message:'Enter your username and password.'}]);
        // Verify that the required values are collected.  If the cash box and network node name
        // are not provided, the Business Services API will not be called (see the controller
        // for more info).
        if (isMissingUsername || isMissingPassword) {
            component.set('v.errorMessage', 'Please enter your username and password.');
            component.set('v.isAuthenticating', false);
            return;
        }

        component.set('v.isLoading', true);
        var loginAction = component.get('c.authenticateCcm');
        loginAction.setParams({
            'username': username,
            'password': password
        });
        loginAction.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                var values = response.getReturnValue();
                if (values.isAuthedCcm) {
                    helper.setIsAuthedCcm(component, helper);
                }

                helper.showError(component, values.error);
            } else {
                component.set('v.errorMessage', 'Unable to validate credentials at this time.');
            }
            
            component.set('v.isAuthenticating', false);
        });
        $A.enqueueAction(loginAction);
    },
    
    processLogout : function(component, event, helper) {
        var logoutAction = component.get('c.logout');
        logoutAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === 'SUCCESS') {
                helper.resetIsAuthedCcm(component, helper);
            } else {
                helper.showError('Failed to properly logout.');
            }
        });
        $A.enqueueAction(logoutAction);
    },
    
    resetIsAuthedCcm: function(component, event, helper) {
        helper.resetIsAuthedCcm(component, helper);
    },

    showLogin: function(component, event, helper) {
        component.set('v.showLogin', true);
    },
    
    updateState: function(component, event, helper) {
        var values = event.getParam('arguments');
        if (values && values[0]) {
            values = values[0];
            if (values.isAuthedCcm) {
                helper.setIsAuthedCcm(component, helper);
            } else {
                helper.resetIsAuthedCcm(component, helper);
            }
            
            component.set('v.username', values.username);
            component.set('v.allowCcmLogin', values.allowCcmLogin);

            helper.updateVisuals(component, helper);
        }
    }

})