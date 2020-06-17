({
    doInit: function(component, event, helper) {
        // Convert the namespaced variable in the page reference to the local contact Id attribute.
        // As of Spring 19, all non-namespaced variables are stripped from the URL.
        let myPageRef = component.get('v.pageReference');
        let contactId = myPageRef.state.c__contactId;
        component.set('v.contactId', contactId);
    },

    onRequireLogin : function(component, event, helper) {
        // Relay the LWC event(s) to the CRMSystemLogins component.
        var systems = event.getParam('systems');
        for (var loginSystem in systems) {
            var s = systems[loginSystem];
            var myEvent = $A.get('e.c:RequireSystemOfRecordLogin');
            myEvent.setParam('system', s);
            myEvent.fire();
        }
    },

    onPageReferenceChange: function(component, event, helper) {
        var myPageRef = component.get('v.pageReference');
        var contactId = myPageRef.state.c__contactId;
        component.set('v.contactId', contactId);
    }
})