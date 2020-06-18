({
    // show notes
    showMore: function(component, event, helper) {
        component.set("v.ViewNotes", true);
    },
    // hide notes
    showLess: function(component, event, helper) {
        component.set("v.ViewNotes", false);
    }
})