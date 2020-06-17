/**
 * Model object representing the information that should be surfaced to an end-user about the interaction with a system.
 * This model is intentionally immutable.
 */
public class AOInteractionResult {

    public enum State { ERROR, NOT_PRESENT, SUCCESS, UNKNOWN }
    
    public String systemName { get; set; }
    public State state { get; private set; }
    public String message { get; private set; }
    public String systemDecision { get; private set; }

    public AOInteractionResult(String systemName, State state, String message, String systemDecision) {
        this.systemName = systemName;
        this.state = state;
        this.message = message;
        this.systemDecision = systemDecision;
    }

}