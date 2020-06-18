public class AOUnknownDecisionLogParser extends AOSystemDecisionLogParser {
    private String systemName {get; set;}

    public AOUnknownDecisionLogParser(String systemName) {
        this.systemName = systemName;
    }

    public override String getSystemName() {
        return this.systemName;
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo, AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        message = systemInfo.everything;

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override String getFriendlyName() {
        return this.systemName;
    }
}