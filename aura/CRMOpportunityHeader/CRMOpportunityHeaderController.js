({
    recordReceived : function(component, event, helper) {
        //assign background image
        helper.setBackground(component);
        //format numbers
        
        var resourceLoaded = false;
        
        try {
            if (!numeral || !moment) {
                return;
            }
            
            resourceLoaded = true;
        } catch (err) {
            
        }
        
        if (!resourceLoaded) {
            return;
        }
        
        helper.formatNumbers(component);
        
        helper.updateRecord(component, event, helper);
    },
    resourceReceived : function(component, event, helper) {
        if (!numeral || !moment) {
            return;
        }
        
        //format numbers
        helper.formatNumbers(component);
        
        var record = component.get('v.simpleRecord');
        
        if (!record) {
            return;
        }

        helper.updateRecord(component, event, helper);
    }
})