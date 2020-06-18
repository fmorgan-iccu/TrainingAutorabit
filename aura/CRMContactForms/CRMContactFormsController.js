({
    doInit: function(component, event, helper) {
        let myPageRef = component.get('v.pageReference');
        let contactId = myPageRef.state.c__contactId;
        component.set('v.contactId', contactId);
    }
})