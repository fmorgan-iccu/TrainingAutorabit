import { LightningElement, api } from 'lwc';

export default class CrmLwcLoadingSpinner extends LightningElement {
    @api message = null;

    get hasMessage() {
        return this.message != null;
    }
}