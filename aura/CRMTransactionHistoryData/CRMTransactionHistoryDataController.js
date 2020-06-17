({

    doInit : function(component, event, helper) {
        helper.formatDates(component, event, helper);
        helper.formatNumbers(component, event, helper);
    },

    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');

       var toggleText = component.find("toggleActiveColor");
       $A.util.toggleClass(toggleText, "activeColor")
       $A.util.toggleClass(toggleText, "borderBottom")
    },
    
    formatDates : function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },
    
    formatNumbers : function(component, event, helper) {
        helper.formatNumbers(component, event, helper);
    },

})