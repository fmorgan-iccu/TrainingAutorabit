import { LightningElement, api } from 'lwc';
import backgroundImage from '@salesforce/resourceUrl/mountainTreeViewImage';

export default class CrmFormHeader extends LightningElement {
    @api form;
    @api membersname;
    //backgroundStyle = 'background-image: url(' + backgroundImage + ');'
    backgroundStyle = 'background-image: linear-gradient(115deg, rgba(0, 108, 24, 0.8), rgba(64, 188, 43, 0.7)), url(' + backgroundImage + ');'
}