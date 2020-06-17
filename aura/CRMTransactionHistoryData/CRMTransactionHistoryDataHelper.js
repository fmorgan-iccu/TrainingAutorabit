({
	helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');    
       }
	},

    formatDate : function(date) {
        if (!date) {
            return null;
        }
        
        var formattedDate = moment(date).format('M-D-YYYY');
        return formattedDate;
    },

    formatDates : function(component, event, helper) {
        if (!moment) {
            return;
        }

        var transaction = component.get('v.Transaction');
        if (transaction) {
            if (transaction.effectiveDate) {
                var formattedDate = helper.formatDate(transaction.effectiveDate);
                component.set('v.effectiveDate', formattedDate);
            }
            
            if (transaction.postDate) {
                var formattedDate = helper.formatDate(transaction.postDate);
                component.set('v.postDate', formattedDate);
            }
        }
    },
    
    formatNumbers: function(component, event, helper) {
        if (!numeral) {
            return;
        }
        
        var transaction = component.get('v.Transaction');
        
        if (transaction) {
            var format = "$0,000.00";
            
            if (transaction.amount) {
                var amount = numeral(transaction.amount).format(format);
                component.set('v.amount', amount);
            }
            
            if (transaction.balance) {
                var balance = numeral(transaction.balance).format(format);
                component.set('v.balance', balance);
            }
        }
    }

})