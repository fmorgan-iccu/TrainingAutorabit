({
    doInit: function(component, event, helper) {
        // Convert the namespaced variable in the page reference to the local contact Id attribute.
        // As of Spring 19, all non-namespaced variables are stripped from the URL.
        let myPageRef = component.get('v.pageReference');
        let contactId = myPageRef.state.c__contactId;
        component.set('v.contactId', contactId);
    },

    openTravelForm : function(component, event, helper) {
        helper.openNewTab(component, 
            {
                name: 'c__CRMTravelFormWrapper',
                label: 'Travel Form',
                icon: 'utility:edit_form',
                altText: 'Travel Form'
            }
        )
    },

    openHotCardForm : function(component, event, helper) {
        helper.openNewTab(component, 
            {
                name: 'c__CRMHotCardFormWrapper',
                label: 'Card Management',
                icon: 'utility:edit_form',
                altText: 'Card Management'
            }
        )
    },

    openTitleReleaseForm : function(component, event, helper) {
        helper.openNewTab(component, 
            {
                name: 'c__CRMTitleReleaseFormWrapper',
                label: 'Title Release',
                icon: 'utility:edit_form',
                altText: 'Title Release Form'
            }
        )
    },

    openAutoPayoffForm : function(component, event, helper) {
        helper.openNewTab(component, 
            {
                name: 'c__CRMAutoPayoffFormWrapper',
                label: 'Auto Payoff',
                icon: 'utility:edit_form',
                altText: 'Auto Payoff'
            }
        )
    }
})