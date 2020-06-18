({
    DNA_LOGIN_COMP : 'cCRMDnaLogin',
    CCM_LOGIN_COMP : 'cCRMCcmLogin',

    showError : function(component, message) {
        component.set('v.errorMessage', message);
    },

    getAuthenticationInfo: function(component, event, isDoInit) {
        // Because multiple components can broadcast that a login is required at the same time, 
        // this code will prevent this request from being done more than once.
        var isGettingAuthInfo = component.get('v.isGettingAuthInfo');
        if (isGettingAuthInfo) {
            return;
        }
        component.set('v.isGettingAuthInfo', true);

        // To prevent every component from having to make a callout to get the current login state
        // and default values, make one call here.
        var getAuthenticationInfo = component.get('c.getAuthenticationInfo');
        getAuthenticationInfo.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var values = response.getReturnValue();

                component.set('v.allowLogout', values.allowLogout);

                // Update all of the child login component states.
                var childLoginComponents = this.getLoginChildComponents(component);
                childLoginComponents.forEach(function(c) {
                    c.updateState(values);
                });

                // If the component is being initialized for the first time on a wide display
                // region, hide the CCM login.
                var wideDisplay = component.get('v.wideDisplay');
                if (isDoInit && wideDisplay) {
                    var ccmLoginComponent = this.getLoginChildComponent(component, this.CCM_LOGIN_COMP);
                    ccmLoginComponent.hideLogin();
                }

                // Reset the state so future calls can check.
                component.set('v.isGettingAuthInfo', false);
            } else {
                this.showError(component, 'Failed to get system login info.');
            }
        });
        $A.enqueueAction(getAuthenticationInfo);
    },

    getLoginChildComponents : function(component) {
        var childComponents = [];

        var dnaLoginComp = component.find(this.DNA_LOGIN_COMP);
        if (dnaLoginComp) {
            childComponents.push(dnaLoginComp);
        }
        
        var ccmLoginComp = component.find(this.CCM_LOGIN_COMP);
        if (ccmLoginComp) {
            childComponents.push(ccmLoginComp);
        }

        return childComponents;
    },

    getLoginChildComponent : function(component, system) {
        if (system !== this.DNA_LOGIN_COMP &&
            system !== this.CCM_LOGIN_COMP)
        {
            return null;
        }
        var loginComp = component.find(system);

        return loginComp;
    }
})