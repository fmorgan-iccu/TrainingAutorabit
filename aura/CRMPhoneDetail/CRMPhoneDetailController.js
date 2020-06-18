({
    onChangeField: function (component, event, helper) {
        var phoneField = component.find('phone');
        var phone = formatDigitsOnly(phoneField.get('v.value'));
        var phoneValid = true;


        let hideMobile = component.get('v.hideMobile');
        if (!hideMobile) {
            var mobilePhoneField = component.find('mobilePhone');
            var mobilePhone = formatDigitsOnly(mobilePhoneField.get('v.value'));
            var mobilePhoneValid = true;
        }

        //Validity check for resetting the errors
        var phoneNotBlank = phone !== '' && phone !== undefined && phone !== null;
        var mobilePhoneNotBlank = mobilePhone !== '' && mobilePhone !== undefined && mobilePhone !== null;

        if (phoneNotBlank) {
            if (phone.length != 10) {
                phoneField.setCustomValidity('Phone numbers must be 10-digits.');
                phoneValid = false;
            }
        }

        if (mobilePhoneNotBlank) {
            if (mobilePhone.length != 10) {
                mobilePhoneField.setCustomValidity('Phone numbers must be 10-digits.');
                mobilePhoneValid = false;
            }
        }

        if ((phone === '' || phone === undefined || phone === null) &&
            (mobilePhone === '' || mobilePhone === undefined || mobilePhone === null))
        {
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
        if(mobilePhoneField) {
            mobilePhoneField.reportValidity();
        }

        // Determine if all fields are valid.
        helper.checkFieldValidatity(component, event, helper);

        if (phoneNotBlank) {
            if (phone.length == 10) {
                phone = formatPhoneNumber(phone);
            }
        }

        if (mobilePhoneNotBlank){
            if (mobilePhone.length == 10) {
                mobilePhone = formatPhoneNumber(mobilePhone);
            }
        }

        component.set('v.phone', phone);
        component.set('v.mobilePhone', mobilePhone);

        //Function for formatting phone number to (999) 999-9999 format for salesforce and DNA on blur.
        function formatPhoneNumber(phoneNumberString) {
            //Make a copy of phone number and clean it, \D = non-digits and /g = all occurances.
            var cleaned = ('' + phoneNumberString).replace(/\D/g, '')
            var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/)

            //Now format the phone number string.
            if (match) {
                return '(' + match[1] + ') ' + match[2] + '-' + match[3]
            }
            return null
        }

        // Removes all special formatting from a phone number.
        function formatDigitsOnly(phoneNumberString) {
        if (phoneNumberString == null) {
            return null;
        }

        var phoneDigits = phoneNumberString.replace(/[^0-9]/g,'');

        return phoneDigits;
        }
    }
})