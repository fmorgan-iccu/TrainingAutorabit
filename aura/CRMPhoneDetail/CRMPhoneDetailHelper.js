({
	checkFieldValidatity : function(component, event, helper) {
        var allValid = true;
        allValid = allValid && component.find('phone').get('v.validity').valid;
        if (component.find('mobilePhone')) {
            allValid = allValid && component.find('mobilePhone').get('v.validity').valid;
        }
        component.set('v.isValid', allValid);
    }
})