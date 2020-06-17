({
    formatDate: function(date) {
        var parsedDate = moment(date, "YYYY-MM-DD");
        var birthdate = moment(date).format('MMMM DD, YYYY h:mma');
        return birthdate;
    },
    
    openCase: function(caseId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseId
        });
        navEvt.fire();
    },
    
    formatDates: function(component, event, helper) {
        if (!moment) {
            return;
        }
        
        var transaction = component.get('v.transaction');
        
        if (transaction && transaction.timeLastUserActivity) {
            var lastUpdatedDate = transaction.timeLastUserActivity

            if (lastUpdatedDate) {
                lastUpdatedDate = new Date(lastUpdatedDate);
                var formattedLastUpdatedDate = helper.formatDate(lastUpdatedDate);
                component.set('v.lastUpdatedDate', formattedLastUpdatedDate);
            }
        }
    }
    
})