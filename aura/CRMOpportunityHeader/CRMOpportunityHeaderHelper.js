({
    setBackground : function(component) {
        // get the major and minor type codes
        var majorCode = component.get('v.simpleRecord.ProductMajorCode__c');
        var minorCode = Number(component.get('v.simpleRecord.ProductMinorCode__c'));
        //Define background image variable
        var productBackground = $A.get('$Resource.FSCOpportunityHeaderBackground');
        // assign image based on product type
        if (majorCode === 'CRIF') {
            switch(minorCode) {  
                case 107: //new auto
                case 137: //auto
                case 139: //used auto
                case 154: //auto loan credit rebuilder
                    productBackground = $A.get('$Resource.AutoOpportunityHeader');
                    break;
                case 113: //motorcycle
                    productBackground = $A.get('$Resource.MotorcycleOpportunityHeader');
                    break;
                case 109: //Recreational Vehicle - large
                    productBackground = $A.get('$Resource.LargeRecOpportunityHeader');
                    break;
                case 110: //Recreational Vehicle - small
                    productBackground = $A.get('$Resource.SmallRecOpportunityHeader');
                    break;
                case 119: //Visa fixed rate platinum
                case 122: //Credit Builder Visa
                case 134: //Premier Rewards Visa
                case 135: //Rewards Visa
                case 136: //Variable Rate Platinum Visa
                    productBackground = $A.get('$Resource.VisaOpportunityHeader');
                    break;
                case 117: //PLOC
                case 118: //Signature Loan
                case 138: //Credit Builder Signature Loan
                    productBackground = $A.get('$Resource.PlocSigOpportunityHeader');
                    break;
                default: //Default
                    productBackground = $A.get('$Resource.FSCOpportunityHeaderBackground');
            }
            //set the background based on switch statement
            component.set("v.backgroundImage", productBackground);
   		//not CRIF major type
        } else {
            //set background to default image
            var defaultBackground = $A.get('$Resource.FSCOpportunityHeaderBackground');
            component.set("v.backgroundImage", defaultBackground);
        }
    },
	formatNumbers : function(component) {
        var record = component.get("v.simpleRecord");
        var closeDate = component.get("v.simpleRecord.CloseDate");
        var amount = component.get("v.simpleRecord.Product_Amount__c");

        if ( closeDate ) {
            var formattedCloseDate = this.formatDate(closeDate);
            component.set("v.formattedCloseDate", formattedCloseDate);
        }
        if ( amount ) {
            var formattedAmount = this.formatAmount(amount);
            component.set("v.formattedAmount", formattedAmount);
        }
    },
	formatDate: function(date) {
        if (!moment) {
            return;
        }
        
        var closeDate = moment(date).format('MMMM Do YYYY');
		return closeDate;
    },
    formatAmount: function(amount) {
        if (!numeral) {
            return;
        }
        
    	var amount = numeral(amount).format('0,0');
        return amount;
	},
    updateRecord: function(component, event, helper) {
        var record = component.get('v.simpleRecord');
        if (!record) {
            return;
        }
        
        var jsonString = record.avokaApplicationInfoJSON__c;
        if (jsonString) {
            try {
                var json = JSON.parse(jsonString);
                var loans = json.loanApplications;
                
                if (loans) {
                    loans.forEach(function (loan) {
                        if (loan.amount) {
                            var formattedAmount = helper.formatAmount(loan.amount);
                            loan.formattedAmount = formattedAmount;
                        }
                    });
                    
                    component.set('v.applications', loans);
                }

                var applicationIDs = json.loanApplicationIds;
                component.set('v.applicationIDs', applicationIDs);
            } catch (err) {
                console.log(err);
            }
        }
    },
    
    isAbandoned: function(component) {
        var abandoned = component.get('v.simpleRecord.Lost_Reason__c');
        
        if (abandoned === 'Abandoned'){
            component.set('v.abandonedApplication', true);
        }
            
    }
})