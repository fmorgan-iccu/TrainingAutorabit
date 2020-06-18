import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import momentJs from '@salesforce/resourceUrl/MomentJS';

import fetchContact from '@salesforce/apex/ContactController.fetchContact';
import getAuthenticationInfo from '@salesforce/apex/AuthController.getAuthenticationInfo';
import getAccountCollateral from '@salesforce/apex/MemberAccountsController.getAccountCollateral';
import sendSubsequentActionForSignature from '@salesforce/apex/ESignComponentController.sendSubsequentActionForSignature';
import Illustrations from '@salesforce/resourceUrl/Illustrations';

export default class CrmAutoPayoffForm extends LightningElement {
    account = null;
    coBorrowers = [];
    @track addInsuranceOption = '';
    @track taxOwner = {};
    contact = {};
    coBorrower2 = {};
    coBorrower3 = {};
    @track error = null;
    @track isDisabled = false;
    @api editing = false;
    @track accountSelected = false;
    @track complete = false;
    @api contactid = null;
    @track currentBalance = '';
    @track dueDate = null;
    @track effectiveDate = new Date();
    @track errorOnSubmit = null;
    @track insuranceOption = [];
    @track interestRate = '';
    @track isLoading = true;
    @track isSaving = false;
    @track lifeOptOutName = '';
    @track lifeOptOutRoleType = '';
    @track disOptOut = '';
    @track modificationTypeValue =[];
    @track requestType = null;
    @track showDisOptOut = false;
    @track showDueDate = false;
    @track showEffectiveDate = false;
    @track showIncreasePayment = false;
    @track showInterestRate = false;
    @track showLifeOptOut = false;
    @track showModReason = false;
    @track showPaymentAmount = false;
    @track showRemoveOtherBorrower = false;
    successImage = Illustrations + '/form-to-docusign.png';
    @track paymentAmount = '';
    @track removeBorrowerOptionName = '';
    @track removeBorrowerOptionRoleCode = '';
    @track hasLifeInsurance = false;
    @track hasDisabilityInsurance = false;
    @track modificationReason = '';
    @track modificationReason2 = '';
    @track description = '';
    @track vin = '';
    @track disableSubmit = true;
    @track missingEmail = false;

    connectedCallback() {
        this.getContact(this.contactid, "CONTACT");
        loadScript(this, momentJs);
        this.editing = true;
    }

    get addInsuranceOptions() {
        return [
            { label: 'Continuing to make monthly payments until insurance is paid for', value: 'continuedPayments' },
            { label: 'Increasing the monthly payment', value: 'increasedPayment' }
        ];
    }

    get disOptOutOptions() {
        return [
            { label: this.taxOwner.Name, value: this.taxOwner.Name }
        ];
    }

    get insuranceOptions() {
        let options = [];
        if (this.hasLifeInsurance && !this.hasDisabilityInsurance) {
            options = [{ label: 'Life', value: 'life' }];
        } else if (this.hasDisabilityInsurance && !this.hasLifeInsurance) {
            options = [{ label: 'Disability', value: 'disability' }];
        } else if (this.hasLifeInsurance && this.hasDisabilityInsurance) {
            options = [{ label: 'Life', value: 'life' }, { label: 'Disability', value: 'disability' }];
        }
        return options;
    }

    get lifeOptOutOptions() {
        return this.coBorrowers;
    }

    get modificationReasons() {
        return [
            { label: 'Due Date Change', value: 'Due Date Change' },
            { label: 'ICCU Rate Match', value: 'ICCU Rate Match' },
            { label: 'ICCU Retention', value: 'ICCU Retention' },
            { label: 'MRC', value: 'MRC' },
            { label: 'SCRA (Servicemember Civil Relief Act)', value: 'SCRA' },
            { label: 'Team Member Loans', value: 'Team Member Loans' },
        ];
    }

    get modificationTypeOptions() {
        return [
            { label: 'Payment amount', value: 'Payment Amount' },
            { label: 'Interest Rate', value: 'Interest Rate' },
            { label: 'Due Date', value: 'Due Date' }
        ];
    }

