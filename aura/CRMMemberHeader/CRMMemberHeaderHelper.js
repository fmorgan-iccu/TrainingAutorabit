({
    addYearsOfMembership : function(contact) {
        if (contact.MemberSince__c) {
            var memberDate = new Date (contact.MemberSince__c);
            var today = new Date (Date.now());
            memberDate = today.getFullYear() - memberDate.getFullYear();
            return memberDate;
        }

        return 0;
    },

    copyAttributesFromContact: function(component, event, helper) {
        var contact = component.get('v.headerContact');
        if (contact) {
            // The mailing address street must be split into separate lines.
            var streets = contact.MailingStreet ? contact.MailingStreet.split('\n') : [];
            component.set('v.mailingStreet1', streets.length > 0 ? streets[0] : '');
            component.set('v.mailingStreet2', streets.length > 1 ? streets[1] : '');
            component.set('v.mailingCity', contact.MailingCity);
            component.set('v.mailingState', contact.MailingState);
            component.set('v.mailingPostalCode', contact.MailingPostalCode);
            component.set('v.mailingCountry', contact.MailingCountry);
            component.set('v.phone', contact.Phone);
            component.set('v.mobilePhone', contact.MobilePhone);
            component.set('v.email', contact.Email);

            // Ensure the birth date is in the correct format.
            component.set("v.birthdate", helper.formatDate(contact.Birthdate));

            // Calculate the years of membership.
            var yearsOfMembership = helper.addYearsOfMembership(contact);
            component.set('v.yearsOfMembership', yearsOfMembership);
        }
    },

    formatDate: function(date) {
        var formattedDate = $A.localizationService.formatDate(date, "MMMM DD, yyyy")

        return formattedDate;
    }

})