({
	checkFieldValidatity : function(component, event, helper) {
        var allValid = true;
        allValid = allValid && component.find('line1').get('v.validity').valid;
        allValid = allValid && component.find('line2').get('v.validity').valid;
        allValid = allValid && component.find('city').get('v.validity').valid;
        allValid = allValid && component.find('postalCode').get('v.validity').valid;
        allValid = allValid && component.find('country').get('v.validity').valid;

        // Because the state select is only shown for the USA...
        var stateSelect = component.find('stateSelect');
        var stateSelectValidity = stateSelect ? stateSelect.get('v.validity') : undefined;
        if (component.get('v.unitedStates') == true && stateSelectValidity) {
            allValid = allValid && stateSelectValidity.valid;
        }
        
        component.set('v.isValid', allValid);
    } 
})