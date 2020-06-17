({
    /*
     * Common method for displaying error feedback to the user.
     */
	showError : function(component, message) {
		component.set('v.errorMessage', message);
	},
    setIsLoading: function(component, isLoading) {
        component.set('v.isLoading', isLoading);
    }
})