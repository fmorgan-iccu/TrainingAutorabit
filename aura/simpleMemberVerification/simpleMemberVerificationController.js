({
    doInit :  function(component, event, helper) {
        var fetchQuestions = component.get("c.fetchQuestions");
        $A.enqueueAction(fetchQuestions);
    },
    identifyMember: function(component, event, helper) {
        // for Display Modal,set the "identifyMember" attribute to "true"
        component.set("v.identifyMember", true);
    },
    
    // show wallet questions when 'next' is pressed from identifying questions screen
    walletQuestions: function(component, event, helper) {
        component.set("v.identifyingQuestions", false);
        component.set("v.walletQuestions", true);
    },
    
    closeModal: function(component, event, helper) {
        // for Hide/Close Modal,set the "identifyMember" attribute to "False"  
        component.set("v.identifyMember", false);
        
        // This resets the questions tab
        component.set("v.identifyingQuestions", true);
        component.set("v.walletQuestions", false);
    },
    fetchQuestions: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.errorMessage", null);
        component.set('v.infoMessage', null);
        
        console.log('fetching questions for:' + component.get("v.recordId"));
		var action = component.get("c.getMemberVerificationQuestions");
        action.setParams({
            "contactId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var state = response.getState();  

            var displayError = function(error) {
                console.log('>>>>>>>> Questions error: ' + error);
				component.set("v.errorMessage", error);
            };

            if (component.isValid() && state === "SUCCESS") {
                console.log('Questions response from server');

                var responseData = response.getReturnValue();

                if (!responseData) {
                    displayError('An unknown error occurred getting questions. Please try again later.');
                    return;
                }

                if (responseData.error) {
                    displayError(responseData.error);
                    return;
                }

                var identifyingQuestions = responseData.identifyingQuestions;
                var walletQuestions = responseData.walletQuestions;
                
                var infoMessage = null;
                
                if (walletQuestions.length < 2) {
                    infoMessage = 'This member does not have enough history with ICCU to display relevant Out of Wallet Questions.';
                }
                
                var phonePasswordQuestions = responseData.phonePasswordQuestions;

                var showResetPassphrase = phonePasswordQuestions.length == 0;
                
                component.set("v.iQuestions", identifyingQuestions);
                component.set("v.wQuestions", walletQuestions);
                component.set('v.pQuestions', phonePasswordQuestions);
                component.set('v.showResetPassphrase', showResetPassphrase);
                component.set('v.infoMessage', infoMessage);
            } else {
                displayError('There was an error getting questions. Please try again later.');
            }
        });
        
        // fire off the action 		
        $A.enqueueAction(action);        
    },
    
    handleSystemOfRecordLogin : function(component, event, helper) {
    	var fetchQuestions = component.get("c.fetchQuestions");
        $A.enqueueAction(fetchQuestions);
	},
    
    closeModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    resetPassphrase: function(component, event, helper) {
    	component.set('v.showResetPassphrase', true)
	},
    
    createPassphrase: function(component, event, helper) {
        var allValid = component.find('passphrase').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (!allValid) {
            alert('Please add a passphrase and hint.');
            return;
        }
        
        var passphrase = component.get('v.passphrase');
        var passphraseHint = component.get('v.passphraseHint');
        var contactId = component.get("v.recordId");

        component.set('v.isLoading', true);
        
        var updatePasshraseAction = component.get("c.updateMemberPhonePassword");
        updatePasshraseAction.setParams({
            "contactId": contactId,
            "password": passphrase,
            "passwordHint": passphraseHint
        });
        
        updatePasshraseAction.setCallback(this, function(response) {
            var state = response.getState();  

            var displayError = function(error) {
                console.log('>>>>>>>> update passphrase error: ' + error);
				component.set("v.errorMessage", error);
                component.set('v.isLoading', false);
            };

            if (component.isValid() && state === "SUCCESS") {
                console.log('Questions response from server');

                var responseData = response.getReturnValue();

                if (!responseData) {
                    displayError('An unknown error occurred updating passphrase. Please try again later.');
                    return;
                }

                if (responseData.error) {
                    displayError(responseData.error);
                    return;
                }
                
                // Hide the reset passphrase section
                component.set('v.showResetPassphrase', false);

                // Everything is good: time to refresh the data
                var fetchQuestions = component.get("c.fetchQuestions");
                $A.enqueueAction(fetchQuestions);
            } else {
                displayError('There was an error updating passphrase. Please try again later.');
            }
        });
        
        $A.enqueueAction(updatePasshraseAction);
    }
})