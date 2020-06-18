public class AOSFDCDesicionLogParser extends AOSystemDecisionLogParser {

    public override String getSystemName() {
        return 'SFDC';
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo, AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        // If this is a validation of the email against Salesforce, the decision should be ignored since
        // it doesn't impact the decisioning.
        if (systemInfo.system_display_name == 'SFDC-Email Check') {
            if (systemInfo.decision != 'FAIL') {
                message = 'SFDC e-mail check complete';
                state = AOInteractionResult.State.SUCCESS;
            } else {
                message = 'SFDC e-mail check failed';
                state = AOInteractionResult.State.ERROR;
            }
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override String getFriendlyName() {
        return 'SalesForce';
    }
}