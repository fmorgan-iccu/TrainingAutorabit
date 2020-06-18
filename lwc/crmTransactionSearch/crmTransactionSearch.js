import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import momentJs from '@salesforce/resourceUrl/MomentJS';

export default class CrmTransactionSearch extends LightningElement {
    @track startDate = null;
    @track endDate = null;
    @track amountMin = null;
    @track amountMax = null;
    @track description = null;

    connectedCallback() {
        loadScript(this, momentJs);
    }

    handleTransactionSearch() {
        this.dispatchEvent(new CustomEvent('search', {}));
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        let date = moment(event.detail.value);
        date.set({
            hour:   11,
            minute: 59,
            second: 59
        });
        this.endDate = date;
    }

    handleAmountMinChange(event) {
        this.amountMin = event.detail.value;
    }

    handleAmountMaxChange(event) {
        this.amountMax = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.description = event.detail.value;
    }

    @api getStartDate() {
        return this.startDate;
    }

    @api getEndDate() {
        return this.endDate;
    }

    @api getAmountMin() {
        return this.amountMin;
    }

    @api getAmountMax() {
        return this.amountMax;
    }

    @api getDescription() {
        return this.description;
    }
}