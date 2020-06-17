/**
 * Abstract class with a `parseEntry` method to create `DecisionLogEntry` that subclasses can then use to get to their system's specific data information.
 */
public abstract class AOSystemDecisionLogParser implements IAOPayloadParser {
    public String ownerPrefix { get; set; }
    
    public AODecisionLogEntry parseEntry(Map<String,Object> entryData) {
        String everything = (String)entryData.get('everything');
        String callStatus = (String)entryData.get('callStatus');
        String decision = StringUtils.toProperCase((String)entryData.get('decision'));
        String transactionKey = (String)entryData.get('transactionKey');
        String trackingNumber = (String)entryData.get('trackingNumber');
        String svcDisplayName = (String)entryData.get('svcDisplayName');

        if (decision == null) {
            decision = 'Not Present';
        }

        AODecisionLogEntry entry = new AODecisionLogEntry(everything, callStatus, decision, transactionKey, trackingNumber, svcDisplayName);
        return entry;
    }
    
    public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        String systemName = this.getSystemName();
		
        Map<String, Object> systemNode = (Map<String, Object>)payload.get(systemName);
        AOInteractionResult systemResult = null;
        if (systemNode != null) {
            AODecisionLogEntry entry = this.parseEntry(systemNode);
            systemResult = this.processLogEntry(entry, appInfo);
        } else {
            System.debug('The system (' + systemName + ') was not present. These were the systems in the data provided: ' + payload.keySet());
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
    public abstract AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo);
}