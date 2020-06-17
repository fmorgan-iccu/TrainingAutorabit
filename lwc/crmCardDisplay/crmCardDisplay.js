import { LightningElement, api } from 'lwc';
import { CARD_STATUS_FROZEN, CARD_TYPE_DEBIT, getCardStatusGroup, getCardTypeGroup } from 'c/crmCardUtils';

export default class CrmCardDisplay extends LightningElement {
    @api card = {};
    @api selected = false;

    obscuredPan = 'XXXX';

    get cardHolderName() {
        if (this.card.nameOnCard) {
            return this.card.nameOnCard;
        }
        return '????';
    }

    get cardStyle() {
        let cardStyling = getCardTypeGroup(this.card.typeCode);
        if (getCardStatusGroup(this.card.status) === CARD_STATUS_FROZEN) {
            cardStyling = CARD_STATUS_FROZEN;
        }
        return cardStyling;
    }

    get cardType() {
        return (getCardTypeGroup(this.card.typeCode) === CARD_TYPE_DEBIT ? 'Debit' : 'Credit');
    }

    @api getCard() {
        return this.card;
    }

    @api isSelected() {
        return this.selected;
    }

    get lastFour() {
        if (this.card.cardNumber && this.card.cardNumber.length > 4) {
            return this.card.cardNumber.slice(-4);
        }
        return this.obscuredPan;
    }

    toggleCardSelection() {
        // Conditionally shows the visual feedback that the user has selected a card.
        if (this.selected) {
            this.selected = false;
            this.dispatchEvent(new CustomEvent('deselected'));
        } else {
            this.selected = true;
            this.dispatchEvent(new CustomEvent('selected'));
        }
    }
}