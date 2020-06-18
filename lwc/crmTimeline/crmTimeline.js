import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getTimeline from '@salesforce/apex/TimelineController.getTimeline';

/**
 * A generic timeline that can be shown on either Account or Contact pages.
 */
export default class CrmTimeline extends NavigationMixin(LightningElement) {

    @api recordId;

    @track closedEntries = [];
    @track error = '';
    @track openEntries = [];
    @track canCreateCase = false;
    @track canCreateOpportunity = false;
    @track isLoading = false;
    @track pageCount = 1;
    @track pageNumber = 1;

    connectedCallback() {
        this.getTimeline();
    }

    createCase() {
        const defaultValues = {};
        if (this.recordId.slice(0,3) === '001') {
            defaultValues.AccountId = this.recordId;
        } else {
            defaultValues.ContactId = this.recordId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: encodeDefaultFieldValues(defaultValues)
            }
        });
    }

    createOpportunity() {
        const defaultValues = {};
        if (this.recordId.slice(0,3) === '001') {
            defaultValues.AccountId = this.recordId;
        } else {
            defaultValues.ContactId = this.recordId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: encodeDefaultFieldValues(defaultValues)
            }
        });
    }

    hideSpinner() {
        this.isLoading = false;
    }

    get isClosedItems() {
        return this.closedEntries.length > 0;
    }

    get isOpenItems() {
        return this.openEntries.length > 0;
    }

    getTimeline() {
        this.showSpinner('Loading...');

        getTimeline({
            recordId: this.recordId,
            pageNum: null,
            pageSize: null
        }).then(result => {
            if (result.error) {
                this.setError(result.error);
            }

            if (result.pageCount) {
                this.closedEntries = result.closedEntries;
                this.openEntries = result.openEntries;
                this.pageCount = result.pageCount;
                this.pageNumber = result.pageNumber;
                this.canCreateCase = result.canCreateCase;
                this.canCreateOpportunity = result.canCreateOpportunity;
            }

            this.closedEntries = this.preprocessEntries(result.closedEntries);
            this.openEntries = this.preprocessEntries(result.openEntries);
        }).catch(error => {
            if (error.body) {
                this.error = error.body.message;
            } else if (error.message) {
                this.error = error.message;
            } else {
                this.error = 'An unknown error occurred while trying to retrieve the contacts cards.';
            }
        }).finally(() => {
            this.hideSpinner();
        });
    }

    preprocessEntries(entries) {
        let newEntries = [];
        for (let entry of entries) {
            let e = Object.assign({}, entry);
            e.statusClass = e.status ? 'status-' + e.status.replace(/\s/g, '-').toLowerCase() : null;
            e.stageClass = e.stageName ? 'stage-' + e.stageName.replace(/\s/g, '-').toLowerCase() : null;
            newEntries.push(e);
        }
        return newEntries;
    }

    refreshTimeline() {
        this.getTimeline();
    }

    setError(error) {
        this.error = error;
        if (error !== '' && error != null) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Oops! Something went wrong and an error has occured.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    get showCreateCaseOnly() {
        return this.canCreateCase && !this.showNewObjectMenu();
    }

    get showCreateOpportunityOnly() {
        return this.canCreateOpportunity && !this.showNewObjectMenu();
    }

    get showMenu() {
        return this.showNewObjectMenu();
    }

    showNewObjectMenu() {
        return this.canCreateCase && this.canCreateOpportunity;
    }

    showSpinner(message) {
        this.isLoading = true;
        let spinner = this.template.querySelector('c-crm-lwc-loading-spinner');
        if (spinner) {
            spinner.message = message;
        }
    }

}