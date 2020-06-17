import { LightningElement, track } from 'lwc';

export default class CrmAutoPayoffForm extends LightningElement {
    /* TODO: Don't hardcode the data :) */

    @track showAccountList = false;
    @track accountSearch = false;
    @track accountSelected = true;
    @track titleRelease = false;
    @track isDisabled = false;
    @track isLoaded = true; /* TODO: change to true when loading logic is put into place */
    error;
    hasError = false;
    formName = "Auto Payoff";

    // TODO: We need some sort of verification that the user is authenticated before continuing,
    // If the user is unathenticated or an error has occured, change "isDisabled" to true

    doShowAccountList() {
        this.showAccountList = true;
    }
    dontShowAccountList() {
        this.showAccountList = false;
    }
    showAccountSearch() {
        this.accountSelected = false;
        this.showAccountList = false;
        this.accountSearch = true;
    }
    showTitleReleaseForm(event) {
        this.titleRelease = event.target.checked;
    }
    
    member = {
        firstName: "Jill",
        fullName: "Jill Jenkins",
    }
    autoAccounts = [
        {
            Id: 1,
            Nickname: 'Nickname',
            Number: '123465 (account number)',
        },
        {
            Id: 2,
            Nickname: 'My cool car',
            Number: '16579864',
        },
        {
            Id: 3,
            Nickname: 'My lame car',
            Number: '879871456479',
        },
    ];
    contacts = [
        {
            Id: 1,
            Name: 'Jill Jenkins',
            StreetAddress: '123 IcecreamIsThe Way',
            City: 'Chocolate Chip Cookie Dough',
            State: 'Washington',
            Zipcode: '97229',
        },
        {
            Id: 2,
            Name: 'George Jenkins',
            StreetAddress: '3486 Indigo Lane',
            City: 'Breeverton',
            State: 'Oregon',
            Zipcode: '97007',
        },
    ];
}