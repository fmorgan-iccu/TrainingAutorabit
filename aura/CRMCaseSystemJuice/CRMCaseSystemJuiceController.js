({
	prettifyCode : function(component, event, helper) {
        PR.prettyPrint();  
    },
    
    importXml : function(){
        var recordId = component.get("v.recordId");
        var url = '/apex/AOXmlAvokaData' + recordId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }

})