public class AOSFDCDesicionLogParser extends AOSystemDecisionLogParser {

	public override String getSystemName() {
		return 'SFDC';
	}
	
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
		String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        // If this is a validation of the email against Salesforce, the decision should be ignored since
        // it doesn't impact the decisioning.
        if (decisionLogEntry.svcDisplayName == 'SFDC-Email Check') {
            if (decisionLogEntry.decision != 'FAIL') {
                message = 'SFDC e-mail check complete';
                state = AOInteractionResult.State.SUCCESS;
            } else {
                message = 'SFDC e-mail check failed';
                state = AOInteractionResult.State.ERROR;
            }
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }

    public override String getFriendlyName() {
        return 'SalesForce';
    }
}