({
	checkFieldValidatity: function (component, event, helper) {
		var allValid = true;
		allValid = allValid && component.find('email').get('v.validity').valid;

		component.set('v.isValid', allValid);
	}
})