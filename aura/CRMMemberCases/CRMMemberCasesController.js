({
	doInit : function(component, event, helper) {
        var refreshCasesAction = component.get('c.refreshCases');      
        $A.enqueueAction(refreshCasesAction);
	},
    
    refreshCases : function(component, event, helper) {
        var openCasesAction = component.get('c.fetchOpenCases');      
        $A.enqueueAction(openCasesAction);
        
        var closedCasesAction = component.get('c.fetchClosedCases');      
        $A.enqueueAction(closedCasesAction);
        
        var refreshOpportunities = component.get('c.refreshOpportunities');
        $A.enqueueAction(refreshOpportunities);
    },

    fetchOpenCases : function(component, event, helper) {
        var action = component.get("c.getOpenMemberCases");
        var contactId = component.get("v.recordId");
        
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();

                if (!responseData) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                var convertSentimentToEmoji = function(sentiment) {
                    switch (sentiment) {
                        case '1':
                            return '1VeryUnsatisfied';
                        case '2':
                            return '2Unsatisfied';
                        case '3':
                            return '3Neutral';
                        case '4':
                            return '4Satisfied';
                        case '5':
                            return '5VerySatisfied';
                        default:
                            return 'fallback';
                    }
                };
                
                responseData.forEach(function (caze) {
                    var date = new Date(caze.CreatedDate);
                    var localDate = date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
                    
                    caze.formattedCreatedDate = localDate;
                    caze.emoji = convertSentimentToEmoji(caze.MemberSentiment__c);
                });

                component.set('v.openCases', responseData);
            }
        });

        $A.enqueueAction(action);
    },

    fetchClosedCases : function(component, event, helper) {
        var action = component.get("c.getClosedMemberCases");
        var contactId = component.get("v.recordId");
        
        var daysAgo = helper.getDaysAgo(component);
        
        action.setParams({
            "contactId": contactId,
            "numberOfDaysAgo": daysAgo
        });

        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();

                if (!responseData) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }
                
                var convertSentimentToEmoji = function(sentiment) {
                    switch (sentiment) {
                        case '1':
                            return '1VeryUnsatisfied';
                        case '2':
                            return '2Unsatisfied';
                        case '3':
                            return '3Neutral';
                        case '4':
                            return '4Satisfied';
                        case '5':
                            return '5VerySatisfied';
                        default:
                            return 'fallback';
                    }
                };
                
                responseData.forEach(function (caze) {
                    var date = new Date(caze.CreatedDate);
                    var localDate = date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
                    
                    caze.formattedCreatedDate = localDate;
                    caze.emoji = convertSentimentToEmoji(caze.MemberSentiment__c);
                });

                component.set('v.closedCases', responseData);
            }
        });

        $A.enqueueAction(action);
    },

    createCase : function(component, event, helper) {
        var contactId = component.get('v.recordId');

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "defaultFieldValues" : {
                "ContactId" : contactId,
                "Origin" : "Phone"
            }
        });
        createRecordEvent.fire();
    },
    
    refreshOpportunities : function(component, event, helper) {
        var canViewOpportunities = component.get('v.canViewOpportunities');
        
        if (!canViewOpportunities) {
            return;
        }
        
        var contactId = component.get("v.recordId");
        
        var action = component.get('c.getContactOpportunities');
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {
            var showError = function(error) {
                console.log(error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();

                if (!responseData) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }
                
                var error = responseData.error;
                
                if (error) {
                    showError(error);
                    return;
                }
                
                var opportunities = responseData.opportunities;

                component.set('v.openOpportunities', opportunities);
            }
        });

        $A.enqueueAction(action);
    }

})