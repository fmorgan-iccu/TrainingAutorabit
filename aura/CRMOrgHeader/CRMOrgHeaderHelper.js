({
    addYearsOfMembership : function(account) {
        if (account.MembershipDate__c) {
            var memberDate = new Date (account.MembershipDate__c);
            var today = new Date (Date.now());
            memberDate = today.getFullYear() - memberDate.getFullYear();
            return memberDate;
        }

        return 0;
    },

formatDate: function(date) {
    var formattedDate = $A.localizationService.formatDate(date, "MMMM DD, yyyy")

    return formattedDate;
},

copyAttributesFromAccount: function(component, event, helper) {
    var account = component.get('v.headerAccount');
    if (account) {
        // The mailing address street must be split into separate lines.
        var streets = account.BillingStreet ? account.BillingStreet.split('\n') : [];
        component.set('v.mailingStreet1', streets.length > 0 ? streets[0] : '');
        component.set('v.mailingStreet2', streets.length > 1 ? streets[1] : '');
        component.set('v.mailingCity', account.BillingCity);
        component.set('v.mailingState', account.BillingState);
        component.set('v.mailingPostalCode', account.BillingPostalCode);
        component.set('v.mailingCountry', account.BillingCountry);
        component.set('v.phone', account.Phone);
    }
},

formatTaxId: function(component, taxId) {
    if (taxId.length === 10) {
        let taxIdParts = [taxId.substring(0,2), taxId.substring(3,7), taxId.substring(7,10)]
        let redactedTaxId = taxIdParts[0] + '-XXXX' + taxIdParts[2];
        component.set('v.redactedTaxId', redactedTaxId);
    } else {
        component.set('v.redactedTaxId', 'XX-XXXXXXX');
    }
}

})