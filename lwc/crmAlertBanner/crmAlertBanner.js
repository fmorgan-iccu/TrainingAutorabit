import { LightningElement, track, api } from 'lwc';

export default class CrmAlertBanner extends LightningElement {
    @api alertType;
    @api alertTitle;
    @api alertMessage;
}