    get removeBorrowerOptions() {
        return this.coBorrowers;
    }

    get requestTypeOptions() {
        let options = [];
        if (this.hasLifeInsurance || this.hasDisabilityInsurance) {
            options = [
                { label: 'Loan Modification', value: 'modification' },
                { label: 'Removing Credit Insurance Protection', value: 'declination' }, //remove me
                { label: 'Adding Credit Insurance Protection', value: 'addInsurance' }, // only if it does not already have both insurances
                { label: 'Releasing a borrower/guarantor', value: 'releaseBorrower' } // only if it has an additional borrower
            ];
        } else {
            options = [
                { label: 'Loan Modification', value: 'modification' },
                { label: 'Adding Credit Insurance Protection', value: 'addInsurance' }, // only if it does not already have both insurances
                { label: 'Releasing a borrower/guarantor', value: 'releaseBorrower' } // only if it has an additional borrower
            ];
        }
        return options;
    }

    changeAddInsurance(event) {
        this.addInsuranceOption = event.detail.value;
        if (this.addInsuranceOption === 'continuedPayments') {
            this.showIncreasePayment = false;
        } else if (this.addInsuranceOption === 'increasedPayment') {
            this.showIncreasePayment = true;
        } else {
            this.showIncreasePayment = false;
        }
    }

    changeEffectiveDate(event) {
        this.effectiveDate = event.detail.value;
    }

    changeLifeOption(event) {
        this.lifeOptOutName = event.detail.label;
        this.lifeOptOutRoleType = event.detail.value;
    }

    changeInsurance(event) {
        this.insuranceOption = event.detail.value;
        if (this.insuranceOption[0] == 'life' && this.insuranceOption.length == 1) {
            this.showDisOptOut = false;
            this.showLifeOptOut = true;
        } else if (this.insuranceOption[0] == 'disability' && this.insuranceOption.length == 1) {
            this.showLifeOptOut = false;
            this.showDisOptOut = true;
        } else if (this.insuranceOption.length == 0){
            this.showLifeOptOut = false;
            this.showDisOptOut = false;
        } else {
            this.showLifeOptOut = true;
            this.showDisOptOut = true;
        }
    }

    changeDueDate(event) {
        this.dueDate = event.detail.value;
        this.effectiveDate = event.detail.value;
    }

    changeRemoveBorrower(event) {
        let nameRole = event.detail.value.split('|');
        this.removeBorrowerOptionName =  nameRole[0];
        this.removeBorrowerOptionRoleCode = nameRole[1];
    }

    changeRequestType(event) {
        this.requestType = event.detail.value;
        this.disableSubmit = false;
    }

    changeModificationReason(event) {
        this.modificationReason = event.detail.value;
    }

    changeModificationReason2(event) {
        this.modificationReason2 = event.detail.value;
    }

    changeInterestRate(event) {
        this.interestRate = event.detail.value;
    }

    changePaymentAmount(event) {
        this.paymentAmount = event.detail.value;
    }

    get showAddInsurance() {
        return this.requestType === 'addInsurance';
    }

    get showDeclination() {
        return this.requestType === 'declination';
    }

    get showNoBorrower() {
        let showNoBorrower = this.coBorrowers.length == 0;
        if (showNoBorrower) {
            this.disableSubmit = true;
        }
        return showNoBorrower;
    }

    get showError() {
        return this.error && this.error !== '';
    }

    get showErrorOnSubmit() {
        return this.errorOnSubmit && this.errorOnSubmit !== '';
    }

    get showModification() {
        return this.requestType === 'modification';
    }

    get showReleaseBorrower() {
        return this.requestType === 'releaseBorrower';
    }

