({
	doInit : function(component, event, helper) {
		
	},
    
    showDetails : function(component, event, helper) {

        var recordId = component.get("v.recordId");
        $A.createComponent(
            "c:CRMFSCReport",
            {
                "report": component.get('v.report')
            },
            function(content, status){
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
	}
})