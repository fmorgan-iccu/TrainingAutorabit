({
    doInit: function(component, event, helper) {
        helper.getAuthenticationInfo(component, event, true);
    },

    // If an event is triggered to require a system of record login, check the authentication state.
    handleRequireSystemOfRecordLogin: function(component, event, helper) {
        helper.getAuthenticationInfo(component, event, false);
    },

    // Called any time any of the system login events are called so that this component can update
    // its state to properly reflect all system states.
    handleAuthenticationStateChange: function(component, event, helper) {
        helper.showError(component, '');

        // Determine if all of the children are authenticated.
        var isAuthenticated = true;
        var childLoginComponents = helper.getLoginChildComponents(component);
        childLoginComponents.forEach(function(c) {
            isAuthenticated = isAuthenticated && c.getIsAuthenticated();
        });
        component.set('v.isAuthenticated', isAuthenticated);
    },

    // Logout all of the systems.
    processLogout: function(component, event, helper) {
        var childLoginComponents = helper.getLoginChildComponents(component);
        childLoginComponents.forEach(function(c) {
            c.processLogout();
        });
    },
   
    // Attempt to authenticate each of the components.
   	processLogin: function(component, event, helper) {
        component.set('v.isLoading', true);

        var childLoginComponents = helper.getLoginChildComponents(component);
        childLoginComponents.forEach(function(c) {
            c.processLogin();
        });
   	}

})