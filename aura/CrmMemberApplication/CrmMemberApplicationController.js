({
    doInit: function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },
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
    
    formatDates: function(component, event, helper) {
        helper.formatDates(component, event, helper);
    }
})