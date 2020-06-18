({
    // open and close
    toggle : function(component, event, helper) {
        var showMessage = component.get('v.showMessage') !== true;
        component.set('v.showMessage', showMessage);
    }
})