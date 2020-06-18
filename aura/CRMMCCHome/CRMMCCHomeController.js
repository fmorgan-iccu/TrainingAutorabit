({
	// event for login required
    notifyDNACoreLoginRequired : function(component, event, helper) {
        var myEvent = $A.get("e.c:RequireSystemOfRecordLogin");
        myEvent.setParam('system', 'cCRMDnaLogin');
        myEvent.fire();
    }
})