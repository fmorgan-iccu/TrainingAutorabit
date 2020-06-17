({
	doInit : function(component, event, helper) {
        var convertSentimentToEmoji = function(sentiment) {
            switch (sentiment) {
                case '1':
                    return '1VeryUnsatisfied';
                case '2':
                    return '2Unsatisfied';
                case '3':
                    return '3Neutral';
                case '4':
                    return '4Satisfied';
                case '5':
                    return '5VerySatisfied';
                default:
                    return 'fallback';
            }
        };
	}
})