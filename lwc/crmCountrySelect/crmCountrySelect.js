import { LightningElement, api, track, wire } from 'lwc';

import getCountries from '@salesforce/apex/CountryUtils.getCountries';

export default class CrmCountrySelect extends LightningElement {
    @wire(getCountries) countryOptions;
    @api label = 'Country';
    @api multiselect = false;
    @api required = false;
    @track pills = [];
    selectedCountryCodes = [];
    selectedCountryPills = [];
    @track showRequired = false;
    @api isDisabled = false;

    @api checkValidity() {
        return !this.required || this.selectedCountryCodes.length > 0;
    }

    @api getSelectedCountryCodes() {
        return [...this.selectedCountryCodes];
    }

    handleCountryBlur() {
        this.showHelpMessageIfInvalid();
    }

    handleCountrySelect(event) {
        // Verify that the entered value is a country name.
        let enteredCountryName = event.target.value;
        let countryCode = null;
        for (let countryOption of this.countryOptions.data) {
            if (enteredCountryName === countryOption.name) {
                countryCode = countryOption.code;
            }
        }

        if (countryCode !== null && !this.selectedCountryCodes.includes(countryCode)) {
            this.selectedCountryCodes.push(countryCode);
            
            if (this.multiselect) {
                this.selectedCountryPills.push({
                    label: enteredCountryName,
                    variant: 'circle'
                });
                this.updatePills();
                event.target.value = '';
            }
        }

        this.showHelpMessageIfInvalid();
    }

    handleItemRemove(event) {
        const index = event.detail.index;
        this.selectedCountryCodes.splice(index, 1);

        if (this.multiselect) {
            this.selectedCountryPills.splice(index, 1);
            this.updatePills();
        }

        this.showHelpMessageIfInvalid();
    }

    get hasError() {
        return this.showRequired ? 'slds-has-error' : '';
    }

    get multiSelectShowStyle() {
        let style = 'display:' + (this.multiselect ? 'inherit' : 'hidden');
        return style;
    }

    renderedCallback() {
        // Because id selectors are not supported by LWC querySelector, find the Ids of the
        // country datalists using a class and then set the list attribute on the associated
        // input.
        let countryListId = this.template.querySelector('.countryList').id;
        this.template.querySelector('.countryInput').setAttribute('list', countryListId);
    }

    @api setRequired(required) {
        this.required = required;
    }

    @api showHelpMessageIfInvalid() {
        // Determine if this field is valid;
        let isValid = this.checkValidity();
        this.showRequired = !isValid;
    }

    // This function is used to copy the values from the selected array into a new array that is
    // assigned to the pills.  This will cause the pill container to re-render.
    updatePills() {
        this.pills = [...this.selectedCountryPills];
    }
}