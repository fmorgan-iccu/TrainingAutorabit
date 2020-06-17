({
	doInit : function(component, event, helper) {
        var action = component.get('c.refreshProductName');
        $A.enqueueAction(action);
    },

    refreshData : function(component, event, helper) {
        var updateProductNameAction = component.get('c.refreshProductName');
        $A.enqueueAction(updateProductNameAction);
        
        var updateFundingAction = component.get('c.refreshFundingInfo');
        $A.enqueueAction(updateFundingAction);
        
        var appLink = component.get('v.simpleRecord.AvokaFormUrl__c');
        component.set('v.appLink', appLink);
        
        var appInfoJSON = component.get('v.simpleRecord.AvokaApplicationInfoJSON__c');
        
        if (appInfoJSON) {
            try {
                var json = JSON.parse(appInfoJSON);

                var applicationIDs = json.loanApplicationIds;
                component.set('v.applicationIDs', applicationIDs);
            } catch(err) {
                console.log('Error trying to process JSON: ' + err);
            }
            
        }
    },
    
    refreshFundingInfo : function(component, event, helper) {
        var appInfoJSON = component.get('v.simpleRecord.AvokaApplicationInfoJSON__c');

        try {
            var appInfo = JSON.parse(appInfoJSON);

            var paymentType = appInfo.paymentType;
            component.set('v.paymentType', paymentType);
            
            var wasSuccessfulTransaction = appInfo.successfullyTransferedFunds;            
            component.set('v.wasSuccessfulTransaction', wasSuccessfulTransaction);

            var newAccounts = appInfo.newAccounts;
            if (newAccounts) {
                component.set('v.newAccounts', newAccounts);

                // For joint applications (and not-yet-funded primary applications) we don't want to show the funding banner
                // until there is an actual value in the `wasSuccessfulTransaction` node of the JSON.
                var shouldShowFundingBanner = (newAccounts.length > 0) && (wasSuccessfulTransaction != null);
                component.set('v.shouldShowFundingBanner', shouldShowFundingBanner);
            }

            var isFatalError = appInfo.isFatalError;
            if (!isFatalError) { // Backwards compatibility...
                isFatalError = false;
            }
            
            component.set('v.isFatalError', isFatalError);
        } catch (err) {
            console.err(err);
        }
    },
    
    refreshProductName : function(component, event, helper) {
        var productName = component.get("v.simpleRecord.ProductName__c");

        // We have a product name, no need to go get it.
        if (productName) {
            component.set('v.productName', productName);
            return;
        }

        var productMajorType = component.get('v.simpleRecord.ProductMajorCode__c');
        var productMinorType = component.get('v.simpleRecord.ProductMinorCode__c');

        if (!productMajorType || !productMinorType) {
            // No need to proceed.  This case doesn't have a product yet.
            return;
        }

        var action = component.get("c.getProduct");

        // pass current contact record to method
        action.setParams({
            "productMajorType": productMajorType,
            "productMinorType": productMinorType
        });
        
        action.setCallback(this, function(response) {
            var showError = function(error) {
                console.log(error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var product = responseData.product;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!product) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                component.set('v.productName', product.displayName);
            }
        });
        
        $A.enqueueAction(action);
    }
})