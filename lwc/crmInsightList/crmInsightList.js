import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import fetchInsights from '@salesforce/apex/MemberInsightsController.fetchInsights';

export default class CrmInsights extends NavigationMixin(LightningElement) {

    @api allowCustomInsights = false;
    @api recordId = null;

    @track accountInsights = [];
    @track error = null;
    @track generalInsights = [];
    @track isLoading = false;

    connectedCallback() {
        this.loadInsights();
    }

    handleCreateCustomInsight() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'MemberInsight__c',
                actionName: 'new'
            },
            state : {
                nooverride: '1',
                defaultFieldValues:'ContactID__c=' + this.recordId
            }
        });
    }

    handleRefreshInsights() {
        this.loadInsights();
    }

    @api loadInsights() {
        this.error = null;
        this.isLoading = true;

        fetchInsights({ recordId: this.recordId }).then(result => {
            if (result.error && result.error !== '') {
                this.setError(result.error);
            }
            if (result.financialAccountInsights && result.generalInsights) {
                this.accountInsights = result.financialAccountInsights;
                this.generalInsights = result.generalInsights;
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the contacts cards.');
            }
        }).finally(() => {
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('load', { detail: true }));
        });
    }

    setError(message) {
        this.error = message;
    }

    get noInsights() {
        return this.accountInsights.length < 1 && this.generalInsights.length < 1;
    }

    get showAccountInsights() {
        return this.accountInsights.length > 0;
    }

    get showGeneralInsights() {
        return this.generalInsights.length > 0;
    }

    get showError() {
        return  this.error && this.error != '';
    }
}