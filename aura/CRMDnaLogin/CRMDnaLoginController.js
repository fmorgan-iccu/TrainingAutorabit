({
    doInit: function(component, event, helper) {
        // Default as many values on the login form as possible.
        var today = (new Date()).toISOString().substring(0,10);
        component.set('v.postingDate', today);
        component.set('v.effectiveDate', today);
        helper.updateVisuals(component, helper);
    },

    getIsAuthenticated : function(component, event, helper) {
        return component.get('v.isAuthedCore') && component.get('v.isAuthedBusinessServices');
    },

    handleCoreLogin: function (component, event, helper) {
        helper.setIsAuthedCoreVars(component, helper);
    },

    handleBusinessServicesLogin: function (component, event, helper) {
        helper.setIsAuthedBusinessServicesVars(component, helper);
    },

    handleCoreLogout: function (component, event, helper) {
        helper.resetIsAuthedCoreVars(component, helper);
    },

    handleBusinessServicesLogout: function (component, event, helper) {
        helper.resetIsAuthedBusinessServicesVars(component, helper);
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
        var username = component.get('v.username');
        var passwordInput = component.find('dnaPassword');
        var password = passwordInput.get('v.value');
        var cashBox = component.get('v.cashBox');
        var postingDate = component.get('v.postingDate');
        var effectiveDate = component.get('v.effectiveDate');
        var networkNodeName = component.get('v.networkNodeName');

        var isMissingUsername = !username || username.length == 0;
        var isMissingPassword = !password || password.length == 0;

        // Verify that the required values are collected.  If the cash box and network node name
        // are not provided, the Business Services API will not be called (see the controller
        // for more info).
        if (isMissingUsername || isMissingPassword) {
            component.set('v.errorMessage', 'Please enter your username and password.');
            component.set('v.isAuthenticating', false);
            return;
        }

        component.set('v.isLoading', true);
        var loginAction = component.get('c.authenticateDna');
        loginAction.setParams({
            'username': username,
            'password': password,
            'cashBox': cashBox,
            'postingDate': postingDate,
            'effectiveDate': effectiveDate,
            'networkNodeName': networkNodeName
        });
        loginAction.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                var values = response.getReturnValue();
                if (values.isAuthedCore) {
                    helper.setIsAuthedCore(component, helper);
                }
                if (values.isAuthedBusinessServices) {
                    helper.setIsAuthedBusinessServices(component, helper);
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
                helper.resetIsAuthedCore(component, helper);
                helper.resetIsAuthedBusinessServices(component, helper);
            } else {
                helper.showError('Failed to properly logout.');
            }
        });
        $A.enqueueAction(logoutAction);
    },

    resetIsAuthedCore: function(component, event, helper) {
        helper.resetIsAuthedCore(component, helper);
    },

    resetIsAuthedBusinessServices: function(component, event, helper) {
        helper.resetIsAuthedBusinessServices(component, helper, true);
    },

    showLogin: function(component, event, helper) {
        component.set('v.showLogin', true);
    },

    updateState: function(component, event, helper) {
        var values = event.getParam('arguments');
        if (values && values[0]) {
            values = values[0];
            if (values.isAuthedCore) {
                helper.setIsAuthedCore(component, helper);
            } else {
                helper.resetIsAuthedCore(component, helper);
            }
            if (values.isAuthedBusinessServices) {
                helper.setIsAuthedBusinessServices(component, helper);
            } else {
                helper.resetIsAuthedBusinessServices(component, helper);
            }

            component.set('v.username', values.username);
            component.set('v.cashBox', values.cashBox);
            component.set('v.networkNodeName', values.networkNodeName);
            component.set('v.allowFullLogin', values.allowDnaFullLogin);

            helper.updateVisuals(component, helper);
        }
    },

    computeSize: function(component, event, helper) {
        var loginContainer = component.get('main-container');
        var computedCSS = getComputedStyle(loginContainer);
        debugger

        if (computedCSS.width <= "400px"){
            loginContainer.style.flexDirection = "column";
        }
    }

})