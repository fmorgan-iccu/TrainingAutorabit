({
	validateInsightForm : function(component) {
		var validInsight = true;
        // Show error messages if required fields are blank
        var allValid = component.find('insightField').reduce(function (validFields, inpueCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && InputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            //verify we have an account to attach it to
            var account = component.get("v.newInsight");
            if($A.util.isEmpty(account)) {
                validInsight = false;
                console.log("Quick action context doesn't have a valid account");
            }
            return(validInsight);
            
        }
	}
    
})