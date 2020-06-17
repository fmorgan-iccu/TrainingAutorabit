({
	doInit :  function(component, event, helper) {
        var fetchQuestions = component.get("c.fetchQuestions");
        $A.enqueueAction(fetchQuestions);
    },
    
    fetchQuestions: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        if (!recordId) {
            return;
        }
        
        var simpleRecord = component.get('v.simpleRecord');
        
        var cache = component.get('v.passphraseCache');
        if (cache) {
            var questions = cache[recordId];
            
            if (questions) {
                component.set('v.pQuestions', questions);
                return;
            }
        }
        
        component.set('v.isLoading', true);
        component.set("v.errorMessage", null);
        component.set('v.infoMessage', null);

        console.log('fetching questions for:' + component.get("v.recordId"));
        
		var action = component.get("c.getMemberVerificationQuestions");
        action.setParams({
            "contactId": recordId
        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var displayError = function(error) {
				component.set("v.errorMessage", error);
            };

            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();

                if (!responseData) {
                    displayError('An unknown error occurred getting the passphrase. Please try again later.');
                    return;
                }

                if (responseData.error) {
                    displayError(responseData.error);
                    return;
                }

                var phonePasswordQuestions = responseData.phonePasswordQuestions;

                component.set('v.pQuestions', phonePasswordQuestions);
                
                var highlightUtilityBar = component.get("c.highlightUtilityBar");
                $A.enqueueAction(highlightUtilityBar);
                
                // Cache the results if there is something there.
                if (phonePasswordQuestions.length > 0) {
                    var cache = component.get('v.passphraseCache');
                    if (!cache) {
                        cache = {};
                    }
                    
                    var recordId = component.get('v.recordId');
                    
                    cache[recordId] = phonePasswordQuestions;
                    
                    component.set('v.passphraseCache', cache);
                }
            } else {
                displayError('There was an error getting questions. Please try again later.');
            }
        });
	
        $A.enqueueAction(action);        
    },
    
    handleSystemOfRecordLogin: function(component, event, helper) {
        var fetchQuestions = component.get("c.fetchQuestions");
        $A.enqueueAction(fetchQuestions);
    },
    
    recordUpdated: function(component, event, helper) {
        var fetchQuestions = component.get("c.fetchQuestions");
        $A.enqueueAction(fetchQuestions);
    },
    
    locationChanged: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        if (recordId && recordId.startsWith('003')) { // 003 is a contact record.
            var fetchQuestions = component.get("c.fetchQuestions");
            $A.enqueueAction(fetchQuestions);
        }
    },
    
    highlightUtilityBar: function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        
        if (utilityAPI) {
            //utilityAPI.setUtilityHighlighted({highlighted:true});
        }
    }
})