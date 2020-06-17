({
	// on component load 
	doInit : function(component, event, helper) {
		
		// grab the current contact data from SF 
        var action = component.get('c.refreshFromSF');       
        $A.enqueueAction(action);
		
        var accountItems = helper.createAccountItems();
        component.set('v.insightAccountItems', accountItems);
        
        var generalItems = helper.createGeneralItems();
        component.set('v.insightGeneralItems', generalItems);
        
        component.set('v.insightCustomItems', []);
        
        var updateCaseInsightsAction = component.get("c.updateCaseInsights");
        $A.enqueueAction(updateCaseInsightsAction);
        
        var updateAccountInsightsAction = component.get("c.updateAccountInsights");
        $A.enqueueAction(updateAccountInsightsAction);
        
        var updateWarningFlagsAction = component.get("c.updateWarningFlags")
        $A.enqueueAction(updateWarningFlagsAction);
        
        var updateCustomInsightsAction = component.get("c.updateCustomInsights");
        $A.enqueueAction(updateCustomInsightsAction);
	},
    
	// get data from SF
    refreshFromSF :  function(component, event, helper) {  
        var action = component.get("c.getContact");
        var contactId = component.get("v.recordId");
        action.setParams({
            "contactId": contactId
        });

        // call method async 
        action.setCallback(this, function(response) {            
            var state = response.getState();  
            
            if (component.isValid() && state === "SUCCESS") {    
            	
                var contact = response.getReturnValue();
                
                if (!contact) {
                    console.log('Fetched contact, but it was null!');
                    return;
                }
                
            	// set component var headerContact to the results of the call
                component.set("v.insightContact", contact);
            }

        });
        
        // fire off the action 		
        $A.enqueueAction(action);
        
    },
    
    handleContactRefresh : function(component, event, helper) {
        console.log('received contact refresh event');
        // refresh from SF again, since it was updated.
        var action = component.get('c.refreshFromSF');       
        $A.enqueueAction(action);
        
        var updateAccountInsightsAction = component.get("c.updateAccountInsights");
        $A.enqueueAction(updateAccountInsightsAction);
        
        var updateWarningFlagsAction = component.get("c.updateWarningFlags")
        $A.enqueueAction(updateWarningFlagsAction);
    },

    updateCaseInsights : function(component, event, helper) {
        var action = component.get("c.fetchCaseInsights");
        var contactId = component.get("v.recordId");
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {            
            var state = response.getState();  

            var openCasesValue = 'Error';

            if (component.isValid() && state === "SUCCESS") {                
                var data = response.getReturnValue();

                var openCases = data.open;
                if (openCases) {
                    openCasesValue = '' + openCases.length;
                }
            }

            helper.updateItem('openCases', openCasesValue, component, 'v.insightAccountItems');
        });
        
        // fire off the action 		
        $A.enqueueAction(action);
    },
    
    updateAccountInsights :  function (component, event, helper) {
        var action = component.get("c.fetchAccountInsights");
        var contactId = component.get("v.recordId");
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {            
            var state = response.getState();  
            
            var hasOverdrawnAccountId = 'hasOverdrawnAccount';
            var hasPastDueAccountId = 'hasPastDueAccount';
            
            helper.removeItem(hasOverdrawnAccountId, component, 'v.insightAccountItems');
            helper.removeItem(hasPastDueAccountId, component, 'v.insightAccountItems');

            if (component.isValid() && state === "SUCCESS") {                
                var data = response.getReturnValue();
                var error = response.error;
                var hasOverdrawnAccount = data.hasOverdrawnAccount;
                var hasPastDueAccount = data.hasPastDueAccount;

                if (error) {
                    console.log('Error updating account insights: ' + error);
                    return;
                }
                
                if (hasOverdrawnAccount) {
                    var item = {
                        title: "Overdrawn Member",
                        value: "",
                        icon: "exclamation",
                        color: "deepRed",
                        isLoading: false,
                        id: hasOverdrawnAccountId,
                        usesFA: true
                    }
                    
                    helper.insertItem(item, 0, component, 'v.insightAccountItems');
                }
                
                if (hasPastDueAccount) {
                    if (moment) { // Checking for the formatting library first
                        var pastDueDate = data.oldestPastDueDate;
                        var value = helper.subtractFromNow(pastDueDate);
                        
                        var item = {
                            title: "Loans Past Due",
                            value: value,
                            icon: "exclamation",
                            color: "deepRed",
                            isLoading: false,
                            id: hasPastDueAccountId,
                            usesFA: true
                        }
                        
                        helper.insertItem(item, 0, component, 'v.insightAccountItems');
					}
                }
            }
        });
        
        // fire off the action 		
        $A.enqueueAction(action);
	},
    
    updateWarningFlags :  function (component, event, helper) {
    	var action = component.get("c.fetchWarningFlags");
        var contactId = component.get("v.recordId");
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {            
            var state = response.getState();

            var showError = function(error) {
                console.log('Warning Flags Error: ' + error);
            };
            
            if (component.isValid() && state === "SUCCESS") {                
                var data = response.getReturnValue();
				var error = data.error;
                var flags = data.warningFlags;
                
                if (error) {
                    showError(error);
                    return;
                }
                
                flags.forEach(function (flag) {
                    var item = {
                        title: flag.flagCodeDescription,
                        value: '',
                        icon: "exclamation",
                        color: "red",
                        isLoading: false,
                        id: flag.flagCode,
                        usesFA: true
                    };

                    // This method can be called multiple times, so we need to upsert
                    helper.upsertItem(item, 0, component, 'v.insightAccountItems', helper);
                });
            }
        });
        
        // fire off the action 		
        $A.enqueueAction(action);
	},
    
    updateCustomInsights : function (component, event, helper) {
        var action = component.get("c.fetchMemberInsights");
        var contactId = component.get("v.recordId");
        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {            
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {                
                var insights = response.getReturnValue();

				// no easy way to know the what insight was deleted, so just clear out the aura attribute and repopluate it                 
                var empty = [];
                component.set("v.insightCustomItems", empty);                
                				              				                              
                insights.forEach(function (insight) {
                                        
                    var item = {
                        title: insight.name,
                        value: '',
                        icon: insight.icon,
                        color: insight.color,
                        isLoading: false,
                        id: insight.id,
                        usesFA: true,
                        extendedDetail: insight.extraDetails
                    };
                    console.log(item);

                    // This method can be called multiple times, so we need to upsert
                    helper.upsertItem(item, 0, component, 'v.insightCustomItems', helper);
                });         
                           
        	}
        });
        
        // fire off the action 		
        $A.enqueueAction(action);
    },
    
    createInsight : function (component, event, helper) {
        var contactId = component.get('v.recordId');

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "MemberInsight__c",
            "defaultFieldValues" : {
                "ContactID__c" : contactId
            },
            "panelOnDestroyCallback": function(event) {
                var updateCustomInsightsAction = component.get("c.updateCustomInsights");
                $A.enqueueAction(updateCustomInsightsAction);
            }
        });
        createRecordEvent.fire();
    }

})