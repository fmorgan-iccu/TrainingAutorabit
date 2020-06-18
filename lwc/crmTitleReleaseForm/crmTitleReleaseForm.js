import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchContact from '@salesforce/apex/ContactController.fetchContact';

export default class CrmTitleReleaseForm extends LightningElement {
    account = null;
    collateral = [];
    @track contact = {};
    @track accountSearch = false;
    @track accountSelected = false;
    @api contactid = null;
    @track error = null;
    @track errorOnSubmit = null;
    @track isDisabled = false;
    @track isLoading = true;
    @track isSaving = false;
    @track showAccountList = false;
    @track taxOwner = {};
    @track complete = false;
    @api editing = false;

    connectedCallback() {
        this.getContact(this.contactid, false);
        this.editing = true;
    }

    getContact(id, taxOwner) {
        fetchContact({ contactId: id }).then(result => {
            let fetchedContact = result ? result : {};
            if (fetchedContact) {
                if (taxOwner) {
                    this.taxOwner = fetchedContact;
                } else {
                    this.contact = fetchedContact;
                }
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

    handleAccountChange() {
        // Determine who the tax owner for the account and retrieve their information.
        this.taxOwner = {};
        this.accountSelected = false;
        this.error = null;
        let accountLookupComp = this.template.querySelector('.primary-account');
        this.account = accountLookupComp.getSelectedAccount();
        if (this.account) {
            for (let owner of this.account.jointOwners) {
                if (owner.roleCode === 'TAX' && owner.contactId) {
                    this.getContact(owner.contactId, true);
                    this.accountSelected = true;
                    break;
                }
            }
        }
        if (this.account != null && !this.accountSelected) {
            this.setError('Unable to find the tax owner of this account in Helix.  Please contact Help Desk.');
        }
    }

    handleError(message) {
        this.error = message;
        this.showErrorToast();
    }

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded() {
        this.isLoading = false;
    }

    handleFormError(event) {
        let message = event.detail.error;
        this.setError(message);
    }

    handleFormSaving(event) {
        this.isSaving = true;
    }

    handleFormSucess(event) {
        this.complete = true;
        this.isSaving = false;
        this.showSuccessToast('The title release form has been saved to OnBase.');
    }

    handleSubmitForm() {
        let detailComponent = this.template.querySelector('c-crm-title-release-detail');
        detailComponent.submitForm();
    }

    handleFormLoaded(event) {
        this.isLoading = false;
    }

    handleFormLoading(event) {
        this.isLoading = true;
    }

    // functions for custom events from child detail component.
    setError(message) {
         this.error = message;
         this.isLoading = false;
         this.isSaving = false;
         this.showErrorToast();
    }

    setErrorOnSubmit(message) {
        this.errorOnSubmit = message;
        this.showErrorToast();
    }

    showAccountSearch() {
        this.accountSelected = false;
        this.showAccountList = false;
        this.accountSearch = true;
    }

    get showError() {
        return this.error && this.error !== '';
    }

    get showErrorOnSubmit() {
        return this.errorOnSubmit && this.errorOnSubmit !== '';
    }

    get disableSubmit() {
        return !this.accountSelected;
    }

    // Showing a standard Salesforce Toast when an error has occurred on submit.
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Oops! Something went wrong and an error has occured. ',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }


    // Showing a standard Salesforce Toast on a successful submit.
    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Form submitted successfully!',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

}