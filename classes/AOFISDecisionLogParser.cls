public class AOFISDecisionLogParser extends AOSystemDecisionLogParser {

	public override String getSystemName() {
		return 'FIS';
	}
	
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry,  AOApplicationInfo appInfo) {
        String message = null; 
        String decision = decisionLogEntry.decision;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN; 

        try {
            // create map of FIS response
            Map<String, Object> everythingMap = (Map<String, Object>) JSON.deserializeUntyped(decisionLogEntry.everything);
            
            String errorText = (String)everythingMap.get('errorTxt');
            if (errorText != null) {
                errorText = errorText.trim();
                state = AOInteractionResult.State.SUCCESS;

                if (errorText.length() > 0) {
                    message = 'Error: ' + errorText;
                    return new AOInteractionResult(getSystemName(), state, message, decision);
                }
            }

            // Verify the accountAcceptanceTxt node is present.
            String acceptanceText = (String) everythingMap.get('accountAcceptanceTxt');
            
            if (acceptanceText != null) {
                message = 'Acceptance: ' + acceptanceText;
                state = AOInteractionResult.State.SUCCESS;
                
                Map<String, Object> reportPayload = new Map<String, Object> {
                    AOReportParser.RAW_DATA_KEY => everythingMap
                };
                AOFISReportParser reportParser = new AOFISReportParser();
                reportParser.parsePayload(reportPayload, appInfo);
            } else {
                message = 'Unable to find error nor acceptance information.';
                state = AOInteractionResult.State.UNKNOWN;
            }
        } catch(Exception e) {
            message = 'Unable to read FIS data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }
        
        return new AOInteractionResult(getSystemName(), state, message, decision);
    }
    
    public override String getFriendlyName() {
        return 'FIS Qualifile';
    }
	
}