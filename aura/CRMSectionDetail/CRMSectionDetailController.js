({
	// show or hide section
    accordian: function(component, event, helper) {
        if ( component.get("v.ViewSection") === true ) {
            component.set("v.ViewSection", false);
            component.set("v.SectionClosed", true);
        } else {
            component.set("v.SectionClosed", false);
            component.set("v.ViewSection", true);
        }
    },
})