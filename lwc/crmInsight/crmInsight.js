import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/**
 * This component displays an individual insight within the member insights component.
 */
export default class CrmInsight extends NavigationMixin(LightningElement) {

    @api insight = {};

    @track isEditable = false;
    @track isExpanded = false;
    @track isLoading = false;

    connectedCallback() {
        this.isEditable = this.insight.insightId && this.insight.insightId !== '';
    }

    handleCollapseDetail() {
        this.isExpanded = false;
    }

    handleEditInsight() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: this.insight.insightId,
                objectApiName: 'c__MemberInsight__c',
                actionName: 'edit'
            }
        });
    }

    handleExpandDetail() {
        this.isExpanded = true;
    }

    get hasExtendedDetails() {
        return this.insight.extendedDetail && this.insight.extendedDetail !== '';
    }

    get rowOneClasses() {
        return 'main-row-1';
    }

    get rowTwoClasses() {
        return 'main-row-2 ' + (this.isExpanded ? 'opened' : 'closed');
    }

}