    getContact(id, role) {
        fetchContact({ contactId: id }).then(result => {
            let fetchedContact = result ? result : {};
            if (fetchedContact) {
                if (role === "TAX") {
                    this.taxOwner = fetchedContact;
                } else if (role === "CONTACT") {
                    this.contact = fetchedContact;
                    if (!this.contact.Email) {
                        this.missingEmail = true;
                        this.disableSubmit = true;
                    }
                } else if (role === "coBorrower2") {
                    this.coBorrower2 = fetchedContact;
                } else if (role === "coBorrower3") {
                    this.coBorrower3 = fetchedContact;
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
                return;
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

    handleAccountChange() {
        // Determine who the tax owner for the account and retrieve their information.
        this.taxOwner = {};
        let jointOwners = {};
        this.accountSelected = false;
        this.error = null;
        let accountLookupComp = this.template.querySelector('c-crm-account-lookup');
        this.account = accountLookupComp.getSelectedAccount();
        if (this.account) {
            for (let owner of this.account.jointOwners) {
                if (owner.roleCode === 'TAX' && owner.contactId) {
                    this.getContact(owner.contactId, "TAX");
                    this.accountSelected = true;
                    this.hasLifeInsurance = this.account.hasLifeInsurance;
                    this.hasDisabilityInsurance = this.account.hasDisabilityInsurance;
                    this.currentBalance = this.account.formattedCurrentBalance.toFixed(2);
                    this.dueDate = this.account.nextPaymentDate;
                    this.interestRate = (this.account.interestRate * 100).toFixed(2);
                    this.paymentAmount = this.account.formattedMonthlyPayment.toFixed(2);
                    this.getSelectedCollateral(this.account.accountNumber);
                    continue;
                }
                if (jointOwners.hasOwnProperty(owner.fullName) === false && (owner.roleCode === 'OWN' || owner.roleCode === 'SIGN' || owner.roleCode === 'GUAR') && owner.contactId) {
                    let role = '';
                    if (owner.roleCode == 'OWN' || owner.roleCode == 'SIGN') {
                        role = 'Borrower';
                    }
                    if (owner.roleCode == 'GUAR') {
                        role = 'Guarantor';
                    }
                    let option = {
                        "label": owner.fullName,
                        "value": owner.fullName + '|' + role,
                        "contactId": owner.contactId
                    };
                    this.coBorrowers.push(option);
                    jointOwners[owner.fullName] = option;
                    continue;
                }
            }
            if (this.coBorrowers.length > 0) {
                let borrower1Id = this.coBorrowers[0].contactId;
                this.getContact(borrower1Id, 'coBorrower2');
            }
            if (this.coBorrowers.length > 1) {
                let borrower1Id = this.coBorrowers[1].contactId;
                this.getContact(borrower1Id, 'coBorrower3');
            }
        }
        if (this.account != null && !this.accountSelected) {
            this.setError('Unable to find the tax owner of this account in Helix.  Please contact Help Desk.');
        }
    }

    getSelectedCollateral(accountNumber) {
        getAccountCollateral({ accountNumber: accountNumber }).then(result => {
            if (result.error && result.error !== '') {
                this.setError(result.error);
            }
            if (result.collateral) {
                this.collateral = result.collateral;
                for (let a of this.collateral) {
                    this.description = a.description;
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

    generateSubsequentActionForm() {
        this.error = null;
        this.errorOnSubmit = null;
        this.isSaving = true;

        // validate the form fields are complete.
        let monthlyPaymentComponent = this.template.querySelector('.monthlyPayment');
        let monthlyPaymentComponentValid = true;
        if (monthlyPaymentComponent) {
            monthlyPaymentComponentValid = monthlyPaymentComponent.checkValidity();
            monthlyPaymentComponent.showHelpMessageIfInvalid();
        }
        let interestRateComponent = this.template.querySelector('.interestRate');
        let interestRateComponentValid = true;
        if (interestRateComponent) {
            interestRateComponentValid = interestRateComponent.checkValidity();
            interestRateComponent.showHelpMessageIfInvalid();
        }
        let dueDateComponent = this.template.querySelector('.dueDate');
        let dueDateComponentValid = true;
        if (dueDateComponent) {
            dueDateComponentValid = dueDateComponent.checkValidity();
            dueDateComponent.showHelpMessageIfInvalid();
        }

        let modificationReasonComponent = this.template.querySelector('.modificationReason');
        let modificationReasonComponentValid = true;
        if (modificationReasonComponent) {
            modificationReasonComponentValid = modificationReasonComponent.checkValidity();
            modificationReasonComponent.showHelpMessageIfInvalid();
        }

        let modificationReasonComponent2 = this.template.querySelector('.modificationReason2');
        let modificationReasonComponentValid2 = true;
        if (modificationReasonComponent2) {
            modificationReasonComponentValid2 = modificationReasonComponent2.checkValidity();
            modificationReasonComponent2.showHelpMessageIfInvalid();
        }

        let effectiveDateComponent = this.template.querySelector('.effectiveDate');
        let effectiveDateComponentValid = true;
        if (effectiveDateComponent) {
            effectiveDateComponentValid = effectiveDateComponent.checkValidity();
            effectiveDateComponent.showHelpMessageIfInvalid();
        }

        let insuranceOptionsComponent = this.template.querySelector('.insuranceOptions');
        let insuranceOptionsComponentValid = true;
        if (insuranceOptionsComponent) {
            insuranceOptionsComponentValid = insuranceOptionsComponent.checkValidity();
            insuranceOptionsComponent.showHelpMessageIfInvalid();
        }

        let modReasonsComponent = this.template.querySelector('.modReasons');
        let modReasonsComponentValid = true;
        if (modReasonsComponent) {
            modReasonsComponentValid = modReasonsComponent.checkValidity();
            modReasonsComponent.showHelpMessageIfInvalid();
        }

        let addInsuranceComponent = this.template.querySelector('.addInsurance');
        let addInsuranceComponentValid = true;
        if (addInsuranceComponent) {
            addInsuranceComponentValid = addInsuranceComponent.checkValidity();
            addInsuranceComponent.showHelpMessageIfInvalid();
        }

        if (!monthlyPaymentComponentValid ||
            !interestRateComponentValid ||
            !dueDateComponentValid ||
            !modificationReasonComponentValid ||
            !insuranceOptionsComponentValid ||
            !modReasonsComponentValid ||
            !addInsuranceComponentValid ||
            !modificationReasonComponentValid2 ||
            !effectiveDateComponentValid)
        {
            this.setError('Provide all of the required fields.');
            return;
        }

        // constants for logic for sections of form
        let release = this.requestType === 'releaseBorrower' ? true : false;
        let modification = this.requestType === 'modification' ? true : false;
        let modifyPayment =this.modificationTypeValue.includes('Payment Amount') ? true : false;
        let modifyRate = this.modificationTypeValue.includes('Interest Rate') ? true : false;
        let modifyDueDate =  this.modificationTypeValue.includes('Due Date') ? true : false;
        let credit = this.requestType === 'addInsurance' ? true : false;
        let continuedPayments = this.addInsuranceOption === 'continuedPayments' ? true : false;
        let increasedPayment = this.addInsuranceOption === 'increasedPayment' ? true : false;
        let today = new Date();
        let cancelInsurance = this.requestType === 'declination' ? true : false;
        let lifeInsuranceSelected = this.insuranceOption[0] == 'life' || this.insuranceOption.length == 2 ? true : false;
        let disabilityInsuranceSelected = this.insuranceOption[0] == 'disability' || this.insuranceOption.length == 2 ? true : false;

        let requestJson = JSON.stringify({
                    iccu: {
                        accountNumber: this.account.accountNumber.toString(),
                        requestDate: moment(today).format("MM/DD/YYYY"),
                        collateralDescription: this.description,
                        vin: this.vin,

                        releaseBorrower: release ? release : false,
                        releaseDate: release ? moment(today).format("MM/DD/YYYY") : '',
                        releaseName: release ? this.removeBorrowerOptionName : '',
                        borrowerNumber: release ? this.removeBorrowerOptionRoleCode : '',

                        loanModification: modification ? modification : false,
                        unpaidBalance: modification ? this.currentBalance : '',
                        interestRate: modification ? this.interestRate : '',
                        interestStartDate: modification ? this.effectiveDate : '',
                        modMonthlyPayment: modification && modifyPayment ? modifyPayment : false,
                        modRate: modification && (modifyRate && !modifyPayment) ? modifyRate : false,
                        modNone: modification && (modifyDueDate && !modifyPayment && !modifyRate) ? modifyDueDate : false,
                        monthlyPayment1: modification && modifyPayment ? this.paymentAmount : '',
                        dueDate1: modification && modifyPayment ? moment(this.dueDate).format('M/D/YYYY') : '',
                        monthlyPayment2: modification && (modifyRate && !modifyPayment) ? this.account.formattedMonthlyPayment.toFixed(2) : '',
                        modReason1: modification ? this.modificationReason : '',
                        modReason2: modification ? this.modificationReason2 : '',

                        creditProtection: credit ? credit : false,
                        makeMorePayments: credit ? continuedPayments : false,
                        increasePayments: credit ? increasedPayment : false,
                        monthlyPayment3: credit && increasedPayment ? this.paymentAmount : '',

                        cancelationOfInsurance: cancelInsurance ? cancelInsurance : false,
                        lifeInsurance: cancelInsurance ? lifeInsuranceSelected : false,
                        lifeName1: cancelInsurance && lifeInsuranceSelected ? this.taxOwner.Name : '',
                        lifeName2: cancelInsurance && lifeInsuranceSelected ? this.lifeOptOutName : '',

                        creditDisability: disabilityInsuranceSelected,
                        creditName1: cancelInsurance && disabilityInsuranceSelected ? this.taxOwner.Name : ''
                    },
                borrowers: [
                    {
                        name: this.taxOwner.Name,
                        email: this.taxOwner.Email
                    },
                    {
                        name: this.coBorrower2.Name,
                        email: this.coBorrower2.Email
                    },
                    {
                        name: this.coBorrower3.Name,
                        email: this.coBorrower3.Email
                    }
                ]
            });

        sendSubsequentActionForSignature({ jsonPayload : requestJson }).then(result => {
            let SubResult = result ? result : {};
            if (!SubResult.error) {
                this.complete = true;
                this.isSaving = false;
            } else {
                this.setError('Unable to complete Subsequent Action form. ' + SubResult.error);
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

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
    }

    handleAccountsLoaded() {
        this.isLoading = false;
    }

    handleFormLoaded(event) {
        this.isLoading = false;
    }

    handleFormLoading(event) {
        this.isLoading = true;
    }

    handleFormSaving(event) {
        this.isSaving = true;
    }

    handleFormSucess(event) {
        this.complete = true;
        this.isSaving = false;
    }

    modificationTypeChange(event) {
        this.modificationTypeValue = event.detail.value;

        if (this.modificationTypeValue.includes('Payment Amount')) {
            this.showPaymentAmount = true;
            this.showEffectiveDate = true;
        } else {
            this.showPaymentAmount = false;
        }

        if (this.modificationTypeValue.includes('Interest Rate')) {
            this.showInterestRate = true;
            this.showEffectiveDate = true;
        } else {
            this.showInterestRate = false;
        }

        if(this.modificationTypeValue.includes('Due Date')) {
            this.showDueDate = true;
            this.showEffectiveDate = false;
            this.modificationReason = 'Due Date Change';
        } else {
            this.showDueDate = false;
            this.modificationReason = '';
        }

        if (this.modificationTypeValue.length == 0) {
            this.showInterestRate = false;
            this.showPaymentAmount = false;
            this.showDueDate = false;
            this.showModReason = false;
            this.showEffectiveDate = false;
            this.modificationReason = '';
        } else {
            this.showModReason = true;
        }
    }

    setError(error) {
        this.error = error;
        this.isLoading = false;
        this.isSaving = false;
        if (error !== '' && error != null) {
            this.showErrorToast();
        }
    }

    showAccountSearch() {
        this.accountSelected = false;
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