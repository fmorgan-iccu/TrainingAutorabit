({
	doInit : function(component, event, helper) {
        // Breaking out the report title and data because of a deep-rooted, not-well-understood
        // lightning bug.  Not the firefly kind.
		var report = component.get('v.report');
        
        if (report) {
            component.set('v.title', report.title);
            component.set('v.reportData', report.data);
        }
	}
})