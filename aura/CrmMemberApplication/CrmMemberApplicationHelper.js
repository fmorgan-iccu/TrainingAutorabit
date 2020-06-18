({
	formatDate: function(date, format) {
        var formattedDate = moment(date).format(format);
        return formattedDate;
    },
    
    formatDates: function(component, event, helper) {
        if (!moment) {
            return;
        }
        
        var application = component.get('v.Application');
        var format = 'M-D-YYYY';
        
        if (application.completedDate) {
            var formattedCompleteDate = helper.formatDate(application.completedDate, format);
            component.set('v.formattedCompletedDate', formattedCompleteDate);
        }
        
        if (application.startedDate) {
            var formattedStartedDate = helper.formatDate(application.startedDate, format);
            component.set('v.formattedStartedDate', formattedStartedDate);
        }
    }
})