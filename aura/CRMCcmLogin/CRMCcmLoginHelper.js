({
    showError : function(component, message) {
        component.set('v.errorMessage', message);
    },

    setIsAuthedCcm: function(component, helper) {
        helper.setIsAuthedCcmVars(component, helper);

        var e = $A.get('e.c:CCMLogin');
        e.fire();
    },

    setIsAuthedCcmVars: function(component, helper) {
        component.set('v.isAuthedCcm', true);
        component.set('v.showLogin', false);

        helper.updateVisuals(component, helper);
    },

    resetIsAuthedCcm: function(component, helper) {
       helper.resetIsAuthedCcmVars(component, helper);

        var e = $A.get('e.c:CCMLogout');
        e.fire();
    },

    resetIsAuthedCcmVars: function(component, helper) {
        component.set('v.isAuthedCcm', false);
        component.set('v.showLogin', true);

        helper.updateVisuals(component, helper);
    },

    updateVisuals: function(component, helper) {
        var allowCcmLogin = component.get('v.allowCcmLogin');
        var hideAfterLogin = component.get('v.hideAfterLogin');
        var isAuthedCcm = component.get('v.isAuthedCcm');
        if (!allowCcmLogin) {
            component.set('v.loginContainerClass', 'containerHidden');
        } else if (isAuthedCcm) {
            if (hideAfterLogin) {
                component.set('v.loginContainerClass', 'containerHidden');
            } else {
                component.set('v.loginContainerClass', 'containerFullyAuthed');
                component.set('v.containerBackground', 'background-image: linear-gradient(115deg, rgba(5, 141, 15, 0.8), rgba(75, 206, 20, 0.7)), url(' + $A.get('$Resource.idahoRollingMountains') + ');');
            }
        } else {
            component.set('v.loginContainerClass', 'containerNotAuthed');
            component.set('v.containerBackground', 'background-image: linear-gradient(115deg, rgba(255, 110, 42, 0.8), rgba(243, 155, 41, 0.7)), url(' + $A.get('$Resource.idahoRollingMountains') + ');');
        }
    }
})