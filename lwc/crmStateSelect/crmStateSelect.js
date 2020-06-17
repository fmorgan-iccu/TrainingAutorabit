import { LightningElement, api, track, wire } from 'lwc';

import getStates from '@salesforce/apex/USStateUtils.getStates';

export default class CrmStateSelect extends LightningElement {
    @api label = 'State';
    @api multiselect = false;
    @api required = false;
    @track pills = [];
    @api isDisabled;
    selectedStateCodes = [];
    selectedStatePills = [];
    @track showRequired = false;
    @wire(getStates) stateOptions;

    @api checkValidity() {
        return !this.required || this.selectedStateCodes.length > 0;
    }

    @api getSelectedStateCodes() {
        return [...this.selectedStateCodes];
    }

    handleStateBlur() {
        this.showHelpMessageIfInvalid();
    }

    handleStateSelect(event) {
        // Verify that the entered value is a state name.
        let enteredStateName = event.target.value;
        let stateCode = null;
        for (let stateOption of this.stateOptions.data) {
            if (enteredStateName === stateOption.name) {
                stateCode = stateOption.code;
            }
        }

        if (stateCode !== null && !this.selectedStateCodes.includes(stateCode)) {
            this.selectedStateCodes.push(stateCode);

            if (this.multiselect) {
                this.selectedStatePills.push({
                    label: enteredStateName,
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
        this.selectedStateCodes.splice(index, 1);

        if (this.multiselect) {
            this.selectedStatePills.splice(index, 1);
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
        let stateListId = this.template.querySelector('.stateList').id;
        this.template.querySelector('.stateInput').setAttribute('list', stateListId);
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
        this.pills = [...this.selectedStatePills];
    }
}