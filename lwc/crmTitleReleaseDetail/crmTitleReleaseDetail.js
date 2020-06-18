import { LightningElement, track, api } from 'lwc';

import saveTitleRelease from '@salesforce/apex/TitleFormController.saveTitleRelease';
import getAccountCollateral from '@salesforce/apex/MemberAccountsController.getAccountCollateral';

const MEMBER_PAID_IN_FULL = 'Member Paid Loan in Full - Mail Title to Address Above';
export default class CrmTitleReleaseDetail extends LightningElement {
    @api account = null;
    @api taxOwner = null;
    @track make = '';
    @track model = '';
    @track year = null;
    @track vin = '';
    refinancedAccount = '';
    @track error = null;
    @track isDisabled = false;
    @api complete = false;
    @track payoffValue = '';
    @track memberValue = '';
    @api editing = false;

    connectedCallback() {
        this.editing = true;
        this.getSelectedCollateral(this.account.accountNumber);
        const loadingEvent = new CustomEvent('loading', {});
            this.dispatchEvent(loadingEvent);
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

    @api getComplete() {
        return this.complete;
    }

    handleRefinancedAccountChange() {
        // Select account for refinancing
        this.error = null;
        let refinancedAccountLookupComp = this.template.querySelector('.refinanced-account');
        this.refinancedAccount = refinancedAccountLookupComp.getSelectedAccount();
    }

    handleAccountError(event) {
        let message = event.detail;
        this.setError(message);
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

    get payoffOptions() {
        return [
            { label: 'Dealership', value: 'DEALERSHIP' },
            { label: 'Financial Institution', value: 'FINANCIAL INSTITUTION' },
            { label: 'Individual Payoff', value: 'INDIVIDUAL PAYOFF' },
            { label: 'Title Company', value: 'TITLE COMPANY' }
        ];
    }

    handlePayoffChange(event) {
        this.payoffValue = event.detail.value;
    }

    get memberOptions() {
        return [
            { label: 'Member Paid Loan in Full', value: MEMBER_PAID_IN_FULL },
            // { label: 'Member Refinanced to a New ICCU Loan - Move Title Record to New ICCU Loan', value: 'Member Refinanced to a New ICCU Loan - Move Title Record to New ICCU Loan' },
            { label: 'Member Sold the Vehicle and Buyer Paid in Cash', value: 'Member Sold Vehicle and Buyer Paid in Cash - Mail Title to Buyer' },
            { label: 'Member Sold the Vehicle and Financed the Purchase', value: 'Member Sold Vehicle and Buyer Financed Purchase - Mail Title to 3rd Party' }
            // { label: 'Member Sold Vehicle and Buyer Financed at ICCU - Move Title Record to New ICCU Loan', value: 'Member Sold Vehicle and Buyer Financed at ICCU - Move Title Record to New ICCU Loan' }
        ];
    }

    handleMemberChange(event) {
        this.memberValue = event.detail.value;
    }

    handleMakeChange(event) {
        this.make = event.detail.value;
    }
    handleModelChange(event) {
        this.model = event.detail.value;
    }
    handleYearChange(event) {
        this.year = event.detail.value;
    }
    handleVinChange(event) {
        this.vin = event.detail.value;
    }

    get showIndividualPayoff() {
        return this.payoffValue === 'INDIVIDUAL PAYOFF';
    }

    get showMailing() {
        return this.payoffValue === 'DEALERSHIP' ||
        this.payoffValue === 'FINANCIAL INSTITUTION' ||
        this.payoffValue === 'TITLE COMPANY';
    }

    get showPaidInFull() {
        return this.memberValue === MEMBER_PAID_IN_FULL;
    }
    get showMemberRefinanced() {
        return this.memberValue === 'Member Refinanced to a New ICCU Loan - Move Title Record to New ICCU Loan';
    }
    get showBuyerPaidInCash() {
        return this.memberValue === 'Member Sold Vehicle and Buyer Paid in Cash - Mail Title to Buyer';
    }
    get showBuyerFinancedICCU() {
        return this.memberValue === 'Member Sold Vehicle and Buyer Financed at ICCU - Move Title Record to New ICCU Loan';
    }
    get showBuyerFinanced() {
        return this.memberValue === 'Member Sold Vehicle and Buyer Financed Purchase - Mail Title to 3rd Party';
    }

    @api submitForm() {
        this.error = null;

        if (!this.account || !this.taxOwner) {
            this.setError('An account with a tax owner must be selected before submitting this form.');
            return;
        }

        let addressDetailComponent = this.template.querySelector('c-crm-Lwc-Address-Detail');
        let fullAddress = null;
        let addressState = null;
        let addressPostalCode = null;
        let addressDetailValid = true;
        let addressCity = null;
        if (addressDetailComponent) {
            fullAddress = addressDetailComponent.getLine1() + ' ' + addressDetailComponent.getLine2();
            addressCity = addressDetailComponent.getCity();
            addressState = addressDetailComponent.getState();
            addressPostalCode = addressDetailComponent.getPostalCode();
            addressDetailValid = addressDetailComponent.checkValidity();
        }

        let thirdPartyNameComponent = this.template.querySelector('.thirdParty');
        let thirdPartyNameValid = true;
        let thirdPartyName = null;
        if (thirdPartyNameComponent) {
            thirdPartyNameValid = thirdPartyNameComponent.checkValidity();
            thirdPartyNameComponent.showHelpMessageIfInvalid();
            thirdPartyName = thirdPartyNameComponent.value;
        }

        let attentionComponent = this.template.querySelector('.attn');
        let attention = null;
        if (attentionComponent) {
            attention = attentionComponent.value;
        }

        let companyNameComponent = this.template.querySelector('.companyName');
        let companyName = null;
        if (companyNameComponent) {
            companyName = companyNameComponent.value;
        }

        let buyersNameComponent = this.template.querySelector('.buyersName');
        let buyersNameValid = true;
        let buyersName = null;
        if (buyersNameComponent) {
            buyersNameValid = buyersNameComponent.checkValidity();
            buyersNameComponent.showHelpMessageIfInvalid();
            buyersName = buyersNameComponent.value;
        }

        // Removed for now, may need to add this back in if CLP gets HELIX.
        // let buyersIccuNumberComponent = this.template.querySelector('.buyersIccuNumber');
        // let buyersIccuNumberValid = true;
        // let buyersIccuNumber = null;
        // if (buyersIccuNumberComponent) {
        //     buyersIccuNumberValid = buyersIccuNumberComponent.checkValidity();
        //     buyersIccuNumberComponent.showHelpMessageIfInvalid();
        //     buyersIccuNumber = buyersIccuNumberComponent.value;
        // }

        // let buyersNewLoanNumberComponent = this.template.querySelector('.buyersNewLoanNumber');
        // let buyersNewLoanNumberValid = true;
        // let buyersNewLoanNumber = null;
        // if (buyersNewLoanNumberComponent) {
        //     buyersNewLoanNumberValid = buyersNewLoanNumberComponent.checkValidity();
        //     buyersNewLoanNumberComponent.showHelpMessageIfInvalid();
        //     buyersNewLoanNumber = buyersNewLoanNumberComponent.value;
        // }

        if (!this.payoffValue ||
            !thirdPartyNameValid ||
            !buyersNameValid ||
            !addressDetailValid
            )
        {
            this.setError('Provide all of the required fields.');
            return;
        }

        let memberStreetAddress = this.taxOwner.MailingStreet;
        let memberCity = this.taxOwner.MailingCity;
        let memberPostalCode = this.taxOwner.MailingPostalCode;
        let memberState = this.taxOwner.MailingState;
        if (this.memberValue === MEMBER_PAID_IN_FULL) {
            memberStreetAddress = fullAddress;
            memberCity = addressCity;
            memberPostalCode = addressPostalCode;
            memberState = addressState;
        }

        let formData = {
            accountNumber: this.account.accountNumber,
            companyName: companyName,
            payOffType: this.payoffValue,
            thirdPartyName: thirdPartyName,
            attn: attention,
            thirdPartyStreet: fullAddress,
            thirdPartyCity: addressCity,
            thirdPartyState: addressState,
            thirdPartyPostalCode: addressPostalCode,
            nonDnaStreet: fullAddress,
            nonDnaCity: addressCity,
            nonDnaState: addressState,
            nonDnaPostalCode: addressPostalCode,
            buyersName: buyersName,
            buyersStreet: fullAddress,
            buyersCity: addressCity,
            buyersState: addressState,
            buyersPostalCode: addressPostalCode,
            newLoanNumber: this.refinancedAccount.accountNumber,
            //buyersNewLoanNumber: buyersNewLoanNumber,
            actionToTake: this.memberValue,
            //buyersIccuNumber: buyersIccuNumber,
            checkBoxVerification: "1",
            make: this.make,
            model: this.model,
            year: this.year,
            vin: this.vin,
            memberCity: memberCity,
            memberPostalCode: memberPostalCode,
            memberState: memberState,
            memberStreetAddress: memberStreetAddress
        };

        let requestJson = JSON.stringify(formData);

        let request = {
            contactId: this.taxOwner.Id,
            requestJson: requestJson
        };

        // Dispatch an event to the parent indicating the form  are loading.
        const loading = new CustomEvent('saving', {});
        this.dispatchEvent(loading);

        saveTitleRelease(request)
            .then(response => {
                if (response.error) {
                    this.setError(response.error);
                    return;
                }

                // Dispatch an onsuccess event to the parent component
                const successEvent = new CustomEvent('success', {});
                this.dispatchEvent(successEvent);
            })
            .catch(err => {
                let message = JSON.stringify(err);
                this.setError(message);
            });
    }

    setError(message) {
        const error = new CustomEvent('error', {
            detail: { error: message },
        });
        this.dispatchEvent(error);
    }
}