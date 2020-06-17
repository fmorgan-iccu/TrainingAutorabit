({
	onChangeField: function (component, event, helper) {
		var sourceField = event.getSource();
		var sourceName = sourceField.get('v.name');
		var sourceValue = sourceField.get('v.value');
		component.set('v.' + sourceName, sourceValue);

		// Determine if all fields are valid.
		helper.checkFieldValidatity(component, event, helper);
	}
})