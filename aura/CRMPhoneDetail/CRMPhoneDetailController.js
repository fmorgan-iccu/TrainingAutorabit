({
	onChangeField: function (component, event, helper) {
		var phoneField = component.find('phone');
		var phone = phoneField.get('v.value');
		var phoneValid = true;
		component.set('v.phone', phone);

		var mobilePhoneField = component.find('mobilePhone');
		var mobilePhone = mobilePhoneField.get('v.value');
		var mobilePhoneValid = true;
		component.set('v.mobilePhone', mobilePhone);

		// Validate that at least one of the phone numbers is provided.  These regular expressions
		// match the format that the DNA system uses for phone numbers, (999) 999-9999 Ext:999.
		var phoneInvalidFormat = phone !== '' && phone !== undefined && !phone.match(/^\([0-9]{3}\) [0-9]{3}-[0-9]{4}( Ext: [0-9]+)?$/);
		var mobilePhoneInvalidFormat = mobilePhone !== '' && mobilePhone !== undefined && !mobilePhone.match(/^\([0-9]{3}\) [0-9]{3}-[0-9]{4}( Ext: [0-9]+)?$/);
		if (phoneInvalidFormat) {
			phoneField.setCustomValidity('You must use the format (999) 999-9999 Ext: 999');
			phoneValid = false;
		}
		if (mobilePhoneInvalidFormat) {
			mobilePhoneField.setCustomValidity('You must use the format (999) 999-9999 Ext: 999');
			mobilePhoneValid = false;
		}
		if ((phone === '' || phone === undefined)
			&& (mobilePhone === '' || mobilePhone === undefined)) {
			phoneField.setCustomValidity('The member must have a phone number on file.');
			phoneValid = false;

			mobilePhoneField.setCustomValidity('The member must have a phone number on file.');
			mobilePhoneValid = false;
		}
		if (phoneValid) {
			phoneField.setCustomValidity('');
		}
		if (mobilePhoneValid) {
			mobilePhoneField.setCustomValidity('');
		}
		phoneField.reportValidity();
		mobilePhoneField.reportValidity();

		// If the phone number is not present but the mobile number is and is valid, set the phone number to match the mobile number.
        /* if ((phone === '' || phone === null) && mobilePhoneValid) {
            component.set('v.phone', mobilePhone);
        } */

		// Determine if all fields are valid.
		helper.checkFieldValidatity(component, event, helper);
	}
})