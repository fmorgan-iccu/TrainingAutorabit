import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';

import fetchContact from '@salesforce/apex/ContactController.fetchContact';
import getAuthenticationInfo from '@salesforce/apex/AuthController.getAuthenticationInfo';
import getAccountWithTransactions from '@salesforce/apex/MemberAccountsController.getAccountWithTransactions';
import sendACHDisputeForSignature from '@salesforce/apex/ESignComponentController.sendACHDisputeForSignature';

import momentJs from '@salesforce/resourceUrl/MomentJS';
import numeralJs from '@salesforce/resourceUrl/NumeralJS';
import Illustrations from '@salesforce/resourceUrl/Illustrations';

const transactionsPerPage = 15;
const companiesPerPage = 1;

export default class CrmAchDisputeForm extends LightningElement {
    account = null;
    contact = {};
    @track accountSelected = false;
    @track complete = false;
    @api contactid = null;
    @track disableNext = true;
    @track hideBack = true;
    @track hideNext = false;
    @track hideNextTransaction = false;
    @track hideBackTransaction = true;
    @track error = '';
    @track filterTransactions = true;
    @track isDisabled = false;
    @track isLoading = false;
    @track isSaving = false;
    @track companyList = [];
    @track displayCompanyList = [];
    @track numberSelectedTransactions = 0;
    @track selectedTransactions = [];
    successImage = Illustrations + '/form-to-docusign.png';
    @track transactions = [];
    @track displayTransactions = [];
    @track unableToProcess = false;
    @track continueForm = false;
    @track taxOwner = {};
    @track transactionSelected = false;
    @track startDate = null;
    @track endDate = null;
    @track currentPage = 0;
    @track numberOfPages = 1;
    @track currentCompany = 0;
    @track numberOfCompanyPages = 1;
    @track pages = [];
    @track minAmount = null;
    @track maxAmount = null;
    @track filterDescription = null;
    @track hideNextCompany = false;
    @track hideBackCompany = true;
    @track disableSubmit = true;
    @track currentReason = '';
    @track missingEmail = false;


    connectedCallback() {
        this.getContact(this.contactid, false);
    }

    setDisplayTransactions() {
        let startIndex = this.currentPage * transactionsPerPage;
        let endIndex = startIndex + transactionsPerPage;

        if (this.minAmount != null && this.maxAmount != null) {
            this.filterByAmount(this.minAmount, this.maxAmount);
        }
        if (this.filterDescription != null) {
            this.filterByDescription(this.filterDescription);
        }
        let filteredTransactions = [];
        for (let trans of this.transactions) {
            if (!trans.isDisabled) {
                filteredTransactions.push(trans);
            }
        }
        if (endIndex > filteredTransactions.count - 1) {
            endIndex = filteredTransactions.count - 1;
        }

        this.displayTransactions = filteredTransactions.slice(startIndex, endIndex);
        this.updatePages(filteredTransactions);
        if (this.numberOfPages == 1 || this.numberOfPages == 0) {
            this.hideNextTransaction = true;
            this.hideBackTransaction = true;
        } else {
            this.hideNextTransaction = false;
        }
    }

    setDisplayCompanies() {
        let startIndex = this.currentCompany * companiesPerPage;
        let endIndex = startIndex + companiesPerPage;

        if (endIndex > this.companyList.count - 1) {
            endIndex = this.companyList.count - 1;
        }

        this.displayCompanyList = this.companyList.slice(startIndex, endIndex);
        this.updateCompanyPages(this.companyList);
        if (this.numberOfCompanyPages == 1 || this.numberOfCompanyPages == 0) {
            this.hideNextCompany = true;
            this.hideBackCompany = true;
            this.disableSubmit = false;
        } else {
            this.hideNextCompany = false;
            this.disableSubmit = true;
        }
        this.currentReason = this.displayCompanyList[0].reason;
    }

    handleNextClicked(event) {
        this.currentPage = this.currentPage + 1;
        this.setDisplayTransactions();
        if (this.currentPage == this.numberOfPages - 1) {
            this.hideNextTransaction = true;
        }
        if (this.currentPage != 0) {
            this.hideBackTransaction = false;
        }
    }

