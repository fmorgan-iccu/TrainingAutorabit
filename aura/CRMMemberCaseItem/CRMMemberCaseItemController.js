({
    gotoRelatedList: function (component, event, helper) {
    	var action = component.get("c.getContact");
        
        action.setParams({
            "contactId": component.get("v.recordId")
        });  
        
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Cases",
            "parentRecordId": component.get("v.recordId")
        });
    
        relatedListEvent.fire();
    },
    
    openCase : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
})