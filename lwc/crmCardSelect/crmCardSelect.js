import { LightningElement, api, track } from 'lwc';
import { CARD_TYPE_CREDIT, CARD_TYPE_DEBIT } from 'c/crmCardUtils';

// Constants used by this class
const GROUP_BY_NONE = 'none';
const GROUP_BY_STATUS = 'status';
const GROUP_BY_TYPE = 'type';

const ALL_CARDS = 'all';

export default class CrmCardSelect extends LightningElement {
    cards = null;
    @track cardGroups = [];
    @api groupBy = GROUP_BY_NONE;
    @track selectedCard = null;

    connectedCallback() {
        // Ensure that the groupBy value conforms with the expected values, and if not, set it to none.
        if (this.groupBy !== GROUP_BY_NONE && this.groupBy !== GROUP_BY_STATUS && this.groupBy !== GROUP_BY_TYPE) {
            this.groupBy = GROUP_BY_NONE;
        }
    }

    @api checkValidity() {
        return this.selectedCard !== null;
    }

    @api getSelectedCard() {
        return this.selectedCard;
    }

    // Updates the selected card and shows all of the cards.
    @api handleDeselectCard() {
        this.selectedCard = null;
        this.dispatchEvent(new CustomEvent('change'));
    }

    // Updates the selected card and hides all of the others.
    handleSelectCard() {
        this.selectedCard = null;
        let cardComponents = this.template.querySelectorAll('c-crm-card-display');
        for (let cardComponent of cardComponents) {
            if (cardComponent.isSelected()) {
                let card = cardComponent.getCard();
                this.selectedCard = card;
                this.dispatchEvent(new CustomEvent('change'));
            }
        }
    }

    get showGroupLabel() {
        return this.groupBy !== GROUP_BY_NONE;
    }

    @api showHelpMessageIfInvalid() {
        return null; // Provided for consistency of validation; effectively a no-op.
    }

    get showNoCardsToDisplay() {
        return !(this.cards) || this.cards.length === 0;
    }

    get showSelectedCard() {
        return this.selectedCard !== null;
    }

    sortByCardNumber(cardA, cardB) {
        return cardA.cardNumber.localeCompare(cardB.cardNumber);
    }

    @api setCards(cards) {
        // Sanity check
        if (cards === null) {
            return;
        }

        this.handleDeselectCard();

        this.cards = cards;
        this.cards.sort(this.sortByCardNumber);

        // Determine the appropriate display groups that will be needed.
        let groups = {};
        switch (this.groupBy) {
            case GROUP_BY_STATUS:
                break;
            case GROUP_BY_TYPE:
                groups[CARD_TYPE_DEBIT] = [];
                groups[CARD_TYPE_CREDIT] = [];
                break;
            default:
                groups[ALL_CARDS] = [];
                break;
        }
        for (let card of this.cards) {
            let key = this.groupBy === GROUP_BY_STATUS ? 'userFriendlyStatus' : 'typeCode';
            let keyValue = card[key];

            // The back-end controller doesn't always return all values.
            if (typeof keyValue === 'undefined') {
                keyValue = '';
            }

            // The key values must mapped to the appropriate group/bucket for display.
            let bucket = null;
            switch (this.groupBy) {
                case GROUP_BY_STATUS:
                    bucket = card.userFriendlyStatus;

                    if (!groups[bucket]) {
                        groups[bucket] = [];
                    }
                    break;
                case GROUP_BY_TYPE:
                    bucket = card.displayType;
                    break;
                default:
                    bucket = ALL_CARDS;
            }

            groups[bucket].push(card);
        }

        // Finally update the cardGroups structure with the grouped information in the order that
        // they should be displayed.
        this.cardGroups = [];
        switch (this.groupBy) {
            case GROUP_BY_STATUS:
                {
                    // Sort the returned user friendly group names alphabetically.
                    let keys = Object.keys(groups);
                    keys.sort();

                    // The following preferred group order will only be used if the names returned
                    // by the backend match!  However, only thos friendly names that are provided
                    // will be displayed.
                    let preferredKeyOrder = ['ON','Waiting Activation','OFF'];
                    let allKeysFound = true;
                    for (let key of keys) {
                        allKeysFound = allKeysFound && preferredKeyOrder.includes(key);
                    }
                    if (allKeysFound) {
                        keys = preferredKeyOrder.filter(key => {
                            return keys.includes(key);
                        });
                    }

                    // Update the card groups for display.
                    keys.forEach(key => {
                        this.cardGroups.push({
                            'cards': groups[key],
                            'label': key
                        })
                    });
                }
                break;
            case GROUP_BY_TYPE:
                if (groups[CARD_TYPE_DEBIT].length > 0) {
                    this.cardGroups.push({
                        'cards': groups[CARD_TYPE_DEBIT],
                        'label': 'Debit'
                    });
                }
                if (groups[CARD_TYPE_CREDIT].length > 0) {
                    this.cardGroups.push({
                        'cards': groups[CARD_TYPE_CREDIT],
                        'label': 'Credit'
                    });
                }
                break;
            default:
                if (groups[ALL_CARDS].length > 0) {
                    this.cardGroups.push({
                        'cards': groups[ALL_CARDS],
                        'label': 'All Cards'
                    });
                }
                break;
        }
    }
}