    handleBackClicked(event) {
        this.currentPage = this.currentPage - 1;
        this.setDisplayTransactions();
        if (this.currentPage == 0) {
            this.hideBackTransaction = true;
        }
    }

    handleNextCompanyClicked(event) {
        let reasonComponent = this.template.querySelector('.disputeReason');
        let reasonComponentValid = reasonComponent.checkValidity();
        reasonComponent.showHelpMessageIfInvalid();

        if (!reasonComponentValid) {
            this.setError('Please provide the dispute reason.');
            return;
        } else {
            this.error = null;
            this.currentCompany = this.currentCompany + 1;
            this.setDisplayCompanies();
        }
        if (this.currentCompany == this.numberOfCompanyPages - 1) {
            this.hideNextCompany = true;
            this.disableSubmit = false;
        }
        if (this.currentCompany != 0) {
            this.hideBackCompany = false;
        }
    }

    handleBackCompanyClicked(event) {
        this.currentCompany = this.currentCompany - 1;
        this.setDisplayCompanies();
        if (this.currentCompany == 0) {
            this.hideBackCompany = true;
        }
    }

    updatePages(transactions) {
        let count = transactions.length;
        let pages = Math.ceil(count / transactionsPerPage);
        this.numberOfPages = pages;
    }

    updateCompanyPages(companyList) {
        let count = companyList.length;
        let pages = Math.ceil(count / companiesPerPage);
        this.numberOfCompanyPages = pages;
    }

    showAllTransactions() {
        this.filterTransactions = false;
        if (this.transactions) {
            for (let trans of this.transactions) {
                if (trans.typeCode !== 'XWTH') {
                    trans.isDisabled = false;
                    trans.disableAch = true;
                    continue;
                } else {
                    trans.disableAch = false;
                }
            }
            this.setDisplayTransactions();
        }
    }

    showFilteredTransactions() {
        this.filterTransactions = true;
        this.currentPage = 0;

        if (this.transactions) {
            for (let trans of this.transactions) {
                if (trans.typeCode !== 'XWTH') {
                    trans.isDisabled = true;
                    continue;
                } else {
                    trans.isDisabled = false;
                }
            }
            this.setDisplayTransactions();
        }
    }

    get companyContactOptions() {
        return [
            { label: 'Yes', value: 'Yes'},
            { label: 'No', value: 'No'}
        ];
    }
    handleContactedCompany(event) {
        let value = event.detail.value;
        if (value == 'Yes') {
            this.continueForm = true;
            this.unableToProcess = false;
            this.isLoading = true;
        }
        if (value == 'No') {
            this.unableToProcess = true;
        }
    }

