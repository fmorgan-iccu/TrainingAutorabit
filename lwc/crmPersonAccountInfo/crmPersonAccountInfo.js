import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getContactByAccount from '@salesforce/apex/ContactController.getContactByAccount';

export default class CrmPersonAccountInfo extends NavigationMixin(LightningElement) {
    // [ ] person ID? to link to profile?
    @track contact = {};
    @api recordId;
    @track error = '';

    connectedCallback() {
        this.accountId = this.recordId;
        this.getContact(this.accountId);
    }

    handleNavigation(event) {
        let contactHomePageRef = {};
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();
        contactHomePageRef = {
            type: 'standard__recordPage',
                attributes: {
                    recordId: this.contact.Id,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
        };
        // Navigate to the Contact Home page.
        this[NavigationMixin.Navigate](contactHomePageRef);
    }

    getContact(id) {
        getContactByAccount({ accountId: id }).then(result => {
            let fetchedContact = result ? result : {};
            if (fetchedContact) {
                this.contact = fetchedContact;
            } else {
                this.setError('Unable to retrieve the contact.');
                this.isDisabled = true;
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the contacts cards.');
            }

            this.isDisabled = true;
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