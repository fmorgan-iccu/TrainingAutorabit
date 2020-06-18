({
    doInit : function(component, event, helper) {
        // grab the current account data from SF
        var action = component.get('c.refreshFromSF');
        $A.enqueueAction(action);

        var getTotalsAction = component.get('c.getHeaderTotals');
        $A.enqueueAction(getTotalsAction);
    },

    refreshFromSF :  function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            "accountId": component.get("v.recordId")
        });

        // call method async
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                // Verify the response is well formed.
                var values = response.getReturnValue();

                if (values.hasOwnProperty('error')) {
                    component.set('v.errorMessage', error);
                    return;
                } else if (!values.hasOwnProperty('account')) {
                    component.set('v.errorMessage', 'The account was not properly returned.');
                    return;
                }

                component.set('v.headerAccount', values.account);
                // Calculate the years of membership.
                var yearsOfMembership = helper.addYearsOfMembership(values.account);
                component.set('v.yearsOfMembership', yearsOfMembership);

                // Format the MembershipDate__c
                var businessEstablishmentDate = '';
                if (values.account.Business_Establishment_Date__c) {
                    businessEstablishmentDate = helper.formatDate(values.account.Business_Establishment_Date__c);
                }
                component.set('v.businessEstablishmentDate', businessEstablishmentDate);

                // Permission for showing full Tax ID
                if (values.canViewFullTaxId) {
                    component.set('v.canViewFullTaxId', values.canViewFullTaxId)
                }

                // Redact and format the TaxId
                if (values.account.OrganizationTaxID__c) {
                    helper.formatTaxId(component, values.account.OrganizationTaxID__c);
                }

                // now that we have loaded the initial data, go out and refresh it from the system of record
                var refreshAction = component.get("c.refreshFromSystemOfRecord");
                $A.enqueueAction(refreshAction);
            }
        });

        action.setBackground();
        // fire off the action
        $A.enqueueAction(action);
    },

    hideTaxId: function (component) {
        component.set("v.viewingTaxId", false);
    },

    showTaxId: function (component) {
        component.set("v.viewingTaxId", true);
    },

    getHeaderTotals :  function(component, event, helper) {
        var action = component.get("c.getAccountTotals");
        action.setParams({
            "accountId": component.get("v.recordId")
        });

        // call method async
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var accountSummary = response.getReturnValue();

                component.set("v.loanTotalOwner", accountSummary.LoanTotalOwnerFormatted);
                component.set("v.depositTotalOwner", accountSummary.DepositTotalOwnerFormatted);
            }

        });

        action.setBackground();
        // fire off the action
        $A.enqueueAction(action);
    },

    refreshFromSystemOfRecord : function(component, event, helper) {
        component.set('v.errorMessage', '');
        // create action to call our APEX controller method refreshContent
        var refreshAccountAction = component.get("c.refreshContent");

        // pass our loaded sf account id to the refresh method
        refreshAccountAction.setParams({
            "orgNumber": component.get("v.headerAccount.OrganizationNumber__c")
        });

        // call method async
        refreshAccountAction.setCallback(this, function(response) {
            var state = response.getState();

            var displayError = function (error) {
                component.set('v.errorMessage', error);
            };

            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var account = responseData.account;
                var error = responseData.error;

                if (!account) {
                    displayError(error);
                    var action = component.get('c.notifyRequireSystemOfRecordLogin');
                    $A.enqueueAction(action);
                    return;
                }

                // Redact and format the TaxId
                if (account.OrganizationTaxID__c) {
                    helper.formatTaxId(component, account.OrganizationTaxID__c);
                }

                // update our component account with the updated info from system of record
                component.set("v.headerAccount", account);
                helper.copyAttributesFromAccount(component, event, helper);

                var action = component.get('c.notifyAccountRefresh');
                $A.enqueueAction(action);

                // Enable the edit button.
                component.set('v.isAuthenticated', true);
            } else {
                displayError('Failed to refresh from system of record.')
            }
        });

        refreshAccountAction.setBackground();
        // fire off the action
        $A.enqueueAction(refreshAccountAction);
    },

    saveChanges: function (component, event, helper) {
        // Clear any previous errors.
        component.set('v.errorMessageEdit', '');

        // If the form isn't valid, show a message.
        var isValidForm = component.get('v.isValidAddress') && component.get('v.isValidPhone');
        if (!isValidForm) {
            component.set('v.errorMessageEdit', 'One or more fields are required or have the incorrect format.  Correct them before saving.');
            return;
        }

        // Retrieve the mailing address as entered on the form in the CRMAddressDetail child component.
        var mailingStreet1 = component.get('v.mailingStreet1');
        var mailingStreet2 = component.get('v.mailingStreet2');
        var mailingCity = component.get('v.mailingCity');
        var mailingState = component.get('v.mailingState');
        var mailingPostalCode = component.get('v.mailingPostalCode');
        var mailingCountry = component.get('v.mailingCountry');
        var phone = component.get('v.phone');
        //var mailingStreet = mailingStreet1 + (mailingStreet2 !== '' ? '\n' + mailingStreet2 : '');

        // Ensure that the user has verified the member per policy.
        var checkBoxCmp = component.find('verifiedIdentity');
        var verifiedIdentity = checkBoxCmp.get('v.checked');
        if (!verifiedIdentity) {
            component.set('v.errorMessageEdit', 'Verification of identification must be completed for all changes of address requested by phone. Please check the box below to indicate that you have followed procedure.');
            return;
        }

        // Indicate that the save is happening.
        component.set('v.isSaving', true);

        // Make a call to the back-end controller to update the contact.
        var action = component.get('c.updateAccount');
        action.setParams({
            'accountId': component.get('v.recordId'),
            'mailingStreet1': mailingStreet1,
            'mailingStreet2': mailingStreet2,
            'mailingCity': mailingCity,
            'mailingCountry': mailingCountry,
            'mailingPostalCode': mailingPostalCode,
            'mailingState': mailingState,
            'phone': phone,
            'verifiedIdentityPhone': verifiedIdentity
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            var account = component.get('v.headerAccount');
            if (component.isValid() && state === 'SUCCESS') {
                var responseObj = response.getReturnValue();

                // Disable the saving indicator so that the results can be shown.
                component.set('v.isSaving', false);

                // If the response contains a account, it will be the information that was updated on file.
                if (responseObj.hasOwnProperty('account')) {
                    var account = responseObj.account;
                    component.set('v.headerAccount', account);

                    // Disable the editing mode since the save is complete.
                    component.set('v.editing', false);
                }

                // Check to see if the user is not logged into DNA when updating contact info, then provide a login prompt.
                if (responseObj.requiredLogins) {
                    var action = component.get('c.notifyRequireSystemOfRecordLogin');
                    $A.enqueueAction(action);
                    component.set('v.errorMessageEdit', responseObj.error);
                }

                // If any error was provided in the response, display it.  If neither an error or contact
                // is included, indicate a generic error.
                if (responseObj.hasOwnProperty('error')) {
                    component.set('v.errorMessageEdit', responseObj.error);
                } else if (!responseObj.hasOwnProperty('account')) {
                    component.set('v.errorMessageEdit', 'An expected response was received while attempting to update the person.');
                }
            } else {
                component.set('v.errorMessageEdit', 'An unknown error has occurred while attempting to update the person.');
            }
            // Disable the saving indicator so that the results can be shown.
            component.set('v.isSaving', false);
        });
        $A.enqueueAction(action);
    },

    editInfo: function (component, event, helper) {
        component.set('v.editing', true);

        // Reset the phone verification flag
        var action = component.get('c.resetVerifiedIdentityPhone');
        action.setParams({
            'accountId': component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var responseObj = response.getReturnValue();

                // If any error was provided in the response, display it.  If the response wasn't
                // success and didn't provide an error, show a generic error message.
                if (responseObj.hasOwnProperty('error')) {
                    component.set('v.errorMessage', responseObj.error);
                    component.set('v.editing', false);
                } else if (responseObj.hasOwnProperty('success') && !responseObj.success) {
                    component.set('v.errorMessage', 'Resetting the "verify phone identity" failed for an unknown reason.');
                    component.set('v.editing', false);
                }
            } else {
                component.set('v.errorMessage', 'An unknown error has occurred while attempting to update the "verify phone identity" flag.');
                component.set('v.editing', false);
            }
        });
        $A.enqueueAction(action);
    },

    cancelEdit: function (component, event, helper) {
        component.set('v.editing', false);
        component.set('v.errorMessageEdit', null);
    },

    notifyAccountRefresh : function(component, event, helper) {
        var myEvent = $A.get("e.c:AccountRefresh");
        myEvent.setParams({"account": component.get("v.headerAccount")});
        myEvent.fire();
    },

    notifyRequireSystemOfRecordLogin : function(component, event, helper) {
        var myEvent = $A.get("e.c:RequireSystemOfRecordLogin");
        myEvent.setParam('system', 'cCRMDnaLogin');
        myEvent.fire();
    },

    handleSystemOfRecordLogin: function(component, event, helper) {
        var action = component.get('c.refreshFromSystemOfRecord');
        $A.enqueueAction(action);
    }

})