    getTransactions(contactId, accountNumber, startDate, endDate) {
        getAccountWithTransactions({ recordId: contactId, accountNumber: accountNumber, startDate: startDate, endDate: endDate }).then(result => {
            this.transactions = result.transactions ? result.transactions : {};
            if (this.transactions) {
                this.showFilteredTransactions();
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the ach transactions.');
            }

            this.isDisabled = true;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    getContact(id, taxOwner) {
        fetchContact({ contactId: id }).then(result => {
            let fetchedContact = result ? result : {};
            if (fetchedContact) {
                if (taxOwner) {
                    this.taxOwner = fetchedContact;
                } else {
                    this.contact = fetchedContact;
                    if (!this.contact.Email) {
                        this.missingEmail = true;
                        this.isLoading = false;
                    }
                }
            } else {
                this.setError('Unable to retrieve the contact.');
                this.isDisabled = true;
            }

            // Chain a call to get the user's information
            return getAuthenticationInfo({});
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

    get disputeReasons() {
        return [
            { label: 'Unauthorized', value: 'NOT_AUTHORIZED', info: 'The member did not authorize the transaction.'},
            { label: 'Revoked Authorization', value: 'REVOKED_AUTHORIZATION' , info: 'The member did authorize the transaction, but revoked the authorization in the manner specified within that authorization prior to the initiation of the entry.'},
            { label: 'Entry Cleared Earlier than Authorized', value: 'BEFORE_AUTHORIZATION' , info: 'The transaction cleated the account on a date earlier than the date the member authorized.'},
            { label: 'Amount Differs from Authorized Amount', value: 'DIFFERENT_AMOUNT' , info: 'The transaction cleared for an amount different from what was authorized by the member.'},
            { label: 'Incomplete Transaction', value: 'INCOMPLETE_TXN' , info: 'A payment authorized by the member to an intended third-party payee was not made or completed. A partial or erroneous payment to the intended third-party payee is not an Incomplete Transaction.'},
            { label: 'Source Document Cleared and Processed as Electronic Check', value: 'ELECTRONIC_CHECK' , info: 'The check that was used as a source document for the electronic check and the electronic check itself have both been presented for payment and posted to the member account.'}
        ];
    }

    handleTransactionSearch() {
        if (this.transactions.length > 0) {
            for (let trans of this.transactions) {
                    trans.isDisabled = false;
                    continue;
            }
        }
        let transactionSearchLookupComp = this.template.querySelector('c-crm-transaction-search');
        if (transactionSearchLookupComp.getStartDate() != null || transactionSearchLookupComp.getEndDate() != null) {
            this.isLoading = true;
            this.startDate = transactionSearchLookupComp.getStartDate();
            this.endDate = transactionSearchLookupComp.getEndDate();
            this.getTransactions(this.contactid, this.account.accountNumber, this.startDate, this.endDate);
        }
        if (transactionSearchLookupComp.getAmountMin() != null) {
            this.minAmount = transactionSearchLookupComp.getAmountMin();
        }
        if (transactionSearchLookupComp.getAmountMax() != null) {
            this.maxAmount = transactionSearchLookupComp.getAmountMax();
        }
        if (transactionSearchLookupComp.getDescription() != null) {
            this.filterDescription = transactionSearchLookupComp.getDescription();
        }
        this.setDisplayTransactions();
    }

    filterByAmount(min, max) {
        if (this.transactions) {
            for (let trans of this.transactions) {
                if (Math.abs(trans.amount) < min || Math.abs(trans.amount) > max) {
                    trans.isDisabled = true;
                    continue;
                }
            }
        }
    }

    filterByDescription(description) {
        if (this.transactions) {
            for (let trans of this.transactions) {
                if (!trans.longDescription.toLowerCase().includes(description.toLowerCase())) {
                    trans.isDisabled = true;
                    continue;
                }
            }
        }
    }

    handleAccountChange() {
        // Determine who the tax owner for the account and retrieve their information.
        this.taxOwner = {};
        this.accountSelected = false;
        this.error = null;
        let accountLookupComp = this.template.querySelector('c-crm-account-lookup');
        this.account = accountLookupComp.getSelectedAccount();
        if (this.account) {
            this.isLoading = true;
            for (let owner of this.account.jointOwners) {
                if (owner.roleCode === 'TAX' && owner.contactId) {
                    this.getContact(owner.contactId, true);
                    this.accountSelected = true;
                    this.getTransactions(this.contactid, this.account.accountNumber, this.startDate, this.endDate);
                    break;
                }
            }
        }
        if (this.account != null && !this.accountSelected) {
            this.setError('Unable to find the tax owner of this account in Helix.  Please contact Help Desk.');
        }
    }

    handleTransactionClick(event) {
        let transactionNumber = event.detail.transactionNumber;
        let selected = event.detail.selected;
        if (this.selectedTransactions.length > 0) {
            for (let t of this.selectedTransactions) {
                if (t.transactionNumber == transactionNumber) {
                    if (selected == false) {
                        this.selectedTransactions.splice(this.selectedTransactions.indexOf(t), 1);
                    }
                }
            }
        }
        for (let trans of this.transactions) {
            if (trans.transactionNumber == transactionNumber && selected == true) {
                this.selectedTransactions.push(trans);
                break;
            }
        }
        if (this.selectedTransactions.length > 0) {
            this.disableNext = false;
            this.numberSelectedTransactions = this.selectedTransactions.length;
        } else {
            this.disableNext = true;
            this.numberSelectedTransactions = 0;
        }
    }

    handleReason(event) {
        let value = event.detail.value;
        this.displayCompanyList[0].reason = value;
    }

    handleCompanies() {
        let companies = {};
        for (let trans of this.selectedTransactions) {
            let merchant = trans.shortDescription;
            let merchantCode = trans.shortDescription.substring(0,6);
            if (companies.hasOwnProperty(merchantCode) === false) {
                let formattedTrans = {
                    "date": moment(trans.postDate).format('M/D/YYYY'),
                    "amount": numeral(trans.amount).format('$0,000.00').toString()
                }
                let company = {
                    "name": merchant,
                    "reason": '',
                    "transactions" : [formattedTrans],
                    "merchantCode" : merchantCode
                };
                this.companyList.push(company);
                companies[merchantCode] = company;
            } else {
                let company = companies[merchantCode];
                let formattedTrans = {
                    "date": moment(trans.postDate).format('M/D/YYYY'),
                    "amount": numeral(trans.amount).format('$0,000.00').toString()
                }
                company.transactions.push(formattedTrans);
            }
        }
        this.setDisplayCompanies();
    }

    handleNextButton() {
        this.accountSelected = false;
        this.transactionSelected = true;
        this.hideBack = false;
        this.hideNext = true;
        Promise.all([
            loadScript(this, momentJs),
            loadScript(this, numeralJs)
        ]).then(() => {
            for (let trans of this.selectedTransactions) {
                if (trans.postDate) {
                    trans.postDate = moment(trans.postDate).format('M/D/YYYY');
                }
                if (trans.amount) {
                    trans.amount = numeral(trans.amount).format('$0,000.00');
                }
            }
        });
        this.handleCompanies();
    }

    handleBackButton() {
        this.accountSelected = true;
        this.isLoading = true;
        this.error = null;
        this.transactionSelected = false;
        this.disableNext = true;
        this.hideBack = true;
        this.hideNext = false;
        this.selectedTransactions = [];
        this.numberSelectedTransactions = 0;
        this.companyList = [];
        this.currentCompany = 0;
        this.disableSubmit = true;
        this.minAmount = null;
        this.maxAmount = null;
        this.filterDescription = null;
        this.getTransactions(this.contactid, this.account.accountNumber, null, null);
    }

    submitACHForm() {
        this.error = null;
        this.isSaving = true;

        let reasonComponent = this.template.querySelector('.disputeReason');
        let reasonComponentValid = reasonComponent.checkValidity();
        reasonComponent.showHelpMessageIfInvalid();

        if (!reasonComponentValid) {
            this.setError('Please provide the dispute reason.');
            return;
        }

        if (!this.taxOwner.Name) {
            this.setError('Please provide the members name in Helix.');
            return;
        }
        if (!this.taxOwner.TaxID__c) {
            this.setError('Please provide the members Tax Id number in Helix.');
            return;
        }
        if (!this.taxOwner.Email) {
            this.setError('Please provide the members email address in Helix.');
            return;
        }
        if (!this.taxOwner.MemberNumber__c) {
            this.setError('Member Number was blank.');
            return;
        }
        if (this.companyList.length == 0) {
            this.setError('Selected transactions cannot be 0.');
            return;
        }
        if (!this.account.accountNumber) {
            this.setError('Account number was null.');
            return;
        }

        let taxIdParts = this.taxOwner.TaxID__c.split('-');
        let redactedTaxId = 'XXX-XX-' + (taxIdParts.length === 3 ? taxIdParts[2] : 'XXXX');

        let requestJson = JSON.stringify({
            name: this.taxOwner.Name,
            taxId: redactedTaxId,
            email: this.taxOwner.Email,
            memberNumber: this.taxOwner.MemberNumber__c.toString(),
            accountNumber: this.account.accountNumber.toString(),
            companies: this.companyList
        });

        //let encodedJson = encodeURI(requestJson);
        //encodedJson = encodedJson.replace(/#/g, '%23');

        sendACHDisputeForSignature({ jsonPayload : requestJson }).then(result => {
            let ACHResult = result ? result : {};
            if (!ACHResult.error) {
                this.complete = true;
                this.isSaving = false;
            } else {
                this.setError('Unable to complete ACH form. ' + ACHResult.error);
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

    get showError() {
        return this.error && this.error !== '';
    }

    setError(message) {
        this.error = message;
        this.isLoading = false;
        this.isSaving = false;
        this.showErrorToast();
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