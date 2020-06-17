({
	getDaysAgo : function(component) {
		var daysAgo = component.get('v.daysAgo');
        daysAgo = parseInt(daysAgo);

        if (daysAgo === NaN) {
            daysAgo = 90;
        }

        return daysAgo;
	}
})