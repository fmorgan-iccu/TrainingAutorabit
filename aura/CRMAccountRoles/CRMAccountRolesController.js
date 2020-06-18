({
	doInit : function(component, event, helper) {

	},
    openEntity : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
})