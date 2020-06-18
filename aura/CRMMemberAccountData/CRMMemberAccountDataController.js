({
    doInit : function(component, event, helper) {

    },

    showAccountDetails : function(component, event, helper) {

        let account = component.get('v.account');
        let tabLabel = account.nickName ? account.nickName : account.name;
        if (account.accountNumber) {
            tabLabel += ' - ' + account.accountNumber;
        }

        helper.openSubTab(component,
            {
                altText: tabLabel,
                icon: 'utility:currency', // NOTE:  For some reason the custom icons don't work, see account.icon
                label: tabLabel,
                name: 'c__CRMAccountDetails',
                state: {
                    'c__recordId': component.get('v.contactId'),
                    'c__accountNumber': account.accountNumber
                }
            }
        );
    },

    formatAmounts: function(component, event, helper) {
        helper.formatAmounts(component, event, helper);
    }
})