import { LightningElement, api, track } from 'lwc';

import getMemberAccountsList from '@salesforce/apex/MemberAccountsController.getMemberAccountsList';

export default class CrmAccountLookup extends LightningElement {
    accounts = [];
    @track accountSelected = true;
    @api contactId = null;
    @track displayAccounts = [];  // Contains the filtered accounts to display
    @track error = null;
    @track selectedAccount = null;
    @track showAccountList = false;
    @api isDisabled;

    connectedCallback() {
        getMemberAccountsList({ contactId: this.contactId }).then(result => {
            this.error = result.error;
            if (result.accounts) {
                this.accounts = result.accounts;
                this.setAccountIconAndNames();
                this.filterAccounts();
            }
        }).catch(error => {
            if (error.body) {
                this.error = error.body.message;
            } else {
                this.error = 'An unknown error occurred while trying to get the member\'s accounts.';
            }
        });
    }

    filterAccounts(filterBy) {
        if (!filterBy || filterBy === '') {
            filterBy = null;
        }
        // Creates a new array so that the @track on this field will trigger a refresh.
        this.displayAccounts = [];
        for (let a of this.accounts) {
            if (filterBy == null ||
                (a.nickName && a.nickName.includes(filterBy)) ||
                (a.name && a.name.includes(filterBy)))
            {
                this.displayAccounts.push(a);
            }
        }
    }

    @api getSelectedAccountNumber() {
        let accountNumber = this.selectedAccount && this.selectedAccount.accountNumber ? this.selectedAccount.accountNumber : null;
        return accountNumber;
    }

    handleFilterAccounts(event) {
        let filterBy = event.target.value;
        if (filterBy) {
            this.filterAccounts(filterBy);
        }
        this.showAccountList = true;
    }

    handleHideAccounts() {
        this.showAccountList = false;
    }

    handleClearAccount() {
        this.selectedAccount = null;
        this.dispatchEvent(new CustomEvent('change', { detail: null }));
    }

    handleSelectAccount(event) {
        let el = event.target;
        if (!el.getAttribute('data-account-number')) {
            el = event.target.closest('div[data-account-number]');
        }
        let accountNumber = el.getAttribute('data-account-number');
        for (let a of this.accounts) {
            if (a.accountNumber === accountNumber) {
                this.selectedAccount = a;
                this.showAccountList = false;
                this.dispatchEvent(new CustomEvent('change', { detail: a.accountNumber }));
                break;
            }
        }
    }

    setAccountIconAndNames() {
        for (let a of this.accounts) {
            a.displayName = a.nickName ? a.nickName : a.name;

            switch (a.majorType) {
                case 'MTG': // Mortgage
                    a.icon = 'custom:custom107'; // home icon
                    break;
                case 'CK': // Checking
                case 'SAV': // Savings
                    a.icon = 'cusotm:custom17'; // money bag icon
                    break;
                default:
                    switch(a.minorType) {  
                        case 107: //new auto
                        case 137: //auto
                        case 139: //used auto
                        case 154: //auto loan credit rebuilder
                            a.icon = 'custom:custom31'; // auto icon
                            break;
                        case 113: //motorcycle
                        case 109: //Recreational Vehicle - large
                        case 110: //Recreational Vehicle - small
                            a.icon = 'custom:custom80'; // motorcycle icon
                            break;
                        case 119: //Visa fixed rate platinum
                        case 122: //Credit Builder Visa
                        case 134: //Premier Rewards Visa
                        case 135: //Rewards Visa
                        case 136: //Variable Rate Platinum Visa
                            a.icon = 'custom:custom40'; // card icon
                            break;
                        default: //Default
                            a.icon = 'custom:custom40'; // bank icon
                    }
                    break;
            }
        }
    }

    get showSelectedAccount() {
        return this.selectedAccount != null;
    }

}