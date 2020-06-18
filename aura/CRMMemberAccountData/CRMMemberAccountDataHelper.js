({
    formatAmounts: function(component, event, helper) {
        if (!numeral) {
            return;
        }

        var account = component.get('v.account');

        if (account) {
            var currencyFormat = "$0,000.00";

            var availableBalance = numeral(account.availableBalance).format(currencyFormat);
            component.set('v.availableBalance', availableBalance);

            var currentBalance = numeral(account.currentBalance).format(currencyFormat);
            component.set('v.currentBalance', currentBalance);
        }
    },

    openSubTab : function(component, componentDef) {
        var parentTabId = null;
        var subTabId = null;
        var workspaceAPI = component.find('workspace');
        workspaceAPI.getFocusedTabInfo().then((response) => {
            parentTabId = response.tabId;

            return workspaceAPI.getAllTabInfo();
        }).then((response) => {
            // Determine if a sub-tab is already open within the parent tab.
            for (let tabObj of response) {
                if (tabObj.tabId === parentTabId) {
                    for (let subTabObj of tabObj.subtabs) {
                        if (subTabObj.title === componentDef.label) {
                            subTabId = subTabObj.tabId;
                            break;
                        }
                    }
                    break;
                }
            }

            // The requested page is already open, so give it focus and refresh it.
            if (subTabId !== null) {
                workspaceAPI.focusTab({tabId : subTabId});
                workspaceAPI.refreshTab({ tabId: subTabId, includeAllSubtabs: true });
                throw 'tab opened';
            }

            // Open a new sub-tab
            return workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                pageReference: {
                    'type': 'standard__component',
                    'attributes': {
                        'componentName': componentDef.name
                    },
                    'state': componentDef.state
                },
                focus: true
            });
        }).then((response) => {
            subTabId = response;
            workspaceAPI.setTabLabel({
                tabId: subTabId,
                label: componentDef.label
            });
            workspaceAPI.setTabIcon({
                tabId: subTabId,
                icon: componentDef.icon,
                iconAlt: componentDef.altText
            });
        }).catch(function(error) {
            console.log(error);
        });
    }
})