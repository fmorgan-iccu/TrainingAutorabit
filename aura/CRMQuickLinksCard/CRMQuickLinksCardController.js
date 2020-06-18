({
    // on component load 
	doInit : function(component, event, helper) {
		var action = component.get("c.getQuickLinks");
        
        // fetch the links
        action.setCallback(this, function(response) {            
            var state = response.getState();  

            if (component.isValid() && state === "SUCCESS") {
                // Update the links
                component.set("v.quickLinks", response.getReturnValue());
            }
        });
        
        // fire off the action 		
        $A.enqueueAction(action);
	}
})