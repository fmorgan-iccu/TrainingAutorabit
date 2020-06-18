import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';

import momentJs from '@salesforce/resourceUrl/MomentJS';

import getAccountCollateral from '@salesforce/apex/MemberAccountsController.getAccountCollateral';
import fetchContact from '@salesforce/apex/ContactController.fetchContact';

export default class CrmGapCancellationForm extends LightningElement {
    account = null;
    contact = {};
    @api contactid = null;
    @track taxOwner = {};
    @track complete = false;
    @track error = '';
    @track accountSelected = false;
    @track errorOnSubmit = '';
    @track showExplanation = false;
    @track isLoading = true;
    @track isSaving = false;
    @track make = '';
    @track model = '';
    @track year = '';
    @track vin = '';
    @track fullRefund = true;
    @track fullRefundOnLoad = null;
    @track effectiveDate = null;
    @track cancellationDate = null;
    @track cancelBeforeDate = null;
    @track renderPdfUrl = null;

    connectedCallback() {
        this.getContact(this.contactid, false);
        loadScript(this, momentJs);
    }

    get cancellationOptions() {
        return [
            { label: 'Member Requested', value: 'requested' },
            { label: 'Other', value: 'other' },
        ];
    }

    get disableSubmit() {
        return !this.accountSelected;
    }

    get memberHasFullRefund() {
        return this.fullRefundOnLoad && this.fullRefund;
    }

    onChangeCancellationReason(event) {
        this.showExplanation = event.detail.value === 'other';
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
                    this.getSelectedCollateral(this.account.accountNumber);
                    this.fullRefundOnLoad = this.account.fullRefund;
                    this.cancelBeforeDate = moment(this.account.cancelBeforeDate).format('MM/DD/YYYY');
                    this.effectiveDate =  moment(this.account.gapPurchaseDate).format('YYYY-MM-DD');
                    break;
                }
            }
        }

        if (this.account != null && !this.accountSelected) {
            this.setError('Unable to find the tax owner of this account in Helix.  Please contact Help Desk.');
        }
    }

    getContact(id) {
        fetchContact({ contactId: id }).then(result => {
            if (result.error) {
                this.setError(result.error);
            } else if (result) {
                this.taxOwner = result;
            } else {
                this.setError('Unable to retrieve the owner.');
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

    getSelectedCollateral(accountNumber) {
        getAccountCollateral({ accountNumber: accountNumber }).then(result => {
            if (result.error && result.error !== '') {
                this.setError(result.error);
            }
            if (result.collateral) {
                this.collateral = result.collateral;
                for (let a of this.collateral) {
                    this.make = a.make;
                    this.model = a.model;
                    this.year = a.year;
                    this.vin = a.id;
                    break;
                }
            }

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the collateral for the selected account.');
            }
        });
    }

    handleEffectiveDateChange(event) {
        this.effectiveDate = event.detail.value;

        this.validateDate();
    }

    handleCancellationDateChange(event) {
        this.cancellationDate = event.detail.value;
        if(this.fullRefundOnLoad) {
            if (Date.parse(this.cancellationDate) > Date.parse(this.cancelBeforeDate)) {
                this.fullRefund = false;
            } else {
                this.fullRefund = true;
            }
        }
        this.validateDate();
    }

    validateDate() {
        let today = new Date();
        today = today.toISOString().split('T')[0];
        today = Date.parse(today);

        let cancellationDateComp = this.template.querySelector('.cancellation-date');
        cancellationDateComp.setCustomValidity('');

        let formattedCancellationDate = this.cancellationDate !== '' ? Date.parse(this.cancellationDate) : null;

        if (formattedCancellationDate < today) {
            cancellationDateComp.setCustomValidity('Can\'t be in the past');
        }

        if (this.cancellationDate != null && this.effectiveDate != null) {
            if (this.cancellationDate < this.effectiveDate) {
                cancellationDateComp.setCustomValidity('Cancellation date can\'t be before effective date');
            }
        } else {
            cancellationDateComp.setCustomValidity('');
        }

        cancellationDateComp.showHelpMessageIfInvalid();
    }

    generateGapCancellationForm() {
        this.error = null;
        this.errorOnSubmit = null;

        // Extract the information from the form for sending to the XFDF generation.
        let effectiveDateComponent = this.template.querySelector('.effective-date');
        let effectiveDateComponentValid = effectiveDateComponent.checkValidity();
        let effectiveDate = effectiveDateComponent.value;
        effectiveDateComponent.showHelpMessageIfInvalid();

        let cancellationDateComponent = this.template.querySelector('.cancellation-date');
        let cancellationDateComponentValid = cancellationDateComponent.checkValidity();
        let cancellationDate = cancellationDateComponent.value;
        cancellationDateComponent.showHelpMessageIfInvalid();

        let cancellationReasonComponent = this.template.querySelector('.cancellation-reason');
        let cancellationReasonComponentValid = cancellationReasonComponent.checkValidity();
        let cancellationReason = cancellationReasonComponent.value;
        cancellationReasonComponent.showHelpMessageIfInvalid();

        let cancellationDateAcknowledgedComponent = this.template.querySelector('.cancellation-date-acknowledged');
        let cancellationDateAcknowledgedComponentValid = true;
        if (cancellationDateAcknowledgedComponent) {
            cancellationDateAcknowledgedComponentValid = cancellationDateAcknowledgedComponent.checkValidity();
            cancellationDateAcknowledgedComponent.showHelpMessageIfInvalid();
        }

        let explanationComponent = this.template.querySelector('.explanation');
        let explanation = '';
        if (explanationComponent) {
            explanation = explanationComponent.value
        }

        let requestedCheckbox = '';
        if (cancellationReason === 'requested') {
            requestedCheckbox = 'Yes';
        } else {
            requestedCheckbox = 'No';
        }

        if (!cancellationDateComponentValid ||
            !cancellationReasonComponentValid ||
            !effectiveDateComponentValid ||
            !cancellationDateAcknowledgedComponentValid)
        {
            this.setErrorOnSubmit('Provide all of the required fields.');
            return;
        }

        let requestJson = JSON.stringify({
            memberNumber: this.taxOwner.MemberNumber__c,
            loanNumber: this.account.accountNumber,
            effectiveDate: effectiveDate,
            cancellationDate: cancellationDate,
            cancellationReason: cancellationReason,
            explanation: explanation,
            memberCityStatePostalCode: this.taxOwner.MailingCity + ', ' + this.taxOwner.MailingState + ' ' + this.taxOwner.MailingPostalCode,
            memberName: this.taxOwner.Name,
            memberStreet: this.taxOwner.MailingStreet,
            memberSSN: this.taxOwner.TaxID__c,
            vehicleYear: this.year,
            vehicleMake: this.make,
            vehicleModel: this.model,
            vin: this.vin,
            requestedCheckbox: requestedCheckbox,
        });
        let encodedJson = encodeURI(requestJson);
        encodedJson = encodedJson.replace(/#/g, '%23');

        let targetUrl = '/apex/GapCancellationXfdf?payload=' + encodedJson;

        this.renderPdfUrl = targetUrl;
        this.complete = true;
        this.isSaving = false;
    }

    get showError() {
        return this.error && this.error !== '';
    }

    get showErrorOnSubmit() {
        return this.errorOnSubmit && this.errorOnSubmit !== '';
    }

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

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded() {
        this.isLoading = false;
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