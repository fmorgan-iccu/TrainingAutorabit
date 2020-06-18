import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import backgroundImage from '@salesforce/resourceUrl/AOOpportunityHeader';

const FIELDS = [
    'Opportunity.Name',
    'Opportunity.PromotionCode__c',
    'Opportunity.AOFormUrl__c',
    'Opportunity.avokaApplicationInfoJSON__c',
];

export default class CrmAoOpportunityHeader extends LightningElement {
    abandonedApplication = false;
    backgroundStyle = 'background-image: linear-gradient(115deg, rgba(77, 77, 77, 0.8), rgba(77, 77, 77, 0.8)), url(' + backgroundImage + ');'
    @track defferedAccount;
    @track defferedAccountNumber;
    @track defferedAccountBalance;
    @track isFatalError = false;
    @track fundAlertType = 'success'; // success or error, depending
    @api recordId;
    @track accounts = null;
    @track paymentType = null;
    @track systemInteractionResults = null;
    @track showRegularBanner = false;
    @track wasSuccessfulTransaction = null;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    get opportunityName() {
        return this.opportunity.data.fields.Name.value;
    }

    get promoCode() {
        return this.opportunity.data.fields.PromotionCode__c.value;
    }

    get appLink() {
        return this.opportunity.data.fields.AOFormUrl__c.value;
    }

    //todo: remove this? Or modify it
    get newAccounts() {
        this.getAccounts();
        return this.accounts;
    }

    get shouldShowFundingBanner() {
        this.getAccounts();
        if (this.accounts) {

            if (this.systemInteractionResults.DeferredFundingPrefill) {
                if (this.systemInteractionResults.DeferredFundingPrefill.systemDecision === "REVIEW") {
                    this.deferredFundingBanner();
                    return true;
                }
            }

            if (this.wasSuccessfulTransaction != null) {
                this.showRegularBanner = true;
                return true;
            } else {
                return false;
            }

        } else {
            return false;
        }
    }

    deferredFundingBanner() {
        this.defferedAccount = this.accounts[0].name;
        this.defferedAccountBalance = this.accounts[0].availableBalance;
        this.defferedAccountNumber = this.accounts[0].accountNumber;
        this.defferedFunding = true;
        if (this.accounts.length > 1) {
            this.accounts.shift();
            this.showRegularBanner = true;
        } else {
            this.showRegularBanner = false;
        }
    }

    getAccounts() {
        let appInfo = JSON.parse(this.opportunity.data.fields.avokaApplicationInfoJSON__c.value);

        this.wasSuccessfulTransaction = appInfo.successfullyTransferedFunds;
        this.fundAlertType = (this.wasSuccessfulTransaction ? 'success' : 'error');

        this.paymentType = appInfo.paymentType;
        this.systemInteractionResults = appInfo.systemInteractionResults;

        let newAccounts = appInfo.newAccounts;
        if (newAccounts) {
            this.accounts = newAccounts;
        }

        this.isFatalError = appInfo.isFatalError;
        if (!this.isFatalError) { // Backwards compatibility...
            this.isFatalError = false;
        }
    }

}