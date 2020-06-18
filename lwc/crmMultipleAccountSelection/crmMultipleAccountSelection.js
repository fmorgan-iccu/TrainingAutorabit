import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import momentJs from '@salesforce/resourceUrl/MomentJS';
import getMemberAccountsList from '@salesforce/apex/MemberAccountsController.getMemberAccountsList';
import getAccount from '@salesforce/apex/MemberAccountsController.getAccount';
import { deepClone } from 'c/crmObjectUtils';

const OWNER_TYPE_OTAX = 'OTAX';
const OWNER_TYPE_OWN = 'OWN';
const ACCOUNT_TYPE_AUTO = 'auto';
const ACCOUNT_TYPE_CREDIT_CARD = 'creditcard';
const ACCOUNT_TYPE_SIGNATURE = 'signature';

export default class CrmMultipleAccountSelection extends LightningElement {
    accounts = [];
    @track accountSelected = true;
    @api contactId = null;
    @track displayAccounts = [];  // Contains the filtered accounts to display
    @track filteredAccounts = [];
    @api selectedAccounts = [];
    @track error = null;
    @api filterByOwnerId = null;
    @api isDisabled = false;
    @track selectedAccountCount = 0;
    @track showSelectedAccounts = false;

    connectedCallback() {
        // Get all of the accounts for the provided contact.
        this.getAccounts();
        loadScript(this, momentJs);
    }

    getAccounts() {
        getMemberAccountsList({ contactId: this.contactId }).then(result => {
            if (result.error && result.error !== '') {
                this.setError(result.error);
            }
            if (result.accounts) {
                this.accounts = deepClone(result.accounts);
                this.filterAccounts();
                if (this.filteredAccounts.length == 0) {
                    this.dispatchEvent(new CustomEvent('load', { detail: false }));
                    this.setError('No eligible accounts found.')
                }
                for(let acc of this.filteredAccounts) {
                    this.getAccountSkipEligibility(acc.accountNumber);
                }
            } else {
                this.dispatchEvent(new CustomEvent('load', { detail: false }));
            }
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else {
                this.setError('An unknown error occurred while trying to get the member\'s accounts.');
            }
            this.dispatchEvent(new CustomEvent('load', { detail: false }));
        });
    }

    getAccountSkipEligibility(accountNumber) {
        getAccount({ accountNumber: accountNumber }).then(result => {
            if (result.error) {
                this.setError('Unable to retrieve Skip a Pay eligibility for accounts.');
                this.isDisabled = true;
                return;
            }
            if (result.account) {
                let skipAccount = result.account;
                skipAccount.accountContainerClasses = 'flex selectable-account';
                if (skipAccount.canSkipPayment == true) {
                    skipAccount.displayName = skipAccount.nickName ? skipAccount.nickName : skipAccount.name;
                    skipAccount.eligible = "Eligible";
                    skipAccount.selectedAccountEligible = true;
                    skipAccount.nextPaymentDateDay = moment(skipAccount.nextPaymentDate).format('D');
                    skipAccount.nextPaymentDateDayForDisplay = moment(skipAccount.nextPaymentDate).format('Do');
                } else {
                    skipAccount.displayName = skipAccount.nickName ? skipAccount.nickName : skipAccount.name;
                    skipAccount.eligible = "Requires MAD Approval"
                    skipAccount.selectedAccountEligible = false;
                    skipAccount.nextPaymentDateDay = moment(skipAccount.nextPaymentDate).format('D');
                    skipAccount.nextPaymentDateDayForDisplay = moment(skipAccount.nextPaymentDate).format('Do');
                }
                this.displayAccounts.push(skipAccount);
            }
            this.dispatchEvent(new CustomEvent('load', { detail: false }));
        }).catch(error => {
            if (error.body) {
                this.setError(error.body.message);
            } else if (error.message) {
                this.setError(error.message);
            } else {
                this.setError('An unknown error occurred while trying to retrieve the payoff amount.');
            }
            this.dispatchEvent(new CustomEvent('load', { detail: false }));
            this.isDisabled = true;
        });
    }

    filterAccounts() {
        // Creates a new array so that the @track on this field will trigger a refresh.
        this.filteredAccounts = [];
            for (let a of this.accounts) {
                if (a.accountType === ACCOUNT_TYPE_AUTO || a.accountType === ACCOUNT_TYPE_CREDIT_CARD || a.accountType === ACCOUNT_TYPE_SIGNATURE) {
                // Ensure that the provided filter by owner ID has a tax owner or non-tax owner roll on the account.
                    for (let i in a.jointOwners) {
                       let jointOwner = a.jointOwners[i];
                       if (jointOwner.contactId === this.filterByOwnerId && (jointOwner.roleCode === OWNER_TYPE_OTAX || jointOwner.roleCode === OWNER_TYPE_OWN)) {
                           this.filteredAccounts.push(a);
                       } else {
                           continue;
                       }
                    }
                }
            }
        }

    @api getSelectedAccounts() {
        return this.selectedAccounts;
    }

    setError(message) {
        this.error = message;
        this.dispatchEvent(new CustomEvent('error', { detail: message }));
    }

    get showNoAccountsMessage() {
        return
    }
    get showAccountList() {
        return this.displayAccounts.length > 0;
    }

    get showSelectedAccounts() {
        return this.showSelectedAccounts;
    }

    selectAccounts() {
        this.showSelectedAccounts = false;
        for (let a of this.displayAccounts) {
            a.selectedAccountEligible = a.canSkipPayment;
        }
        if (this.selectedAccounts.length > 0) {
            this.dispatchEvent(new CustomEvent('continue', { detail: false }));
        } else {
            this.dispatchEvent(new CustomEvent('continue', { detail: true }));
        }
    }

    @api switchViews() {
        this.showSelectedAccounts = true;
    }

    handleAccountClick(event) {
        let accountNumber = null;
        // Identify the Id of the form that was clicked.
        let an = event.target;
        while (an != null) {
            if (an.hasAttribute('data-account-number')) {
                accountNumber = an.getAttribute('data-account-number');
                break;
            }
            an = an.parentElement;
        }
        for (let a of this.displayAccounts) {
            if (a.accountNumber === accountNumber) {
                if (a.canSkipPayment != true) {
                    a.accountIneligibleClasses = 'flex selected-account ineligible';
                } else {
                    a.accountIneligibleClasses = 'flex selected-account';
                }
                if (a.selected == true) {
                    a.selected = false;
                    a.accountContainerClasses = 'flex selectable-account';
                    this.selectedAccounts.splice( this.selectedAccounts.indexOf(a), 1 );
                    this.selectedAccountCount = this.selectedAccountCount - 1;
                } else {
                    a.selected = true;
                    a.accountContainerClasses = 'flex selectable-account selected';
                    this.selectedAccounts.push(a);
                    this.selectedAccountCount = this.selectedAccountCount + 1;
                }
            }
        }
        if (this.selectedAccounts.length == 0) {
            this.showSelectedAccounts = false;
            this.dispatchEvent(new CustomEvent('continue', { detail: true }));
        } else if (this.selectedAccounts.length > 0) {
            this.dispatchEvent(new CustomEvent('continue', { detail: false }));
        } else {
            this.dispatchEvent(new CustomEvent('continue', { detail: true }));
        }
    }

    @api resetAllToEligible() {
        for (let a of this.displayAccounts) {
            a.selectedAccountEligible = true;
            a.accountIneligibleClasses = 'flex selected-account';
        }
    }
}