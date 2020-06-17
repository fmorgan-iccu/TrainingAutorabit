({
    recordDidUpdate : function(component, event, helper) {
        var record = component.get('v.simpleRecord');
        var jsonString = record.AvokaApplicationInfoJSON__c;

        if (!jsonString) {
            return;
        }

        var json = JSON.parse(jsonString);
        var interactions = json.systemInteractionResults;
        var keys = Object.keys(interactions); // The interactions is a map, not an array

        var interactionResults = [];

        // Go get all the interactions and convert and it to the array of interactions we want to send to the client.
        keys.forEach(function(key) {
            var interaction = interactions[key];
            interactionResults.push(interaction);
        });

        component.set('v.systemInteractions', interactionResults);
    }
})