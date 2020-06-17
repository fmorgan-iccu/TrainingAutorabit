({
	formatDates : function(component, event, helper) {
        if (!moment) {
            return;
        }
        
        var card = component.get('v.AccountCard');
        
        if (!card || !card.expirationDate) {
            return;
        }
        
        let expirationFormat = 'MM/YY';
        let expirationDate = card.expirationDate;
        let formattedExpiration = moment(expirationDate).format(expirationFormat);
        component.set('v.formattedExpirationDate', formattedExpiration);
    },
    
    formatCardNumber : function(component, event, helper) {
        var card = component.get('v.AccountCard');
        
        if (!card || !card.cardNumber || card.cardNumber.length < 16) {
            return;
        }
        
        var cardNumber = card.cardNumber;
        var cardChunkLength = 4;
        var chunks = [];
        
        for (var i = 0, charsLength = cardNumber.length; i < charsLength; i += cardChunkLength) {
            chunks.push(cardNumber.substring(i, i + cardChunkLength));
        }
        
        var formattedNumber = '';
        chunks.forEach(function (chunk) {
            formattedNumber += chunk + ' ';
        });
        
        component.set('v.formattedCardNumber', formattedNumber);
    }
})