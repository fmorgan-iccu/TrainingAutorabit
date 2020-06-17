({
	createAccountItems : function() {
        var items = [{
            title: "Open Cases",
            value: "",
            icon: "utility:case",
            color: "blue",
            isLoading: true,
            id: "openCases",
            usesFA: false
        }];

        return items;
	},

    createGeneralItems : function() {
        var items = [];

        return items;
	},
    
    updateItem: function (id, value, component, attribute) {
    	var items = component.get(attribute);

        items.forEach(function (item) {
            if (item.id === id) {
                item.value = value;
                item.isLoading = false;
            }
        });

        component.set(attribute, items);
    },
    
    appendItem: function (item, component, attribute) {
        var items = component.get(attribute);
        items.push(item);

        component.set(attribute, items);
    },
    
    insertItem: function (item, index, component, attribute) {
        var items = component.get(attribute);
        items.splice(index, 0, item);

        component.set(attribute, items);
    },
    
    removeItem: function (id, component, attribute) {
    	var items = component.get(attribute);

        var newItems = [];

        items.forEach(function (item) {
            if (item.id !== id) {
                newItems.push(item);
            }
        });

        component.set(attribute, newItems);
    },
    
    upsertItem: function (item, index, component, attribute, helper) {
        var items = component.get(attribute);
        var foundItem = null;

        // Iterate through and find the item by its ID.
        items.forEach(function (iteratedItem) {
            if (item.id === iteratedItem.id) {
                foundItem = iteratedItem;
            }

        });

        if (foundItem) {
            helper.updateItem(item.id, item.title, component, attribute);
        } else {
            helper.insertItem(item, index, component, attribute);
        }
    },
    
    subtractFromNow: function(date) {
        var ago = moment(date).fromNow();
        return ago;
    }

})