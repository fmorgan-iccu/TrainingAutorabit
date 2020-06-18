import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';

import momentJs from '@salesforce/resourceUrl/MomentJS';
import fetchContact from '@salesforce/apex/ContactController.fetchContact';
import getAuthenticationInfo from '@salesforce/apex/AuthController.getAuthenticationInfo';
import sendSkipAPayForSignature from '@salesforce/apex/ESignComponentController.sendSkipAPayForSignature';
import Illustrations from '@salesforce/resourceUrl/Illustrations';

export default class CrmSkipAPayForm extends LightningElement {
    @track accounts = [];
    @track finalAccounts = [];
    @track accountSelection = true;
    @track contact = {};
    @track complete = false;
    @api contactid = null;
    @track error = '';
    @track isDisabled = false;
    @track isLoading = true;
    @track isSaving = false;
    @track nextPaymentDate = null;
    @track notEligible = false;
    showFeeInformation = false;
    @track showMadApprovalCheckbox = false;
    successImage = Illustrations + '/form-to-docusign.png';
    @track disableContinueButton = true;
    @track today = null;
    @track nextSkippedDate = null;
    @track disableSubmit = true;


    connectedCallback() {
        this.getContact(this.contactid, false);
        loadScript(this, momentJs);
        this.today = new Date();
    }

    handleContinueClicked() {
        this.accountSelection = false;
        let accountLookupComp = this.template.querySelector('c-crm-multiple-account-selection');
        accountLookupComp.switchViews();
        this.accounts = accountLookupComp.getSelectedAccounts();
        if (this.accounts.length > 0) {
            for (let a of this.accounts) {
                if (a.canSkipPayment == false) {
                    this.notEligible = true;
                } else {
                    this.notEligible = false;
                }
            }
        }
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

            // Chain a call to get the user's information
            return getAuthenticationInfo({});
        }).then(result => {
            if (result.error) {
                this.setError(result.error);
                this.isDisabled = true;
            }

            this.user = result;
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

    enableContinue(event) {
        this.disableContinueButton = event.detail;
        this.accountSelection = true;
        this.notEligible = true;
        this.disableSubmit = true;
    }

    get skipPaymentOptions() {
        return [
            { label: 'This month', value: moment(this.today).format('MM/DD/YYYY')},
            { label: 'Next month (' + moment(this.today).add(1, "month").startOf("month").format('MMMM') + ')', value: moment(this.today).add(1, "month").format('MM/DD/YYYY')},
            { label: moment(this.today).add(2, "month").startOf("month").format('MMMM'), value: moment(this.today).add(2, "month").startOf("month").format('MM/DD/YYYY')},
            { label: moment(this.today).add(3, "month").startOf("month").format('MMMM'), value: moment(this.today).add(3, "month").startOf("month").format('MM/DD/YYYY')},
            { label: moment(this.today).add(4, "month").startOf("month").format('MMMM'), value: moment(this.today).add(4, "month").startOf("month").format('MM/DD/YYYY')},
            { label: moment(this.today).add(5, "month").startOf("month").format('MMMM'), value: moment(this.today).add(5, "month").startOf("month").format('MM/DD/YYYY')},
        ]
    }

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded(event) {
        this.isLoading = event.detail;
    }

    skippedPaymentChanged(event) {
        this.nextSkippedDate = event.detail.value;
        this.nextPaymentDate = moment(this.nextSkippedDate).add(1, "month").startOf("month").format('MMMM')
        this.disableSubmit = false;
    }

    toggleEligibility(event) {
        if (event.detail.checked === true) {
            this.notEligible = false;
            let accountLookupComp = this.template.querySelector('c-crm-multiple-account-selection');
            accountLookupComp.resetAllToEligible();
            this.disableSubmit = false;
        } else {
            this.notEligible =true;
            this.disableSubmit = true;
        }
    }

    setError(message) {
        this.error = message;
        this.isLoading = false;
        this.isSaving = false;
        this.showErrorToast();
    }

    get showError() {
        return this.error && this.error !== '';
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

    submitSkipAPayForm() {
        this.error = null;
        this.isSaving = true;

        if (this.accounts.length == 0) {
            this.setError('Selected Accounts cannot be 0.');
            return;
        }

        for (let acc of this.accounts) {
            let paymentAmount = acc.nextPaymentAmount ? acc.nextPaymentAmount : acc.visaNextPaymentAmount;
            let loanType = acc.accountType == 'creditcard' ? 'visa' : 'consumer';
            let todaysDay = moment(this.today).format('D');
            let skippedDate = null;
            if ((parseInt(acc.nextPaymentDateDay) <= parseInt(todaysDay)) && (this.nextSkippedDate == moment(this.today).format('MM/DD/YYYY'))) {
                skippedDate = moment(this.nextSkippedDate).add(1, 'M').format('M') + '/' + acc.nextPaymentDateDay + '/' + moment(this.nextSkippedDate).format('YYYY');
            } else {
                skippedDate = moment(this.nextSkippedDate).format('M') + '/' + acc.nextPaymentDateDay + '/' + moment(this.nextSkippedDate).format('YYYY');
            }
            // If the members payment due date falls on the 31st, DNA automatically moves it back to the last day of that month when processed.
            // We need to do the same for the Skip form so we check and set the date to the last day of the month..
            if (acc.nextPaymentDateDay == 31) {
                skippedDate = moment(this.nextSkippedDate).endOf('month').format('M/D/YYYY');
            }
            let skippedMonth = moment(skippedDate).format('MM');

                let account = {
                    "accountNumber": acc.accountNumber,
                    "accountDescription": acc.displayName,
                    "unpaidBalance": acc.currentBalance.toString(),
                    "paymentAmount": paymentAmount.toString(),
                    "skipDate": skippedDate,
                    "letterDate": moment(this.today).format('MM/DD/YYYY'),
                    "skipMonth": skippedMonth,
                    "loanType": loanType
                };
                this.finalAccounts.push(account);
        }

        if (!this.contact.Name) {
            this.setError('Please provide the members name in Helix.');
            return;
        }
        if (!this.contact.Email) {
            this.setError('Please provide the members email address in Helix.');
            return;
        }
        if (!this.contact.MemberNumber__c) {
            this.setError('Member Number was blank.');
            return;
        }

        let requestJson = JSON.stringify({
            name: this.contact.Name,
            email: this.contact.Email,
            memberNumber: this.contact.MemberNumber__c.toString(),
            addressLine1: this.contact.MailingStreet,
            city: this.contact.MailingCity,
            state: this.contact.MailingState,
            postalCode: this.contact.MailingPostalCode,
            accounts: this.finalAccounts
        });

        //let encodedJson = encodeURI(requestJson);
        //encodedJson = encodedJson.replace(/#/g, '%23');

        sendSkipAPayForSignature({ jsonPayload : requestJson }).then(result => {
            let ACHResult = result ? result : {};
            if (!ACHResult.error) {
                this.complete = true;
                this.isSaving = false;
            } else {
                this.setError('Unable to complete Skip-A-Pay form. ' + ACHResult.error);
                this.isDisabled = true;
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to submit the form.');
            }

            this.isDisabled = true;
        });
    }

}