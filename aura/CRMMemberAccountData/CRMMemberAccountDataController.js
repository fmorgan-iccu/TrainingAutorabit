({
    doInit : function(component, event, helper) {

    },
    
    showAccountDetails : function(component, event, helper) {
        var contactId = component.get('v.contactId');
		var account = component.get("v.account");
        var modalBody;
        $A.createComponent(
            "c:CRMAccountDetails",
            {
                "aura:id": "AccountDetailsModal",
                "account": account,
                "recordId": contactId
            },
            function(content, status){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        body: content,
                        cssClass: "slds-modal_large"
                    });
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error");
                    // Show error message
                }
            }
        );
    },
    
    formatAmounts: function(component, event, helper) {
        helper.formatAmounts(component, event, helper);
    }
})