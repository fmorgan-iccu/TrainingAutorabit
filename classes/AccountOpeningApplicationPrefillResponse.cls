/**
 * Model object representing a response to submitting a prefilled application.
 */
public class AccountOpeningApplicationPrefillResponse {
    private String prefillURL;
    
    public AccountOpeningApplicationPrefillResponse(String prefillURL) {
        this.prefillURL = prefillURL;
    }
    
    public String getPrefillURL() {
        return this.prefillURL;
    }
}