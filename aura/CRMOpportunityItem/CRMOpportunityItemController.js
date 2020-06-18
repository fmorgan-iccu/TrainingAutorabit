({
	openOpportunity : function(component, event, helper) {
        var record = component.get('v.Opportunity');
		var recordId = record.Id;

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
	}
})