public class AOMonetaryTransDecisionLogParser extends AOSystemDecisionLogParser {
	
	public override String getSystemName() {
		return 'DNAMonetaryTransaction';
	}

    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        try {
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(decisionLogEntry.everything);
            List<Map<String, Object>> rawAccounts = APIUtils.convertObjectList((List<Object>)data.get('accounts'));
            String totalAmount = (String)data.get('totalFundingAmount');
            boolean didSucceed = (boolean)data.get('transferSucceeded');
            
            if (didSucceed == null) {
				didSucceed = true;
            }
            
            appInfo.successfullyTransferedFunds = didSucceed;
            
            if (rawAccounts != null) {
                String parsedData = '';
                for (Map<String, Object> rawAccount : rawAccounts) {
                    String accountNumber = (String)rawAccount.get('accountNumber');
                    String amount = (String)rawAccount.get('amount');
                    
                    parsedData += ' [ Account #: ' + accountNumber + ' | Account Amount: $' + amount + '] ';
                }
                
                parsedData += ' Total amount: $' + totalAmount;
                
                message = parsedData;
                state = AOInteractionResult.State.SUCCESS;
            } else {
                message = 'Accounts not found.';
                state = AOInteractionResult.State.UNKNOWN;
            }
        } catch(Exception e) {
            message = 'Unable to read DNA Monetary Transaction data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
    
    public override String getFriendlyName() {
        return 'DNA Monetary Transaction';
    }
	
}