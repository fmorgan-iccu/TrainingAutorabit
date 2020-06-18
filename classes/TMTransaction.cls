public class TMTransaction implements IAccountOpeningTransaction {
    private String id;
    private TMTransactionApplicant applicant;
    private String caseId;
    private String clientName;
    private String contactEmail;
    private String deliveryStatus;
    private String externalProfileId;
    private String formName;
    private String formStatus;
    private String formURL;
    private AccountOpeningProduct product;
    private DateTime timeLastUserActivity;
    private DateTime timeRequested;
    private DateTime timeSubmitted;
    private String trackingCode;

    public TMTransaction(String id, TMTransactionApplicant applicant, String clientName, String contactEmail, String deliveryStatus, String externalProfileId, String formName, String formStatus, String formURL, AccountOpeningProduct product, DateTime timeLastUserActivity, DateTime timeRequested, DateTime timeSubmitted, String trackingCode) {
        this.id = id;
        this.applicant = applicant;
        this.clientName = clientName;
        this.contactEmail = contactEmail;
        this.deliveryStatus = deliveryStatus;
        this.externalProfileId = externalProfileId;
        this.formName = formName;
        this.formStatus = formStatus;
        this.formURL = formURL;
        this.product = product;
        this.timeLastUserActivity = timeLastUserActivity;
        this.timeRequested = timeRequested;
        this.timeSubmitted = timeSubmitted;
        this.trackingCode = trackingCode;
    }
    
    public String getId() {
        return this.id;
    }
    
    public String getCaseId() {
        return this.caseId;
    }
    
    public String getClientName() {
        return this.clientName;
    }
    
    public String getContactEmail() {
        return this.contactEmail;
    }
    
    public String getDeliveryStatus() {
        return this.deliveryStatus;
    }
    
    public String getExternalProfileId() {
        return this.externalProfileId;
    }
    
    public String getFormName() {
        return this.formName;
    }
    
    public String getFormStatus() {
        return this.formStatus;
    }
    
    public String getFormURL() {
        return this.formURL;
    }
    
    public AccountOpeningProduct getProduct() {
        return this.product;
    }
    
    public DateTime getTimeLastUserActivity() {
        return this.timeLastUserActivity;
    }
    
    public DateTime getTimeRequested() {
        return this.timeRequested;
    }
    
    public DateTime getTimeSubmitted() {
        return this.timeSubmitted;
    }
    
    public String getTrackingCode() {
        return this.trackingCode;
    }
    
    public void setCaseId(String caseId) {
        this.caseId = caseId;
    }
}