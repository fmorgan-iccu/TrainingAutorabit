/**
 * Abstract class with a `parseEntry` method to create `DecisionLogEntry` that subclasses can then use to get to their system's specific data information.
 */
public abstract class AOSystemDecisionLogParser {
    public String ownerPrefix { get; set; }

    public void parsePayload(List<AOApplicationRestRequest.SystemInfo> systemInfo, AOApplicationInfo appInfo) {
        // Find the specific SystemInfo object for this parser.
        String systemName = this.getSystemName();
        AOApplicationRestRequest.SystemInfo theSystemInfo = null;
        for (AOApplicationRestRequest.SystemInfo si : systemInfo) {
            if (si.system_name == systemName) {
                theSystemInfo = si;
                break;
            }
        }

        // Process/parse the SystemInfo information.
        AOInteractionResult systemResult = null;
        if (theSystemInfo != null) {
            systemResult = this.processLogEntry(theSystemInfo, appInfo);
        } else {
            systemResult = new AOInteractionResult(this.getFriendlyName(), AOInteractionResult.State.NOT_PRESENT, null, null);
        }

        // Overriding the system name if there is an owner prefix to create unique entries in the AppInfo systemInteractionResults Map.
        if (this.ownerPrefix != null) {
            systemName = this.ownerPrefix + ' ' + systemName;
            systemResult.systemName = this.ownerPrefix + ' ' + systemResult.systemName;
        }

        appInfo.systemInteractionResults.put(systemName, systemResult);
    }

    public abstract String getSystemName();
    public abstract String getFriendlyName();
    public abstract AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo, AOApplicationInfo appInfo);
}