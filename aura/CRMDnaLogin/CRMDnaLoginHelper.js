({
    showError : function(component, message) {
        component.set('v.errorMessage', message);
    },

    // TODO:  This function doesn't appear to be used.  Need to determine if this should be removed.
    shouldShowLogin: function(component) {
        var isAuthedCore = component.get('v.isAuthedCore');
        var isAuthedBusinessServices = component.get('v.isAuthedBusinessServices');
        var allowFullLogin = component.set('v.allowFullLogin');
        return !isAuthedCore || (!isAuthedBusinessServices && allowFullLogin);
    },

    setIsAuthedCore: function(component, helper) {
        component.set('v.isAuthedCore', true);
        component.set('v.showLogin', false);

        helper.updateVisuals(component, helper);

        var e = $A.get('e.c:DNACoreLogin');
        e.fire();
    },

    setIsAuthedBusinessServices: function(component, helper) {
        component.set('v.isAuthedBusinessServices', true);
        component.set('v.showLogin', false);

        helper.updateVisuals(component, helper);

        var e = $A.get('e.c:DNABusinessServicesLogin');
        e.fire();
    },

    resetIsAuthedCore: function(component, helper) {
        component.set('v.isAuthedCore', false);
        component.set('v.showLogin', true);

        helper.updateVisuals(component, helper);

        var e = $A.get('e.c:SystemOfRecordLogout');
        e.fire();
    },

    resetIsAuthedBusinessServices: function(component, helper, showFullLogin) {
        if (showFullLogin === null || typeof showFullLogin === 'undefined') {
            showFullLogin = false;
        }
        component.set('v.isAuthedBusinessServices', false);
        component.set('v.showLogin', true);
        component.set('v.showFullLogin', showFullLogin);
        
        helper.updateVisuals(component, helper);

        var e = $A.get('e.c:SystemOfRecordLogout');
        e.fire();
    },

    updateVisuals: function(component, helper) {
        var allowFullLogin = component.get('v.allowFullLogin');
        var hideAfterLogin = component.get('v.hideAfterLogin');
        var isAuthedCore = component.get('v.isAuthedCore');
        var isAuthedBusinessServices = component.get('v.isAuthedBusinessServices');

        // Determine if the user is fully/partially/not logged in.
        var isFullyLoggedIn =  isAuthedCore && (isAuthedBusinessServices || !allowFullLogin);
        var isNotLoggedIn = !isAuthedCore && !isAuthedBusinessServices;
        var isPartiallyLoggedIn = !isFullyLoggedIn && !isNotLoggedIn;
        component.set('v.isFullyLoggedIn', isFullyLoggedIn);
        component.set('v.isNotLoggedIn', isNotLoggedIn);
        component.set('v.isPartiallyLoggedIn', isPartiallyLoggedIn);

        if (isAuthedCore && (isAuthedBusinessServices || !allowFullLogin)) {
            component.set('v.showLogin', false);
            if (hideAfterLogin) {
                component.set('v.loginContainerClass', 'containerHidden');
            } else {
                component.set('v.loginContainerClass', 'containerFullyAuthed');
                component.set('v.containerBackground', 'background-image: linear-gradient(115deg, rgba(5, 141, 15, 0.8), rgba(75, 206, 20, 0.7)), url(' + $A.get('$Resource.idahoRollingMountains') + ');');
            }
        } else if (isAuthedCore || isAuthedBusinessServices) {
            if (isAuthedCore) {
                component.set('v.showLogin', false);
            }
            component.set('v.loginContainerClass', 'containerPartiallyAuthed');
            component.set('v.containerBackground', 'background-image: linear-gradient(115deg, rgba(74, 148, 244, 0.8), rgba(23, 60, 166, 0.7)), url(' + $A.get('$Resource.idahoRollingMountains') + ');');
        } else {
            component.set('v.loginContainerClass', 'containerNotAuthed');
            component.set('v.containerBackground', 'background-image: linear-gradient(115deg, rgba(255, 110, 42, 0.8), rgba(243, 155, 41, 0.7)), url(' + $A.get('$Resource.idahoRollingMountains') + ');');
        }
    }
})