import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import emojiResource from '@salesforce/resourceUrl/Emojis';
import FONT_AWESOME from '@salesforce/resourceUrl/fontAwesomeProFont';
import ICCU_ICON_FONT from '@salesforce/resourceUrl/iccuIconFont';

const CASE_TYPE = 'case';
const OPPORTUNITY_TYPE = 'opportunity';

export default class CrmTimelineEntry extends NavigationMixin(LightningElement) {

    @api entry = {};
    entryRole = 'Joint'; //TODO: this should be passed in as entry.role from the entry object - if there is no role assigned it should say "Not Assigned"

    @track caseIcon = 'standard:case';
    @track emojiUrl = null;
    @track iconClasses = 'unknown entry-label';
    @track opportunityIcon = 'standard:opportunity';

    connectedCallback() {
        let emojiIdentifier = this.convertSentimentToEmoji(this.entry.memberSentiment);
        this.emojiUrl = emojiResource + '/' + emojiIdentifier + '.png';
    }

    get caseStatusClass() {
        return 'status-' + this.entry.status;
    }

    convertSentimentToEmoji(sentiment) {
        switch (sentiment) {
            case '1':
                return '1VeryUnsatisfied';
            case '2':
                return '2Unsatisfied';
            case '3':
                return '3Neutral';
            case '4':
                return '4Satisfied';
            case '5':
                return '5VerySatisfied';
            default:
                return 'fallback';
        }
    }

    get useSfIcon() {
        let recordTypeName = this.entry.recordTypeName;
        if (this.isCase === true) {
            switch (recordTypeName) {
                case 'Online Account Opening':
                    this.iconClasses = 'avoka entry-label ';
                    this.caseIcon = 'utility:copy';
                    return true;
                case 'Complaint Record Type':
                    this.iconClasses = 'complaint entry-label ';
                    this.caseIcon = ICCU_ICON_FONT + '/symbol-defs.svg#icon-complaint-case';
                    return false;
                case 'Member Support':
                    this.iconClasses = 'support entry-label ';
                    if (this.entry.caseOrigin === 'Web' || this.entry.caseOrigin === 'Email' ) {
                        this.caseIcon = 'utility:comments';
                        return true;
                    } else if (this.entry.caseOrigin === 'Video Chat – Branch' || this.entry.caseOrigin === 'Video Chat - Mobile' ) {
                        this.caseIcon = FONT_AWESOME + '/sprites/solid.svg#video';
                        return false;
                    } else {
                        this.caseIcon = 'utility:questions_and_answers';
                        return true;
                    }
                case 'Member Retention Specialist':
                    this.iconClasses = 'retention entry-label';
                    this.caseIcon = FONT_AWESOME + '/sprites/solid.svg#hand-heart';
                    return false;
                default:
                    return true;
            }
        } else {
            switch (recordTypeName) {
                case 'Online Account Opening':
                    this.iconClasses = 'product-based entry-label ';
                    this.opportunityIcon = FONT_AWESOME + '/sprites/solid.svg#desktop';
                    return false;
                case 'Deposit Product':
                    this.iconClasses = 'product-based entry-label ';
                    this.opportunityIcon = FONT_AWESOME + '/sprites/solid.svg#piggy-bank';
                    return false;
                case 'Prospect':
                    this.iconClasses = 'product-based entry-label ';
                    this.opportunityIcon = ICCU_ICON_FONT + '/symbol-defs.svg#icon-member-prospect';
                    return false;
                case 'Loan':
                    this.iconClasses = 'product-based entry-label ';
                    this.opportunityIcon = FONT_AWESOME + '/sprites/solid.svg#hand-holding-usd';
                    return false;
                case 'HELOC':
                    this.iconClasses = 'product-based entry-label ';
                    this.opportunityIcon = ICCU_ICON_FONT + '/symbol-defs.svg#icon-heloc';
                    return false;
                default:
                    return true;
            }
        }
    }

    get isCase() {
        return this.entry.type === CASE_TYPE;
    }

    get isComplaintCase() {
        return this.entry.recordTypeName === 'Complaint Record Type';
    }

    get isMemberSupportCase() {
        return this.entry.recordTypeName === 'Member Support' || this.entry.recordTypeName === 'Business Support';
    }

    get isOpportunity() {
        return this.entry.type === OPPORTUNITY_TYPE;
    }

    get isUnknownCaseType() {
        return this.entry.recordTypeName !== 'Member Support' && this.entry.recordTypeName !== 'Complaint Record Type' && this.entry.recordTypeName !== 'Online Account Opening' && this.entry.recordTypeName !== 'Business Support';
    }

    get opportunityStageClass() {
        return 'stage-' + this.entry.stageName;
    }

    get showSentiment() {
        return this.entry.recordTypeName === 'Member Support' || this.entry.recordTypeName === 'Complaint Record Type' || this.entry.recordTypeName === 'Business Support';
    }

    openCase(event) {
        this.openRecord(event, 'Case');
    }

    openOpportunity(event) {
        this.openRecord(event, 'Opportunity');
    }

    openRecord(event, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
                attributes: {
                    recordId: this.entry.id,
                    objectApiName: objectApiName,
                    actionName: 'view'
                }
        });
    }

}