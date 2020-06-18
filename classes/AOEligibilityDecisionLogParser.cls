public class AOEligibilityDecisionLogParser extends AOSystemDecisionLogParser {

    public override String getSystemName() {
        return 'Eligibility';
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        try {
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(systemInfo.everything);
            String selectedOption = (String)data.get('selectedOption');
            if (selectedOption != null) {
                message = 'Selected Option: ' + selectedOption;
                state = AOInteractionResult.State.SUCCESS;
            } else {
                // For some reason, they stick some of these other options in other elements,
                // for example, Idaho residence.  Needs to be removed when Avoka is fixed...
                // #avokafix
                String currentIdahoResident = (String)data.get('currentResidentIdaho');
                if (currentIdahoResident != null) {
                    message = 'Current Idaho Resident: ' + currentIdahoResident;
                    state = AOInteractionResult.State.SUCCESS;
                } else {
                    message = 'No selection made';
                    state = AOInteractionResult.State.UNKNOWN;
                }
            }
        } catch(Exception e) {
            message = 'Unable to read eligibility data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override String getFriendlyName() {
        return 'Eligibility';
    }

}