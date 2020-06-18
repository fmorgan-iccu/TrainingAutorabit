import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CARD_STATUS_ACTIVE, getCardStatusGroup } from 'c/crmCardUtils';

import fetchCardData from '@salesforce/apex/MemberCardController.fetchCardData';
import updateTravelNotifications from '@salesforce/apex/MemberCardController.updateTravelNotifications'

export default class CRMTravelForm extends LightningElement {
    cards = [];
    contact = {};
    displayCards = [];
    @api contactid = null;
    @track complete = false;
    @track error = '';
    @track errorOnSubmit = '';
    @track isDisabled = false; // This is the value that changes the input fields to disabled
    @track isLoaded = false;
    @track isSaving = false;
    stateRequired = true;
    @track travelOption = 'usa-travel';
    @track warning = null;

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

    filterCards() {
        this.displayCards = this.cards.filter( card => {
            let isMatch = card.status && getCardStatusGroup(card.status) === CARD_STATUS_ACTIVE;
            return isMatch;
        });
    }

    getCardData() {
        fetchCardData({ contactId: this.contactid }).then(result => {
            this.error = result.error;
            this.warning = result.warning;
            this.contact = result.contact ? result.contact : {};

            if (!this.contact.Phone  && !this.error) {
                this.error = 'A phone number is required to submit this form. Update the member’s phone number and reload this form.';
                this.isDisabled = true;
            }
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

                let cardSelectComponent = this.template.querySelector('c-crm-card-select');
                cardSelectComponent.setCards(this.displayCards);
            }

            // Disable the form as necessary.
            if (this.error || this.displayCards.length === 0) {
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

            this.isDisabled = true;
        }).finally(() => {
            this.isLoaded = true;
        });
    }

    handleDateChange(event) {
        let today = new Date();
        today = today.toISOString().split('T')[0];
        today = Date.parse(today);

        let departureDateComp = this.template.querySelector('.departure');
        let departureDateStr = departureDateComp.value;
        let departureDate = departureDateStr !== '' ? Date.parse(departureDateStr) : null;

        let returnDateComp = this.template.querySelector('.return');
        let returnDateStr = returnDateComp.value;
        let returnDate = returnDateStr !== '' ? Date.parse(returnDateStr) : null;

        // Clear any prior custom validation messages.
        departureDateComp.setCustomValidity('');
        returnDateComp.setCustomValidity('');

        // Verify the dates are not in the past
        if (departureDate && departureDate < today) {
            departureDateComp.setCustomValidity('Can\'t be in the past');
        }
        if (returnDate && returnDate < today) {
            returnDateComp.setCustomValidity('Can\'t be in the past');
        }

        // Verify that the start date is on or before the return date.
        if (departureDate && returnDate && departureDate > returnDate) {
            returnDateComp.setCustomValidity('Must be on or after the departure date')
        }

        if (departureDate) {
            departureDateComp.showHelpMessageIfInvalid();
        }
        if (returnDate) {
            returnDateComp.showHelpMessageIfInvalid();
        }
    }

    // This is an event handler to handle the change of value based on the user's selection of travel.
    handleTravelChange(event) {
        this.travelOption = event.target.value;

        let countryComponent = this.template.querySelector('c-crm-country-select');
        let stateComponent = this.template.querySelector('c-crm-state-select');
        if (this.travelOption === 'usa-travel') {
            countryComponent.setRequired(false);
            stateComponent.setRequired(true);
        } else {
            countryComponent.setRequired(true);
            stateComponent.setRequired(false);
        }
    }

    handleSubmitForm() {
        this.error = '';
        this.errorOnSubmit = '';

        let cardSelect = this.template.querySelector('c-crm-card-select');
        let cardValid = cardSelect.checkValidity();
        let card = cardSelect.getSelectedCard();

        let departureComponent = this.template.querySelector('.departure');
        let departureValid = departureComponent.checkValidity();
        departureComponent.showHelpMessageIfInvalid();
        let departureDate = departureComponent.value;

        let returnComponent = this.template.querySelector('.return');
        let returnValid = returnComponent.checkValidity();
        returnComponent.showHelpMessageIfInvalid();
        let returnDate = returnComponent.value;

        let stateComponent = this.template.querySelector('c-crm-state-select');
        let stateValid = stateComponent.checkValidity();
        stateComponent.showHelpMessageIfInvalid();
        let selectedStateCodes = stateComponent.getSelectedStateCodes();

        let countryComponent = this.template.querySelector('c-crm-country-select');
        let countryValid = countryComponent.checkValidity();
        countryComponent.showHelpMessageIfInvalid();
        let selectedCountryCodes = countryComponent.getSelectedCountryCodes();

        let noteComponent = this.template.querySelector('.note');
        let note = noteComponent.value;

        if (!cardValid || !departureValid || !returnValid || !stateValid || !countryValid) {
            this.errorOnSubmit = 'Provide all of the required fields.';
            this.showErrorToast();
            return;
        }

        let request = [{
            countryCodes: selectedCountryCodes,
            firstName: card.firstName,
            fromDate: departureDate,
            lastName: card.lastName,
            note: note,
            phone: card.phone,
            providerName: card.providerName,
            stateCodes: selectedStateCodes,
            toDate: returnDate,
            uniqueId: card.uniqueId
        }];
        request = JSON.stringify(request);

        this.isSaving = true;
        updateTravelNotifications({ contactId: this.contactid, requestJSON: request }).then(result => {
            if (result.hasOwnProperty('error')) {
                this.errorOnSubmit = result.error;
                this.checkAuthenticationRequired(result.authRequired);
                return;
            } else if (!result.hasOwnProperty('success')) {
                this.errorOnSubmit = 'Unexpected response.';
                return;
            }
            this.error = '';
            this.complete = result.success;

            // Adding the toast events once a submission has occured.
            if (this.complete){
                this.showSuccessToast();
            } else if (this.errorOnSubmit) {
                this.showErrorToast();
            }
        }).catch(error => {
            if (error.body) {
                this.errorOnSubmit = error.body.message;
            } else if (error.message) {
                this.errorOnSubmit = error.message;
            } else {
                this.errorOnSubmit = 'An unknown error occurred while trying to retrieve the contacts cards.';
            }
        }).finally(() => {
            this.isSaving = false;
        });
    }

    get contentContainer() {
        return this.isLoaded ? '' : 'display:none';
    }

    // Used to conditionally show the international travel section if true
    get showCountry() {
        var displayMode = this.travelOption === 'international-travel' ? 'inherit' : 'none';
        return 'display:' + displayMode;
    }

    get showDisabled() {
        return this.isDisabled;
    }

    get showError() {
        return this.error && this.error !== '';
    }

    get showErrorOnSubmit() {
        return this.errorOnSubmit && this.errorOnSubmit !== '';
    }

    get showWarning() {
        return this.warning && this.warning !== '';
    }

    // Showing the travel options for the radio button selection
    get travelOptions() {
        return [
            { label: 'Traveling only in the United States', value: 'usa-travel' },
            { label: 'Traveling Internationally', value: 'international-travel' },
        ];
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
    // Showing a standard Salesforce Toast when an error has occurred on submit.
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Oops! Something went wrong and an error has occured.',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

}