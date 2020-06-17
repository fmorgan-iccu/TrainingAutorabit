public class AOPrefillDecisionLogParser extends AOSystemDecisionLogParser {
	public override String getSystemName() {
		return 'Prefill';
	}
	
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry,  AOApplicationInfo appInfo) {
        String message = null; 
        String decision = decisionLogEntry.decision;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN; 

        try {
			String successMessage = decisionLogEntry.everything.contains('Product Service Call Successfull') ? 'Yes' : 'No';

            message = 'Able to prefill: ' + successMessage;

            state = AOInteractionResult.State.SUCCESS;
        } catch(Exception e) {
            message = 'Unable to read Prefill data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }
        
        return new AOInteractionResult(getSystemName(), state, message, decision);
    }
    
    public override String getFriendlyName() {
        return 'SalesForce Prefill';
    }
}