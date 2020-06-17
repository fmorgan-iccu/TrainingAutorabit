({
    /**
     * Open a component in a new tab.
     * See: https://salesforce.stackexchange.com/questions/208604/how-to-open-a-custom-lightning-component-tab-app-in-lightning-service-console/223112
     * Notice that the contactId uses a namespace.  As of Spring 19, all non-namespaced
     * variables are stripped from the URL.
     * Passing the component, which is needed for the Workpace API
     * as well as passing an object literal that we use here to 
     * pass in the data we need. 
     */
	openNewTab : function(component, componentDef) {

        var parentTabId = null;
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            parentTabId = response.tabId;
        }).catch(function(error) {
            console.log(error);
        });
        
        workspaceAPI.openSubtab({
            parentTabId: parentTabId,
            pageReference: {
                'type': 'standard__component',
                'attributes': {
                    'componentName': componentDef.name
                },
                'state': {
                    'c__contactId': component.get('v.contactId')
                }
            },
            focus: true
        }).then((response) => {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: componentDef.label
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: componentDef.icon,
                iconAlt: componentDef.altText
            });
        }).catch(function(error) {
            console.log(error);
        });
	}
})