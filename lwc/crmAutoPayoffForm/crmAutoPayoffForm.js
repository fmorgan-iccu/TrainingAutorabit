import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import momentJs from '@salesforce/resourceUrl/MomentJS';

import fetchContact from '@salesforce/apex/ContactController.fetchContact';
import getAuthenticationInfo from '@salesforce/apex/AuthController.getAuthenticationInfo';
import getAccountWithPayoff from '@salesforce/apex/MemberAccountsController.getAccountWithPayoff';

export default class CrmAutoPayoffForm extends LightningElement {
    account = null;
    payoffAccount = [];
    @track accountSearch = false;
    @track accountSelected = false;
    @track complete = false;
    @track contact = {};
    @api contactid = null;
    @api editing = false;
    @track error = null;
    @track errorOnSubmit = null;
    @track isDisabled = false;
    @track isLoading = true;
    @track isSaving = false;
    @track renderPdfUrl = null;
    @track showAccountList = false;
    @track taxOwner = {};
    @track titleRelease = false;
    @track payoffDate = null;
    @track payoffAmount = null;
    @track perDiem = null;
    user = {};

    connectedCallback() {
        this.getContact(this.contactid, false);
        this.editing = true;
        this.payoffDate = this.addDays(new Date(), 15).toISOString();

        loadScript(this, momentJs);
    }

    addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
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
        }).finally(() => {
            this.isLoading = false;
        });
    }

    getAccountPayoff() {
        this.isLoading = true;
        getAccountWithPayoff({ accountNumber: this.account.accountNumber, payoffDate: this.payoffDate }).then(result => {
            if (result.error) {
                this.setError('Unable to retrieve the payoff amount.');
                this.isDisabled = true;
                return;
            }
            if (!result.account) {
                this.setError('Account was not returned while retrieving the payoff amount.');
                this.isDisabled = true;
                return;
            }
            let account = result.account;
            this.payoffAmount = account.payoffAmount.toFixed(2);
            this.perDiem = account.perDiem.toFixed(2);
            this.isLoading = false;
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the payoff amount.');
            }

            this.isDisabled = true;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    get formattedPayoffDate() {
        return this.payoffDate;
    }

    get disableSubmit() {
        return !this.accountSelected;
    }

    handleAccountChange() {
        // Determine who the tax owner for the account and retrieve their information.
        this.taxOwner = {};
        this.accountSelected = false;
        this.titleRelease = false;
        this.error = null;
        let accountLookupComp = this.template.querySelector('c-crm-account-lookup');
        this.account = accountLookupComp.getSelectedAccount();
        if (this.account) {
            for (let owner of this.account.jointOwners) {
                if (owner.roleCode === 'TAX' && owner.contactId) {
                    this.getContact(owner.contactId, true);
                    this.accountSelected = true;
                    break;
                }
            }
            this.getAccountPayoff();
        }
        if (this.account != null && !this.accountSelected) {
            this.setError('Unable to find the tax owner of this account in Helix.  Please contact Help Desk.');
        }
    }

    handleCountryChangeError() {
        let addressDetailComponent = this.template.querySelector('c-crm-Lwc-Address-Detail');
        let isUSA = addressDetailComponent.getIsUnitedStates();

        if (!isUSA) {
            this.setError('This form cannot handle different countries, please contact loan servicing to release a title to another country');
        } else {
            this.setError('');
        }
    }

    handleFormError(event) {
        let message = event.detail.error;
        this.setError(message);
    }

    handleFormLoading(event) {
        this.isLoading = true;
    }

    handleFormLoaded(event) {
        this.isLoading = false;
    }

    handleFormSaving(event) {
        this.isSaving = true;
    }

    handleFormSucess(event) {
        this.complete = true;
        this.isSaving = false;
        this.showSuccessToast('The title release form has been saved to OnBase.');
    }

    handlePayoffDateChange(event) {
        let today = new Date();
        today = today.toISOString().split('T')[0];
        today = Date.parse(today);

        let payoffDateComp = this.template.querySelector('.payoff-date');
        payoffDateComp.setCustomValidity('');

        this.payoffDate = event.detail.value;
        let payoffDate = this.payoffDate !== '' ? Date.parse(this.payoffDate) : null;
        if (payoffDate < today) {
            payoffDateComp.setCustomValidity('Can\'t be in the past');
        } else {
            this.getAccountPayoff();
        }

        payoffDateComp.showHelpMessageIfInvalid();
    }

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded() {
        this.isLoading = false;
    }

    handleSubmitForm() {
        this.error = null;
        this.errorOnSubmit = null;

        if (!this.account || !this.taxOwner) {
            this.setError('A account with a tax owner must be selected before submitting this form.');
            return;
        }

        let addressDetailComponent = this.template.querySelector('c-crm-Lwc-Address-Detail');
        let addressDetailValid = addressDetailComponent.checkValidity();

        let payoffAmountComponent = this.template.querySelector('.payoff-amount');
        let payoffAmountInvalid = payoffAmountComponent.checkValidity();
        payoffAmountComponent.showHelpMessageIfInvalid();

        let perDiemComponent = this.template.querySelector('.per-diem');
        let perDiemInvalid = perDiemComponent.checkValidity();
        perDiemComponent.showHelpMessageIfInvalid();

        if (!addressDetailValid ||
            !payoffAmountInvalid ||
            !perDiemInvalid)
        {
            this.setErrorOnSubmit('Provide all of the required fields.');
            return;
        }

        if (this.titleRelease) {
            let detailComponent = this.template.querySelector('c-crm-title-release-detail');
            detailComponent.submitForm();
        } else {
            this.handleAutoPayoffGeneration();
        }
    }

    handleAutoPayoffGeneration() {
        // Extract the information from the form for sending to the XFDF generation.
        let addressDetailComponent = this.template.querySelector('c-crm-Lwc-Address-Detail');
        let fullAddress = null;
        let addressState = null;
        let addressPostalCode = null;
        let addressCity = null;
        if (addressDetailComponent) {
            fullAddress = addressDetailComponent.getLine1() + ' ' + addressDetailComponent.getLine2();
            addressCity = addressDetailComponent.getCity();
            addressState = addressDetailComponent.getState();
            addressPostalCode = addressDetailComponent.getPostalCode();
        }

        let companyNameComponent = this.template.querySelector('.company-name');
        let companyName = companyNameComponent.value;

        let payoffAmountComponent = this.template.querySelector('.payoff-amount');
        let payoffAmount = payoffAmountComponent.value;

        let perDiemComponent = this.template.querySelector('.per-diem');
        let perDiem = perDiemComponent.value;

        let requestJson = JSON.stringify({
            accountNumber: this.account.accountNumber,
            companyCityStatePostalCode: addressCity + ', ' + addressState + ' ' + addressPostalCode,
            companyName: companyName,
            companyStreet: fullAddress,
            memberCityStatePostalCode: this.taxOwner.MailingCity + ', ' + this.taxOwner.MailingState + ' ' + this.taxOwner.MailingPostalCode,
            memberName: this.taxOwner.Name,
            memberStreet: this.taxOwner.MailingStreet,
            teamMemberName: this.user.name,
            teamMemberTitle: this.user.title ? this.user.title : 'ICCU Team Member',
            payoffAmount: payoffAmount,
            payoffDate: moment(this.payoffDate).format('MM/DD/YYYY'),
            perDiem: perDiem
        });
        let encodedJson = encodeURI(requestJson);
        encodedJson = encodedJson.replace(/#/g, '%23');

        let targetUrl = '/apex/AutoPayoffXfdf?payload=' + encodedJson;

        this.renderPdfUrl = targetUrl;
        this.complete = true;
        this.isSaving = false;
    }

    handleTitleRelease(event) {
        this.titleRelease = event.target.checked;
    }

    handleMailToMember(event) {
        this.mailToMember = event.target.checked;
    }

    setError(error) {
        this.error = error;
        this.isLoading = false;
        this.isSaving = false;
        if (error !== '' && error != null) {
            this.showErrorToast();
        }
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

    // Showing a standard Salesforce Toast when an error has occurred on submit.
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Oops! Something went wrong and an error has occured.',
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