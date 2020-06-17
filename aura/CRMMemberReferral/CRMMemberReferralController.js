({
    doInit : function(component, event, helper) {
        // grab the current contact data from SF
        var action = component.get('c.getFormData');
        $A.enqueueAction(action);
    },
    
    closeModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    getFormData: function(component, event, helper) {
        var getReferralInfoAction = component.get("c.fetchFormData");

        // call method async
        getReferralInfoAction.setCallback(this, function(response) {
            var state = response.getState();

            var displayError = function (error) {
                component.set('v.errorMessage', error);
            };
            
            if (component.isValid() && state === "SUCCESS") {
                var responseData = response.getReturnValue();
                var fscUsers = responseData.fscUsers;
                var currentUserName = responseData.currentUserName;
                var orgId = responseData.orgId;
                var orgHost = responseData.orgHost;
                var recordTypeID = responseData.leadRecordTypeId;
                var referralTypeFieldId = responseData.referralTypeFieldId;
                
                var orgURL = 'https://' + orgHost + '/servlet/servlet.WebToLead?encoding=UTF-8';
                
                // update our component contact with the updated info from system of record
                component.set("v.loanOfficers", fscUsers);
                component.set("v.currentUserName", currentUserName);
                component.set("v.orgId", orgId);
                component.set("v.orgURL", orgURL);
                component.set("v.recordTypeID", recordTypeID);
                component.set("v.referralTypeFieldId", referralTypeFieldId);
            } else {
                displayError('Failed to get user info.')
            }
        });
        
        getReferralInfoAction.setBackground();
        // fire off the action
        $A.enqueueAction(getReferralInfoAction);
    }
})