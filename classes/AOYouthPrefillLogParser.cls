public class AOYouthPrefillLogParser extends AOSystemDecisionLogParser {

    public override String getSystemName() {
        return 'YouthContactService';
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        // Check to see if the Youth Contact Service Failed and display the error message if available.
        if (systemInfo.decision != 'FAIL') {
            message = 'Successful';
            state = AOInteractionResult.State.SUCCESS;
        } else if (!String.isBlank(systemInfo.user_action)) {
            message = systemInfo.user_action;
            state = AOInteractionResult.State.ERROR;
        } else {
            message = 'Youth prefill failed for an unknown reason';
            state = AOInteractionResult.State.ERROR;
        }

        // Check to see if the error is due to lastname/DOB/SSN mismatch and close the case.
        // TODO: Fix this to not check for the error. This will require the Temenos system to return a clear signal for the resulting state.
        if (systemInfo.user_action == 'Applicant entered a last name and/or date of birth that didn\'t match the SalesForce Contact.') {
            appInfo.appRequest.app_status = AOConstants.APP_STATUS_ABANDONED;
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override String getFriendlyName() {
        return 'Youth Prefill';
    }
}