({
    doInit : function(component, event, helper) {

    },
    
    recordDidUpdate : function(component, event, helper) {
		var record = component.get('v.simpleRecord');
        
        if (!record) {
            return;
        }
        
        var jsonString = record.AvokaApplicationInfoJSON__c;
        if (!jsonString) {
            return;
        }
        
        try {
            var json = JSON.parse(jsonString);
            var reports = json.reports;
            
            if (!reports) {
                return;
            }
            
            component.set('v.reports', reports);
        } catch(err) {
            console.log('Error while parsing json: ' + err);
        }
	}
})