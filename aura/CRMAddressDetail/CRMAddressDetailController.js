({
    // NOTE:  For now, these are hard-coded here.  In the future, the picklist fields will likely
    // be enabled and these values should be queried via the SObjectDescribe.
    doInit: function (component, event, helper) {
        // { label: 'Alabama', value: 'AL' }
        var stateOptions = [];
        component.set('v.stateOptions', stateOptions);

        var countryOptions = [];
        component.set('v.countryOptions', countryOptions);

        var getCountriesAction = component.get('c.getAddressOptions');
        getCountriesAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var options = response.getReturnValue();
                var stateOptions = options.stateOptions;
                component.set('v.stateOptions', stateOptions);
                var countryOptions = options.countryOptions;
                component.set('v.countryOptions', countryOptions);
            } else {
                console.log('Unable to retrieve countries!');
            }
        });
        $A.enqueueAction(getCountriesAction);
    },

    onChangeCountry: function (component, event, helper) {
        var country = component.find('country').get('v.value');
        component.set('v.country', country);

        var isUnitedStates = country === 'USA';
        component.set('v.unitedStates', isUnitedStates);

        component.set('v.isAddressChanged', true);

        // Determine if all fields are valid.
        helper.checkFieldValidatity(component, event, helper);
    },

    onChangeField: function (component, event, helper) {
        var sourceField = event.getSource();
        var sourceName = sourceField.get('v.name');
        var sourceValue = sourceField.get('v.value');

        component.set('v.' + sourceName, sourceValue);

        component.set('v.isAddressChanged', true);

        // Determine if all fields are valid.
        helper.checkFieldValidatity(component, event, helper);
    },

    onChangePostalCode: function(component, event, helper) {
        var postalCode = component.find('postalCode').get('v.value');
        component.set('v.postalCode', postalCode);
        if (!postalCode) {
            return;
        }

        var isUnitedStates = component.get('v.unitedStates');
        if (isUnitedStates) {
            // Call the getContact Apex controller method with the contactId.
            var action = component.get("c.getSuggestedCityState");
            action.setParams({
                "postalCode": postalCode
            });
            action.setCallback(this, function (response) {
                var state = response.getState();

                if (component.isValid() && state === "SUCCESS") {
                    var suggestion = response.getReturnValue();
                    var city = suggestion['city'] != null ? suggestion['city'] : '';
                    var state = suggestion['stateCode'] != null ? suggestion['stateCode'] : 'ID';
                    component.set('v.city', city);
                    
                    var stateSelectComp = component.find('stateSelect');
                    stateSelectComp.set('v.value', state);
                    component.set('v.state', state);
                }
            });
            action.setBackground();
            $A.enqueueAction(action);
        }
    },

    onChangeState: function (component, event, helper) {
        var state = component.find('stateSelect').get('v.value');
        component.set('v.state', state);

        component.set('v.isAddressChanged', true);

        // Determine if all fields are valid.
        helper.checkFieldValidatity(component, event, helper);
    },

    onChangeLine1: function (component, event, helper) {
        // Capture the new value of line1
        var sourceField = event.getSource();
        var sourceName = sourceField.get('v.name');
        var sourceValue = sourceField.get('v.value');
        component.set('v.' + sourceName, sourceValue);

        // Validate that the entered value is a physical address (not a po box)
        var isPoBox = /^\s*(.*((p|post)[-.\s]*(o|off|office)[-.\s]*(b|box|bin)[-.\s]*)|.*((p|post)[-.\s]*(o|off|office)[-.\s]*)|.*((p|post)[-.\s]*(b|box|bin)[-.\s]*)|(box|bin)[-.\s]*)(#|n|num|number)?\s*\d+/i;
        if (sourceValue !== '' && sourceValue !== null) {
            if (sourceValue.match(isPoBox)) {
                sourceField.setCustomValidity('A physical address is required. Enter the PO Box in the second address line.');
            } else {
                sourceField.setCustomValidity('');
            }
            sourceField.reportValidity();
        }

        component.set('v.isAddressChanged', true);

        // Determine if all fields are valid.
        helper.checkFieldValidatity(component, event, helper);
    }

})