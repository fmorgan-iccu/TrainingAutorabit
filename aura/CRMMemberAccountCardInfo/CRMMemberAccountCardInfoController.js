({
	doInit : function(component, event, helper) {
		helper.formatDates(component, event, helper);
        helper.formatCardNumber(component, event, helper);
	},

    formatDates : function(component, event, helper) {
        helper.formatDates(component, event, helper);
    },
    
    editCard : function(component, event, helper) {
        component.set('v.isEditing', true);
    },
    
    cancelEditCard : function(component, event, helper) {
        component.set('v.isEditing', false);
    },
    
    updateCard : function(component, event, helper) {
        var cardInfo = component.get('v.AccountCard');
        
        var cardNumber = cardInfo.cardNumber;        
        var providerName = cardInfo.providerName;
        var typeCode = cardInfo.typeCode;
        var uniqueId = cardInfo.uniqueId;
        
        var changeReason = component.find('ChangeReason').get('v.value');
        var changeReasonCode = null;
        var changeReasonCodeComp = component.find('ChangeReasonSelect');

        if (changeReasonCodeComp) {
            changeReasonCode = changeReasonCodeComp.get('v.value');
        }

        var newStatus = component.find('ChangeStatusSelect').get('v.value');

        if (newStatus.length == 0) {
            helper.displayError('You must select a new status.');
            return;
        }
        
        var request = {
            status: newStatus,
            changeReason: changeReason,
            changeReasonCode: changeReasonCode,
            cardNumber: cardNumber,
            providerName: providerName,
            typeCode: typeCode,
            uniqueId: uniqueId
        };
        
        var updateEvent = $A.get('e.c:CardNeedsUpdate');
        updateEvent.setParams({'request': request});
        updateEvent.fire();
    }
    
})