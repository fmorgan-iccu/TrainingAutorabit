({
    // show notes
    showMore: function(component, event, helper) {
        component.set("v.ViewNotes", true);
        component.set("v.NotesClosed", false);
    },
    // hide notes
    showLess: function(component, event, helper) {
        component.set("v.ViewNotes", false);
        component.set("v.NotesClosed", true);
    },
    // open the insight
    openInsight : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
})