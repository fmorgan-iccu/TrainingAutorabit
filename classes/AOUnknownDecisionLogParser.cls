public class AOUnknownDecisionLogParser extends AOSystemDecisionLogParser {
    private String systemName {get; set;}
    
    public AOUnknownDecisionLogParser(String systemName) {
        this.systemName = systemName;
    }
    
    public override String getSystemName() {
		return this.systemName;
	}
	
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
		String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        message = decisionLogEntry.everything;

        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }

    public override String getFriendlyName() {
        return this.systemName;
    }
}