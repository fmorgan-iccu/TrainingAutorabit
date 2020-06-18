import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import momentJs from '@salesforce/resourceUrl/MomentJS';
import numeralJs from '@salesforce/resourceUrl/NumeralJS';


export default class CrmTransactionDetail extends LightningElement {

    @api transaction = {};

    @track amount = null;
    @track balance = null;
    @track balanceSign = null;
    @track creditDebitHeader = null;
    @api disabled;
    @api hide;
    @track postDate = null;
    @track selected = false;
    @api selectedui = 'compact'; //note this will accept two types of ui options: 'compact' and 'normal' with compact as the default
    @track transactionDetailView = false;

    connectedCallback() {
        if (this.transaction) {
            // Initialize values used to render the transaction.
            this.creditDebitHeader = this.transaction.isCredit ? 'Credit' : 'Debit';
            this.balanceSign = this.transaction.balance < 0 ? 'negative' : 'positive';
            this.selected = this.transaction.hasOwnProperty('selected') ? this.transaction.selected : false;
            this.transactionDetailView = this.transaction.hasOwnProperty('transactionDetailView') ? this.transaction.transactionDetailView : false;
            Promise.all([
                loadScript(this, momentJs),
                loadScript(this, numeralJs)
            ]).then(() => {
                if (this.transaction.postDate) {
                    this.postDate = moment(this.transaction.postDate).format('M/D/YYYY');
                }
                if (this.transaction.amount) {
                    this.amount = numeral(this.transaction.amount).format('$0,000.00');
                }
                if (this.transaction.balance) {
                    this.balance = numeral(this.transaction.balance).format('$0,000.00');
                }
            });
        }
    }

    handleClicked() {
        if (this.disabled) {
            return;
        }
        this.selected = !this.selected;
        if (this.selectedui === 'compact') {
            this.transactionDetailView = this.selected;
        }
        this.dispatchEvent(new CustomEvent('transactionclick', {
            detail: {
                transactionNumber: this.transaction.transactionNumber,
                selected: this.selected
            }
        }));
    }

    get transactionAmountClasses() {
        return this.creditDebitHeader + ' amount';
    }

    get transactionAmountClasses2() {
        return this.creditDebitHeader + '-section';
    }

    get transactionBalanceClasses() {
        return this.balanceSign + ' balanceInfo TransactionHeader';
    }

    get transactionBalanceClasses2() {
        return this.balanceSign + ' balance';
    }

    get transactionWrapperClasses() {
        if (this.disabled) {
            return 'transactLayerOne BorderTop disabled ' + this.balanceSign;
        } else if (this.hide) {
            return 'transactLayerOne BorderTop hide';
        }else {
            return 'transactLayerOne BorderTop ' + this.balanceSign + ' ' + this.selectedui + '-selected-' + this.selected;
        }
    }

}