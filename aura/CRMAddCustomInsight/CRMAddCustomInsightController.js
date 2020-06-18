({
    //somwhere in here set v.simpleNewInsight.ContactID__c equal to current contact?
	doInit : function(component, event, helper) {
		//Prepare a new record from template
		component.find("insightRecordCreator").getNewRecord(
        	"MemberInsight__c", // API name
            null, // recordTypeId
            false, //skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newInsight");
                var error = component.get("v.newInsightError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.objectType);
                }
            })
        );
	},
    handleSaveInsight: function(component, event, helper) {
        if(helper.validateInsightForm(component)) {
            component.set("v.simpleNewInsight.ContactID__c", component.get("v.recordID"));
            component.find("InsightRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult === "DRAFT") {
                    //record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved."
                    });
                    resultsToast.fire();
                } else if (saveResult.state === "INCOMPLETE") {
                    //handle the incomplete state
                    console.log('Problm saving Insight, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown promblem, state: ' + saveResult.state +
                                ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }
    }
})