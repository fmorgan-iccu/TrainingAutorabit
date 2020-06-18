({
	doInit : function(component, event, helper) {
        var action = component.get('c.fetchOpenApplications');      
        $A.enqueueAction(action);
	},
	fetchOpenApplications : function(component, event, helper) {
            var action = component.get("c.getOpenApplications");
        var contactId = component.get("v.recordId");
        
        component.set('v.isLoading', true);

        action.setParams({
            "contactId": contactId
        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var updateState = function (error, applications, showApplicationDetails) {
                var openApplications = [];
                var completedApplications = [];
                var fundedApplications = [];

                if (applications) {
                    applications.forEach(function (application) {
                        if (application.isFunded) {
                            fundedApplications.push(application);
                        } else if (application.isComplete) {
                            completedApplications.push(application);
                        } else {
                            openApplications.push(application);
                        }
                    });
                }
                
                var setStartDateOnApplications = function (applications) {
                    if (applications) { // Sanity Check
                        applications.forEach(function (application) {
                            if (application.milestones && application.milestones.length > 0) {
                                var milestone = application.milestones[0];
                                var startedDate = milestone.statusDate;
                                application.startedDate = startedDate;
                            }
                        });
                    }
                }

                var noOpenAppsMessage = '';
                var noFundedAppsMessage = '';
                var noCompleteAppsMessage = '';

                if (openApplications.length === 0 && !error) {
                    noOpenAppsMessage = 'No Submitted Applications';
                }
                
                if (completedApplications.length === 0 && !error) {
                    noCompleteAppsMessage = 'No Unfunded and Complete Applications';
                }

                if (fundedApplications.length === 0 && !error) {
                    noFundedAppsMessage = 'No Funded Applications';
                }

                setStartDateOnApplications(openApplications);
                setStartDateOnApplications(completedApplications);
                setStartDateOnApplications(fundedApplications);

                component.set('v.showApplicationDetails', showApplicationDetails);
                component.set('v.submittedApplicationsErrorMessage', error);
				component.set('v.submittedApplications', openApplications);
                component.set('v.fundedApplications', fundedApplications);
                component.set('v.completedApplications', completedApplications);
                component.set('v.noCompletedApplicationsMessage', noCompleteAppsMessage);
                component.set('v.noSubmittedApplicationsMessage', noOpenAppsMessage);
                component.set('v.noFundedApplicationsMessage', noFundedAppsMessage);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var applications = responseData.applications;
                var showApplicationDetails = responseData.showApplicationDetails ? responseData.showApplicationDetails : false;
                var error = responseData.error;

                updateState(error, applications, showApplicationDetails);
            }
        });

        $A.enqueueAction(action);
    },
    handleSystemOfRecordLogin : function(component, event, helper) {
        var action = component.get('c.fetchOpenApplications');
        $A.enqueueAction(action);
	}
})