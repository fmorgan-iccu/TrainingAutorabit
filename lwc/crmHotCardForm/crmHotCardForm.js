import { LightningElement, track, api} from 'lwc';
import { CARD_STATUS_CANCELLED, getCardStatusGroup } from 'c/crmCardUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import updateCardStatuses from '@salesforce/apex/MemberCardController.updateCardStatuses'
import fetchCardData from '@salesforce/apex/MemberCardController.fetchCardData';

export default class CrmHotCardForm extends LightningElement {
    @track actionHeadline = '';
    cards = [];
    displayCards = [];
    @track contact = {};
    @api contactid = null;
    @track error = null;
    @track errorOnSubmit = null;
    @track isDisabled = false;
    @track isLoaded = false;
    @track warning = null;

    // Hides/shows the card-specific UI
    @track hasSelectedCard = false;

    // Controls if any changes can be performed on the card
    @track canChangeCard = false;

    // Vars related to change reasons
    @track selectedReason;
    @track changeReasonsOptions = [];
    @track showChangeReasonOptions = false;
    @track changeReasonText = '';

    // Vars related to changing statuses
    @track currentStatus = '';
    @track selectedStatus;
    @track applicableStatuses = [];

    checkAuthenticationRequired(requiredSystem) {
        // If authentication is required, dispatch the necessary events for the login
        // component to be displayed.
        if (requiredSystem === 'DNA') {
            let systems = ['cCRMDnaLogin'];
            const requireLoginEvent = new CustomEvent('requirelogin', {
                detail: { systems },
            });
            this.dispatchEvent(requireLoginEvent);
        }
        if (requiredSystem === 'CCM') {
            let systems = ['cCRMCcmLogin'];
            const requireLoginEvent = new CustomEvent('requirelogin', {
                detail: { systems },
            });
            this.dispatchEvent(requireLoginEvent);
        }
    }

    connectedCallback() {
        this.getCardData();
    }

    get currentStatusPill() {
        return 'This card is: ' + this.currentStatus;
    }

    filterCards(accountNumber) {
        // Has the effect of showing all cards because we don't have an account number
        if (!accountNumber || accountNumber === '') {
            accountNumber = null;
        }

        // Show all cards
        if (accountNumber == null) {
            this.displayCards = this.cards;
            return;
        }

        this.displayCards = this.cards.filter( card => {
            let isMatch = (card.accountNumber && card.accountNumber === accountNumber);
            return isMatch;
        });
    }

    getCardData() {
        this.showSpinner('Loading cards...', false);

        fetchCardData({ contactId: this.contactid }).then(result => {
            this.error = result.error;
            this.warning = result.warning;
            this.contact = result.contact ? result.contact : {};

            this.cards = [];
            if (result.debit && result.credit) {
                for (let card of result.debit) {
                    if (card.uniqueId) {
                        this.cards.push(card);
                    }
                }
                for (let card of result.credit) {
                    if (card.uniqueId) {
                        this.cards.push(card);
                    }
                }
                this.filterCards();
                this.renderCards();
            }

            // Disable the form as necessary.
            if (this.error || this.cards.length === 0) {
                this.isDisabled = true;
            }

            this.checkAuthenticationRequired(result.authRequired);
        }).catch(error => {
            if (error.body) {
                this.error = error.body.message;
            } else if (error.message) {
                this.error = error.message;
            } else {
                this.error = 'An unknown error occurred while trying to retrieve the contacts cards.';
            }
        })
        .finally(() => {
            this.showSpinner('', true);
        });
    }

    getSelectedCard() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent) {
            let card = cardSelectComponent.getSelectedCard();
            return card;
        }

        return null;
    }

    handleAccountChange(event) {
        let accountNumber = event.detail;
        this.filterCards(accountNumber);
        this.renderCards();
    }

    // Resets the state of card selection and updates the various vars to update the UI.
    handleCardSelect() {
        let card = this.getSelectedCard();
        let changeReasonsOptions = [];
        let applicableStatuses = [];
        let canChangeCard = false;
        let currenCardStatus = '';
        let hasSelectedCard = false;

        if (card) {
            hasSelectedCard = true;
            changeReasonsOptions = card.applicableChangeReasons.map(reason => {
                return {
                    label: reason.displayValue,
                    value: reason.code
                };
            });

            applicableStatuses = card.applicableStatuses.map(status => {
                return {
                    label: status.displayValue,
                    value: status.code
                };
            });

            canChangeCard = card.canChangeStatus;
            currenCardStatus = card.userFriendlyStatus;
        }

        this.hasSelectedCard = hasSelectedCard;

        this.showChangeReasonOptions = changeReasonsOptions.length > 0;
        this.changeReasonsOptions = changeReasonsOptions;
        this.selectedReason = null;
        this.changeReasonText = '';

        this.applicableStatuses = applicableStatuses;
        this.selectedStatus = null;

        this.canChangeCard = canChangeCard;

        this.currentStatus = currenCardStatus;
    }

    get contentContainer() {
        return this.isLoaded ? '' : 'display:none';
    }

    handleSubmitForm() {
        this.error = null;
        this.errorOnSubmit = null;

        // Create a copy of the card; DO NOT alter the existing one.
        let card = JSON.parse(JSON.stringify(this.getSelectedCard()));
        card.status = this.selectedStatus;
        card.changeReason = this.changeReasonText;
        card.changeReasonCode = this.selectedReason;

        let cards = [card];

        let requestJSON = JSON.stringify(cards);

        let request = {
            contactId: this.contactid,
            requestJSON: requestJSON
        };

        this.showSpinner('Changing card status...', false);

        updateCardStatuses(request)
            .then(response => {
                if (response.error) {
                    this.errorOnSubmit = response.error;
                    this.showErrorToast();
                    return;
                }

                let successMessage = 'Form for card ' +  card.cardNumber + ' submitted successfully!';

                // We're done. Close the card.
                this.cancelAction();
                this.getCardData();
                this.showSuccessToast(successMessage);
            })
            .catch(err => {
                this.errorOnSubmit = JSON.stringify(err);
                this.showErrorToast();
            })
            .finally(() => {
                this.showSpinner('', true);
            });
    }

    renderCards() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent && this.displayCards) {
            cardSelectComponent.setCards(this.displayCards);
        }
    }

    cancelAction() {
        let cardSelectComponent = this.template.querySelector('c-crm-card-select');
        if (cardSelectComponent) {
            cardSelectComponent.handleDeselectCard();
        }
    }

    statusDidChange(event) {
        this.selectedStatus = event.detail.value;
    }

    reasonDidChange(event) {
        this.selectedReason = event.detail.value;
    }

    reasonTextDidChange(event) {
        this.changeReasonText = event.detail.value;
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
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

    showSpinner(message, hidden) {
        this.isLoaded = hidden;

        let spinner = this.template.querySelector('c-crm-lwc-loading-spinner');
        if (spinner) {
            spinner.message = message;
        }
    }

    get showWarning() {
        return this.warning && this.warning !== '';
    }

}