import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchContactOwner from '@salesforce/apex/ContactController.fetchContactOwner';

export default class CrmPrivateClientRecordBanner extends LightningElement {

    @track owner = {};
    @track error = '';
    @api recordId;

    connectedCallback() {
        fetchContactOwner({ contactId: this.recordId }).then(result => {
            if (result.error) {
                this.setError(result.error);
            } else if (result) {
                this.owner = result;
            } else {
                this.setError('Unable to retrieve the owner.');
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the contacts cards.');
            }
        });
    }

    get showError() {
        return this.error && this.error !== '';
    }

    setError(error) {
        this.error = error;
        if (error !== '' && error != null) {
            this.showErrorToast();
        }
    }

    // Showing a standard Salesforce Toast when an error has occurred on submit.
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Oops! Something went wrong and an error has occured.',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

}