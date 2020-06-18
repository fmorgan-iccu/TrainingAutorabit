import { LightningElement, api, track } from 'lwc';
import getSuggestedCityState from '@salesforce/apex/AddressDetailController.getSuggestedCityState';
import getAddressOptions from '@salesforce/apex/AddressDetailController.getAddressOptions';

export default class CrmLwcAddressDetail extends LightningElement {
    @track editable = true;
    @api editing = false;
    @api countryOptions = [];
    @api stateOptions = [];
    @api hideCountry = false;
    @api hideLine2 = false;
    @track isValid = true;
    @track isAddressChanged = false;
    @api line1 = "";
    @api line2 = "";
    @api city = "";
    @api state = "";
    @api postalCode = "";
    @api countryCode = "";
    @api unitedStates = false;
    @api disabled = false;

    connectedCallback() {
        getAddressOptions().then(result => {
            // name => code : label => value
            this.stateOptions = this.convertCodeListToComboList(result.stateOptions);
            this.countryOptions = this.convertCodeListToComboList(result.countryOptions);
        });
        this.hideCountry = this.hideCountry === 'true' ? true : this.hideCountry === 'false' ? false : !!this.hideCountry;
        this.hideLine2 = this.hideLine2 === 'true' ? true : this.hideLine2 === 'false' ? false : !!this.hideLine2;
        if (!this.countryCode || this.hideCountry) {
            this.setCountryCode('USA');
        }
    }

    // All getters for address detail
    get formattedAddress() {
        return this.line1 + ' ' + this.line2;
    }

    get isEdit() {
        return this.editable && this.editing;
    }

    // API functions for exposing the variables in the address LWC
    @api isAddressChanged() {
        return this.isAddressChanged;
    }
    @api getLine1() {
        return this.line1;
    }
    @api getLine2() {
        return this.line2;
    }
    @api getCity() {
        return this.city;
    }
    @api getState() {
        return this.state;
    }
    @api getPostalCode() {
        return this.postalCode;
    }
    @api getCountryCode() {
        return this.countryCode;
    }
    @api getIsUnitedStates() {
        return this.unitedStates;
    }
    @api getIsValid() {
        return this.isValid;
    }

    //Return Validity
    @api checkValidity() {
        let line1Comp = this.template.querySelector('.line1');
        let cityComp = this.template.querySelector('.cityInput');
        let stateComp = this.template.querySelector('.stateComboBox');
        let postalCodeComp = this.template.querySelector('.zipcodeInput');
        let countryCodeComp = this.template.querySelector('.countryComboBox');

        let isLine1Valid = line1Comp.checkValidity();
        line1Comp.showHelpMessageIfInvalid();
        let isCityValid = cityComp.checkValidity();
        cityComp.showHelpMessageIfInvalid();
        let isStateValid = stateComp.checkValidity();
        stateComp.showHelpMessageIfInvalid();
        let isPostalCodeValid = postalCodeComp.checkValidity();
        postalCodeComp.showHelpMessageIfInvalid();
        let isCountryCodeValid = false;
        if (countryCodeComp) {
            isCountryCodeValid = countryCodeComp.checkValidity();
            countryCodeComp.showHelpMessageIfInvalid();
        } else if (this.countryCode) {
            isCountryCodeValid = true;
        }

        return isLine1Valid &&
            isCityValid &&
            isStateValid &&
            isPostalCodeValid &&
            isCountryCodeValid;
    }


    // Set the Values through @API
    @api setAddress(line1, line2, city, state, postalCode, countryCode) {
        this.line1 = line1;
        this.line2 = line2 ? line2 : '';
        this.city = city;
        this.state = state;
        this.postalCode = postalCode;
        this.setCountryCode(countryCode);
    }

    convertCodeListToComboList(options) {
        var comboList = [];
        for (let i = 0; i < options.length; i++) {
            comboList.push({label: options[i].name, value: options[i].code});
        }
        return comboList;
    }

    handleCountryChange(event) {
        this.setCountryCode(event.detail.value);
        this.isAddressChanged = true;
        this.dispatchEvent(new CustomEvent('countrychange'));
    }

    handlePostalCodeChange(event) {
        this.postalCode = event.detail.value;
        this.isAddressChanged = true;
    }

    handlePostalCodeBlur() {
        if (this.postalCode != null && this.unitedStates) {
            const loadingEvent = new CustomEvent('loading', {});
            this.dispatchEvent(loadingEvent);

            // Call the getContact Apex controller method with the contactId.
            getSuggestedCityState({ postalCode: this.postalCode }).then(result => {
                // May need to not set these values to '' in the future if it is clearing out the fields.
                this.city = result.city != null ? result.city : '';
                this.state = result.stateCode != null ? result.stateCode : '';

                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            })
        }
    }

    handleCityChange(event) {
        this.city = event.detail.value;
        this.isAddressChanged = true;
    }

    handleStateChange(event) {
        this.state = event.detail.value;
        this.isAddressChanged = true;
    }

    handleLine1Change(event) {
        this.line1 = event.detail.value;
        this.isAddressChanged = true;

        // Validate that the entered value is a physical address (not a po box); only if line2 is shown.
        if (!this.hideLine2 && (this.line1 !== '' && this.line1 !== null)) {
            let line1Comp = this.template.querySelector('.line1');
            let isPoBox = /^\s*(.*((p|post)[-.\s]*(o|off|office)[-.\s]*(b|box|bin)[-.\s]*)|.*((p|post)[-.\s]*(o|off|office)[-.\s]*)|.*((p|post)[-.\s]*(b|box|bin)[-.\s]*)|(box|bin)[-.\s]*)(#|n|num|number)?\s*\d+/i;
            let message = this.line1.match(isPoBox) ? 'A physical address is required. Enter the PO Box in the second address line.' : '';
            line1Comp.setCustomValidity(message);
        }
    }

    handleLine2Change(event) {
        this.line2 = event.detail.value;
        this.isAddressChanged = true;
    }

    setCountryCode(country) {
        this.countryCode = country;
        this.unitedStates = this.countryCode === 'USA';
    }
}