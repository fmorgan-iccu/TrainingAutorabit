public class AODecisionLogEntry {
    public String everything {get; private set;}
	public String callStatus {get; private set;}
	public String decision {get; private set;}
	public String transactionKey {get; private set;}
	public String trackingNumber {get; private set;}
	public String svcDisplayName {get; private set;}
    
    public AODecisionLogEntry(String everything, String callStatus, String decision, String transactionKey, String trackingNumber, String svcDisplayName) {
        this.everything = everything;
        this.callStatus = callStatus;
        this.decision = decision;
        this.transactionKey = transactionKey;
        this.trackingNumber = trackingNumber;
        this.svcDisplayName = svcDisplayName;
    }
}