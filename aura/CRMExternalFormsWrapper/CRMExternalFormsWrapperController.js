({
    /**
     * Open a component in a new workspace sub-tab.
     * See: https://salesforce.stackexchange.com/questions/208604/how-to-open-a-custom-lightning-component-tab-app-in-lightning-service-console/223112
     * Notice that the contactId uses a namespace.  As of Spring 19, all non-namespaced variables are stripped from the
     * URL.  Passing the component, which is needed for the Workpace API as well as passing an object literal that we
     * use here to pass in the data we need.
     */
    onShowSubTab : function(component, event, helper) {
        var tabDefinition = event.getParam('tabDefinition');

        var parentTabId = null;
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getFocusedTabInfo().then((response) => {
            parentTabId = response.tabId;

            return workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                pageReference: {
                    'type': 'standard__component',
                    'attributes': {
                        'componentName': tabDefinition.name
                    },
                    'state': {
                        'c__contactId': component.get('v.contactId')
                    }
                },
                focus: true
            });
        }).then((response) => {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: tabDefinition.label
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: tabDefinition.icon,
                iconAlt: tabDefinition.altText
            });
        }).catch(function(error) {
            console.log(error);
        });
    },

    refresh: function(component, event, helper) {
        var externalFormsLwcComp = component.find('externalForms');
        externalFormsLwcComp.refresh();
    }
})