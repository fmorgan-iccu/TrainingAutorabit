({
    handleSystemOfRecordLogin: function(component, event, helper) {
        component.find('crmInsightList').loadInsights();
    },

    onRequireLogin : function(component, event, helper) {
        // Relay the LWC event(s) to the CRMSystemLogins component.
        var systems = event.getParam('systems');
        for (var loginSystem in systems) {
            var s = systems[loginSystem];
            var myEvent = $A.get('e.c:RequireSystemOfRecordLogin');
            myEvent.setParam('system', s);
            myEvent.fire();
        }
    }
})