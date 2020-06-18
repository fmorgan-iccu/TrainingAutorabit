public class AOFundAccountsByGroupParser extends AOSystemDecisionLogParser {

    public override String getSystemName() {
        return 'FundAccountsByGroup';
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        try {
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(systemInfo.everything);
            List<Map<String, Object>> rawAccounts = APIUtils.convertObjectList((List<Object>)data.get('accounts'));
            String totalAmount = (String)data.get('totalFundingAmount');
            Boolean didSucceed = (Boolean)data.get('transferSucceeded');

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

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override String getFriendlyName() {
        return 'DNA Monetary Transaction';
    }

}