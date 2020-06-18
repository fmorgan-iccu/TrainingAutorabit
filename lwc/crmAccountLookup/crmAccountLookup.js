import { LightningElement, api, track } from 'lwc';

import getMemberAccountsList from '@salesforce/apex/MemberAccountsController.getMemberAccountsList';
import { deepClone } from 'c/crmObjectUtils';

const ACCOUNT_TYPE_AUTO = 'auto';
const ACCOUNT_TYPE_CREDIT_CARD = 'creditcard';
const ACCOUNT_TYPE_DEPOSIT = 'deposit';
const ACCOUNT_TYPE_MORTGAGE = 'mortgage';

const OWNER_TYPE_OTAX = 'OTAX';
const OWNER_TYPE_OWN = 'OWN';

export default class CrmAccountLookup extends LightningElement {
    accounts = [];
    @track accountSelected = true;
    @api contactId = null;
    @track displayAccounts = [];  // Contains the filtered accounts to display
    @track error = null;
    @api filterByType = null; // Supports Auto, CreditCard, Deposit, Mortgage (see const)
    @api filterByOwnerId = null;
    @track selectedAccount = null;
    @api isDisabled;
    @api filterByGap = null;
    @api filterByFirstPayment = null;
    @api filterByVisaDispute = null;

    connectedCallback() {
        // Verify that the filter by type is a valid type.  If it isn't, reset back to the
        // default of all.
        if (this.filterByType !== ACCOUNT_TYPE_AUTO &&
            this.filterByType !== ACCOUNT_TYPE_CREDIT_CARD &&
            this.filterByType !== ACCOUNT_TYPE_DEPOSIT &&
            this.filterByType !== ACCOUNT_TYPE_MORTGAGE)
        {
            this.filterByType = null;
        }

        // Get all of the accounts for the provided contact.
        this.getAccounts();
    }

    filterAccounts(filterBy) {
        if (!filterBy || filterBy === '') {
            filterBy = null;
        }
        // Creates a new array so that the @track on this field will trigger a refresh.
        this.displayAccounts = [];
        for (let a of this.accounts) {
            let matchesFilterBy = filterBy == null || (a.nickName && a.nickName.includes(filterBy)) || (a.name && a.name.includes(filterBy));
            let matchesFilterByType = this.filterByType == null || this.filterByType === a.accountType;
            let matchesFilterByGap = this.filterByGap == null || (a.activeGapPolicy && !a.cancelledGapPolicy);
            let matchesFilterByFirstPayment = this.filterByFirstPayment == null || a.firstPaymentMade;

            let matchesFilterByVisaDispute = false;
            if (this.filterByVisaDispute !== null) {
                matchesFilterByVisaDispute = (a.nickName && a.nickName.toLowerCase().includes('checking')) || (a.name && a.name.toLowerCase().includes('checking')) || (a.nickName && a.nickName.toLowerCase().includes('heloc')) || (a.name && a.name.toLowerCase().includes('heloc')) || 'creditcard' === a.accountType;
            } else {
                matchesFilterByVisaDispute = true;
            }
            // Ensure that the provided filter by owner ID has a tax owner or non-tax owner roll on the account.
            let matchesFilterByOwnerId = false;

            if (this.filterByOwnerId !== null) {
                for (let i in a.jointOwners) {
                    let jointOwner = a.jointOwners[i];
                    if (jointOwner.contactId === this.filterByOwnerId && (jointOwner.roleCode === OWNER_TYPE_OTAX || jointOwner.roleCode === OWNER_TYPE_OWN)) {
                        matchesFilterByOwnerId = true;
                        break;
                    }
                }
            } else {
                matchesFilterByOwnerId = true;
            }

            if (matchesFilterBy && matchesFilterByType && matchesFilterByOwnerId && matchesFilterByGap && matchesFilterByFirstPayment && matchesFilterByVisaDispute) {
                this.displayAccounts.push(a);
            }
        }
    }

    @api getSelectedAccount() {
        return this.selectedAccount;
    }

    getAccounts() {
        getMemberAccountsList({ contactId: this.contactId }).then(result => {
            if (result.error && result.error !== '') {
                this.setError(result.error);
            }
            if (result.accounts) {
                this.accounts = deepClone(result.accounts);
                this.setAccountNames();
                this.filterAccounts();
            }
            this.dispatchEvent(new CustomEvent('load', { detail: true }));
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else {
                this.setError('An unknown error occurred while trying to get the member\'s accounts.');
            }
            this.dispatchEvent(new CustomEvent('load', { detail: false }));
        });
    }

    handleClearAccount() {
        this.selectedAccount = null;
        this.dispatchEvent(new CustomEvent('change', { detail: null }));
    }

    handleSelectAccount(event) {
        let el = event.target;
        let accountNumber = null;
        while (el != null) {
            if (el.hasAttribute('data-account-number')) {
                accountNumber = el.getAttribute('data-account-number');
                break;
            }
            el = el.parentElement;
        }
        if (accountNumber !== null) {
            for (let a of this.accounts) {
                if (a.accountNumber === accountNumber) {
                    this.selectedAccount = a;
                    this.dispatchEvent(new CustomEvent('change', { detail: a.accountNumber }));
                    break;
                }
            }
        } else {
            this.setError('Unable to find the account number for the selected account.');
        }
    }

    setAccountNames() {
        for (let a of this.accounts) {
            a.displayName = a.nickName ? a.nickName : a.name;
        }
    }

    setError(message) {
        this.error = message;
        this.dispatchEvent(new CustomEvent('error', { detail: message }));
    }

    get showAccountList() {
        return this.displayAccounts.length > 0;
    }

    get showSelectedAccount() {
        return this.selectedAccount != null;
    }

    get filterByAuto() {
        return this.filterByType === 'auto';
    }

}