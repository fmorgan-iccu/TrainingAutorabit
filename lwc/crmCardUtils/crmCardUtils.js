/**
 * Defines constants and Utility methods for working with cards.
 */

const CARD_STATUS_ACTIVE = 'active';
const CARD_STATUS_CANCELLED = 'cancelled';
const CARD_STATUS_FROZEN = 'frozen';

const CARD_TYPE_CREDIT = 'Credit';
const CARD_TYPE_DEBIT = 'Debit';

const STATUS_GROUPS = Object.freeze({
    'ACT': CARD_STATUS_ACTIVE,
    'CLOS': CARD_STATUS_CANCELLED,
    'EXP': CARD_STATUS_CANCELLED,
    'HOT': CARD_STATUS_CANCELLED,
    'INQ': CARD_STATUS_CANCELLED,
    'ISS': CARD_STATUS_FROZEN,
    'LOCK': CARD_STATUS_CANCELLED,
    'LOST': CARD_STATUS_CANCELLED,
    'REST': CARD_STATUS_CANCELLED,
    'WARM': CARD_STATUS_FROZEN,
    'Active': CARD_STATUS_ACTIVE,
    'Closed': CARD_STATUS_CANCELLED,
    'Expired': CARD_STATUS_CANCELLED,
    'Hot Card': CARD_STATUS_CANCELLED,
    'Inquiry Only': CARD_STATUS_CANCELLED,
    'Issued': CARD_STATUS_FROZEN,
    'Lock Out': CARD_STATUS_CANCELLED,
    'Lost': CARD_STATUS_CANCELLED,
    'Restricted': CARD_STATUS_CANCELLED,
    'WarmCard': CARD_STATUS_FROZEN,
    'Fraud': CARD_STATUS_CANCELLED,
    'Inactive': CARD_STATUS_FROZEN,
    'ReportedLost': CARD_STATUS_CANCELLED,
    'ReportedStolen': CARD_STATUS_CANCELLED,
    'Revoked': CARD_STATUS_CANCELLED,
    'Scratched': CARD_STATUS_CANCELLED,
    'SentNotReceived': CARD_STATUS_CANCELLED,
    'WaitingOnActivation': CARD_STATUS_FROZEN
});

/**
 * Give a card status, returns one of the these statuses, CARD_STATUS_ACTIVE,
 * CARD_STATUS_CANCELLED, or CARD_STATUS_FROZEN.
 */
const getCardStatusGroup = (cardStatus) => {
    if (!cardStatus) {
        return null;
    }
    let statusGroup = STATUS_GROUPS[cardStatus];
    return statusGroup;
}

export {
    CARD_STATUS_ACTIVE,
    CARD_STATUS_CANCELLED,
    CARD_STATUS_FROZEN,
    CARD_TYPE_CREDIT,
    CARD_TYPE_DEBIT,
    getCardStatusGroup
};