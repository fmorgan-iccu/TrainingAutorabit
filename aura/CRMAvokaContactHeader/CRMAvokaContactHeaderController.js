({
    formatBirthday : function(component, event, helper) {
        var birthday = component.get("v.simpleRecord.Birthdate");
        if (!moment || !birthday) {
            return;
        }
        var formattedBirthday = helper.formatDate(birthday);
		component.set("v.formattedBirthday", formattedBirthday);
	}
})