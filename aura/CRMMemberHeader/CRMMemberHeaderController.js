({
    // on component load
    doInit: function (component, event, helper) {
        var action = component.get('c.getHeaderInfo');
        $A.enqueueAction(action);

        // Determine if the current date is within the period of the US tax season.  If it is, the
        // address should be disabled.
        var today = new Date();
        var day = today.getDate();
        var month = today.getMonth();
        var addressDisabled = (month >= 0 && month <= 2) || (month === 3 && day <=16) || (month === 11 && day === 31);
        component.set('v.mailingAddressDisabled', addressDisabled);
    },

    // Get the contact and permissions data from Salesforce.
    getHeaderInfo: function (component, event, helper) {
        var action = component.get("c.getHeaderInformation");
        action.setParams({
            "contactId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                // Verify the response is well formed.
                var values = response.getReturnValue();
                if (values.hasOwnProperty('error')) {
                    component.set('v.errorMessage', error);
                    return;
                } else if (!values.hasOwnProperty('contact')) {
                    component.set('v.errorMessage', 'The contact was not properly returned.');
                    return;
                }

                // Update all of the attributes based on the contact data.
                component.set("v.headerContact", values.contact);
                helper.copyAttributesFromContact(component, event, helper);

                // Store whether the user is allowed to use forms.
                component.set('v.allowForms', values.allowForms);

                // Now that we have loaded the initial data, go out and refresh it from the system of record
                var refreshAction = component.get("c.refreshFromSystemOfRecord");
                $A.enqueueAction(refreshAction);
            } else {
                component.set('v.errorMessage', 'Failed to retrieve contact information.');
                return;
            }
        });
        action.setBackground();
        $A.enqueueAction(action);
    },

    // get data from system of record
    refreshFromSystemOfRecord: function (component, event, helper) {
        component.set('v.errorMessage', '');

        // Only do this if the headerContact is loaded.
        var headerContact = component.get('v.headerContact');
        if (headerContact == null) {
            return;
        }

        // create action to call our APEX controller method refreshContent
        var refreshContactAction = component.get("c.refreshContent");

        // pass our loaded sf contact id to the refresh method
        refreshContactAction.setParams({
            'contactId': component.get('v.recordId'),
            'personNumber': headerContact.PersonNumber__c
        });

        // call method async
        refreshContactAction.setCallback(this, function (response) {
            var state = response.getState();

            var displayError = function (error) {
                component.set('v.errorMessage', error);
            };

            if (component.isValid() && state === 'SUCCESS') {
                var responseData = response.getReturnValue();

                if (responseData.error == 'Please log in to DNA.') {
                    var action = component.get('c.notifyRequireSystemOfRecordLogin');
                    $A.enqueueAction(action);
                    return;
                } else if (responseData.error) {
                    displayError(responseData.error);
                    return;
                }

                var contact = responseData.contact;
                if (!contact) {
                    displayError('Contact information not found.');
                    return;
                }

                // Update all of the attributes based on the contact data.
                component.set('v.headerContact', contact);
                helper.copyAttributesFromContact(component, event, helper);

                var action = component.get('c.notifyContactRefresh');
                $A.enqueueAction(action);

                // Enable the edit button.
                component.set('v.isAuthenticated', true);
            } else {
                displayError('Failed to refresh from system of record.');
            }
        });

        refreshContactAction.setBackground();
        // fire off the action
        $A.enqueueAction(refreshContactAction);
    },

    // event for contact refresh
    notifyContactRefresh: function (component, event, helper) {
        var myEvent = $A.get("e.c:ContactRefresh");
        myEvent.setParams({ "contact": component.get("v.headerContact") });
        myEvent.fire();
    },

    // event for login required
    notifyRequireSystemOfRecordLogin: function (component, event, helper) {
        var myEvent = $A.get("e.c:RequireSystemOfRecordLogin");
        myEvent.setParam('system', 'cCRMDnaLogin');
        myEvent.fire();
    },

    // handle system of reocrd login event
    handleSystemOfRecordLogin: function (component, event, helper) {
        var action = component.get('c.refreshFromSystemOfRecord');
        $A.enqueueAction(action);
    },

    showFormsTab: function(component, event, helper) {
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
                    'componentName': 'c__CRMContactForms'
                },
                'state': {
                    'c__contactId': component.get('v.recordId')
                }
            },
            focus: true
        }).then((response) => {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: 'Forms'
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: 'action:record',
                iconAlt: 'Forms'
            });
        }).catch(function(error) {
            console.log(error);
        });
    },

    showMCCReferral: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var modalBody;
        $A.createComponent(
            "c:CRMMemberReferral",
            {
                "aura:id": "CRMMemberReferral",
                "recordId": recordId
            },
            function (content, status) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        body: content,
                        cssClass: ""
                    });
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + status);
                    // Show error message
                }
            }
        );
    },

    showMemberVerification: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var modalBody;
        $A.createComponent(
            "c:simpleMemberVerification",
            {
                "aura:id": "MemberVerificationModal",
                "recordId": recordId
            },
            function (content, status) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        body: content,
                        cssClass: ""
                    });
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + status);
                    // Show error message
                }
            }
        );
    },

    showNewApplicaton: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var modalBody;
        $A.createComponent(
            "c:CRMNewAvokaApp",
            {
                "aura:id": "CRMNewAvokaApp",
                "recordId": recordId
            },
            function (content, status) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        body: content,
                        cssClass: "slds-modal_large"
                    });
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + status);
                    // Show error message
                }
            }
        );
    },

    saveChanges: function (component, event, helper) {
        // Clear any previous errors.
        component.set('v.errorMessageEdit', '');

        // If the form isn't valid, show a message.
        var isValidForm = component.get('v.isValidAddress') && component.get('v.isValidEmail') && component.get('v.isValidPhone');
        if (!isValidForm) {
            component.set('v.errorMessageEdit', 'One or more fields are required or have the incorrect format.  Correct them before saving.');
            return;
        }

        // Retrieve the mailing address as entered on the form in the CRMAddressDetail child component.
        var email = component.get('v.email');
        var mailingStreet1 = component.get('v.mailingStreet1');
        var mailingStreet2 = component.get('v.mailingStreet2');
        var mailingCity = component.get('v.mailingCity');
        var mailingState = component.get('v.mailingState');
        var mailingPostalCode = component.get('v.mailingPostalCode');
        var mailingCountry = component.get('v.mailingCountry');
        var mobilePhone = component.get('v.mobilePhone');
        var phone = component.get('v.phone');
        var mailingStreet = mailingStreet1 + (mailingStreet2 !== '' ? '\n' + mailingStreet2 : '');

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
        var action = component.get('c.updateContact');
        action.setParams({
            'contactId': component.get('v.recordId'),
            'email': email,
            'mailingStreet1': mailingStreet1,
            'mailingStreet2': mailingStreet2,
            'mailingCity': mailingCity,
            'mailingCountry': mailingCountry,
            'mailingPostalCode': mailingPostalCode,
            'mailingState': mailingState,
            'mobilePhone': mobilePhone,
            'phone': phone,
            'verifiedIdentityPhone': verifiedIdentity
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            var contact = component.get('v.headerContact');
            if (component.isValid() && state === 'SUCCESS') {
                var responseObj = response.getReturnValue();

                // Disable the saving indicator so that the results can be shown.
                component.set('v.isSaving', false);

                // If the response contains a contact, it will be the information that was updated on file.
                if (responseObj.hasOwnProperty('contact')) {
                    var contact = responseObj.contact;
                    component.set('v.headerContact', contact);

                    // Disable the editing mode since the save is complete.
                    component.set('v.editing', false);

                    // Show the joint address change informational message
                    if (component.get('v.isAddressChanged')) {
                        component.find('notifLib').showNotice({
                            "variant": "info",
                            "header": "Reminder about Joint Owners and Youth Accounts",
                            "message": "Ask the member if joint owners and youth accounts need to be updated.  You are responsible for changing each record separately."
                        });
                    }
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
                } else if (!responseObj.hasOwnProperty('contact')) {
                    component.set('v.errorMessageEdit', 'An expected response was received while attempting to update the person.');
                }
            } else {
                component.set('v.errorMessageEdit', 'An unknown error has occurred while attempting to update the person.');
            }
        });
        $A.enqueueAction(action);
    },

    editInfo: function (component, event, helper) {
        component.set('v.editing', true);

        // Reset the phone verification flag
        var action = component.get('c.resetVerifiedIdentityPhone');
        action.setParams({
            'contactId': component.get('v.recordId')
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
    }

})