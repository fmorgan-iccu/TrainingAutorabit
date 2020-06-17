({
    doInit : function(component, event, helper) {
        var action = component.get('c.fetchMemberAccounts');      
        $A.enqueueAction(action);
	},
	fetchMemberAccounts : function(component, event, helper) {
		// create a server side action.

        component.set('v.errorMessage', '');
       	component.set('v.isLoading', true);
        
        var auraMethod = "c.getMemberAccountsGrouped";
        var shouldLoadOrgAccounts = component.get('v.LoadOrgAccounts');
        var recordId = component.get("v.recordId");
        
        var params = {};
        
        // Check to see if we should load org accounts, instead of member accounts.
        if (shouldLoadOrgAccounts) {
            auraMethod = "c.getOrganizationAccountsGrouped";
            params.accountId = recordId;
        } else {
            params.contactId = recordId;
        }

        var action = component.get(auraMethod);
        action.setParams(params);
        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
                component.set('v.errorMessage', error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var accountGroups = responseData.accounts;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!accountGroups) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }
                
                // Get dates to compare with next loan due date
                var today = new Date();
                today = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
                
                // Iterate through and add the appropriate icon to the group.
                accountGroups.forEach(function (accountGroup) {
                    if (accountGroup.accounts.length > 0) { // Sanity Check
                        var account = accountGroup.accounts[0];
                        var majorType = account.majorType;
                        
                        var icon = 'file-alt'; // default icon
                        var color = '#555759'; // default color
                        
                        if (majorType === 'CK') {
                            icon = 'credit-card';
                            color = 'green';
                        } else if (majorType === 'SAV') {
                            icon = 'money-bill-alt';
                            color = 'green';
                        } else if (majorType === 'EXT') {
                            icon = 'credit-card';
                            color = '#555759';
                        } else if (majorType === 'TD') {
                            icon = 'chart-line';
                            color = 'green';
                        } else if (majorType === 'CNS') {
                            icon = 'car';
                            color = 'purple';
                        } else if (majorType === 'MTG') {
                            icon = 'home';
                            color = 'orange';
                        }

                        accountGroup.icon = icon;
                        accountGroup.iconColor = color;
                    }
                    
                    //overdrawn or overdue?
                    accountGroup.accounts.forEach(function (account) {
                        //Visas are not overdrawn, they are overpayed
                        if (majorType !== 'EXT') {
                           	var isOverdrawn = account.availableBalance < 0;
                            account.isOverdrawn = isOverdrawn;
                        } 
                        var isOverdue = account.nextPaymentDate < today;
                        account.isOverdue = isOverdue;
                    });
                });

                component.set('v.accounts', accountGroups);
            } else {
                showError('An unknown error occured.');
            }
            
        });

        action.setBackground();
        $A.enqueueAction(action);
    },
    fetchAccountTransactions :  function(component, event, helper) {
        var action = component.get("c.getAccountTransactions");
        var account = component.get("v.account");

        action.setParams({
            "accountMap": account
        });
        
        var showError = function(error) {
            console.log(error);
            component.set('v.errorMessage', error);
        }

        showError('');

        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var transactions = responseData.transactions;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!transactions) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                component.set('v.transactions', transactions);
            }
        });

        $A.enqueueAction(action);
    },
    handleSystemOfRecordLogin : function(component, event, helper) {
        var action = component.get('c.fetchMemberAccounts');      
        $A.enqueueAction(action);
	}
})