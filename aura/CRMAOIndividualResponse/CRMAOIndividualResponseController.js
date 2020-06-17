({
    // open and close
    toggle : function(component, event, helper) {
        if ((component.get('v.showMessage')) === true) {
            component.set('v.showMessage', false);
        } else {
            component.set('v.showMessage', true);
        }
    }
})