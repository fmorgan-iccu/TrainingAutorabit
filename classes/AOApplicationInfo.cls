public class AOApplicationInfo {
    public class AOLoanApplication {
        public Decimal amount { get; set; }
        public String propertyType { get; set; }
        public String propertySubType { get; set; }
        public String purchaseType { get; set; }
        public String vin { get; set; }
    }
    
    public Boolean isYouthApplication { get; set; }
    
    // Avoka form information
	public String deliveryTriggerType { get; set; }
    public String trackingCode { get; set; }
    public String job { get; set; }
	public Boolean isJointApplication { get; set; }
    public String form { get; set; }
    public String formName { get; set; }
    public String status { get; set; }
    public String transactionStatus { get; set; }
    public String submissionData { get; set; }
    public List<String> errors { get; private set; }
    public String formUrl { get; set; }
    
    // New account information
    public List<IAccount> newAccounts;    
    public Double totalFundAmount {get; set;}
    public boolean usingProPay {get; set;}
    public String propayPaymentType {get; set;} 
    public boolean successfullyTransferedFunds {get; set;}
    
    // New/existing member information
    public String personNumber { get; set; }
    public String taxId { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String mobilePhone { get; set; }
    public String workPhone { get; set; }
    public Date birthDate { get; set; }
    public String idNumber { get; set; }
    public String idType { get; set; }
    public String idIssueState { get; set; }
    public Date idIssueDate { get; set; }
    public Date idExpiryDate { get; set; }
    public String mailingStreet { get; set; }
    public String mailingStreet2 { get; set; }
    public String mailingCity { get; set; }
    public String mailingState { get; set; }
    public String mailingPostalCode { get; set; }
    public String mailingCountryCode { get; set; }
    public Integer creditScore { get; set; }
    public String eligibilityResponse { get; set; }
    
    // Youth Specific information
    public String guardianPersonNumber { get; set; }
    public String guardianTaxId { get; set; }
    public String guardianFirstName { get; set; }
    public String guardianLastName { get; set; }
    public String guardianEmail { get; set; }
    public String guardianPhone { get; set; }
    public String guardianMobilePhone { get; set; }
    public String guardianWorkPhone { get; set; }
    public Date guardianBirthDate { get; set; }
    public String guardianIdNumber { get; set; }
    public String guardianIdType { get; set; }
    public String guardianIdIssueState { get; set; }
    public Date guardianIdIssueDate { get; set; }
    public Date guardianIdExpiryDate { get; set; }
    public String guardianMailingStreet { get; set; }
    public String guardianMailingStreet2 { get; set; }
    public String guardianMailingCity { get; set; }
    public String guardianMailingState { get; set; }
    public String guardianMailingPostalCode { get; set; }
    public String guardianMailingCountryCode { get; set; }
    public Integer guardianCreditScore { get; set; }
    
    // Product information
    public String productMajorCode { get; set; }
    public String productMinorCode { get; set; }
    public String productName { get; set; }
    public String promoCode { get; set; }
    
    // CRIF Specific Information
    public Decimal loanTotalAmount { get; set; }
    public List<String> loanErrors { get; set; }
    public List<String> loanApplicationIds { get; set; }
    public List<AOApplicationInfo.AOLoanApplication> loanApplications { get; set; }
    
    // Experian Precise ID Specific Information
    public List<AOExperianPreciseIDVerifyLogParser.AOAnswer> preciseIDAnswers { get; set; }
    
    // Form statuses
	public Boolean isComplete { get; set; }
	public Boolean isAbandoned { get; set; }
	public Boolean isError { get; private set; }
	public Boolean isFatalError { get; set; }
    public Map<String, AOInteractionResult> systemInteractionResults { get; set; }

	// sObject created for this application
    public Id caseId { get; set; }
    
    // Reports
    public Map<String, Object> creditReport;
    public Map<String, Object> kbaReport;
    public Map<String, Object> backgroundCheckReport;
    
    public AOApplicationInfo() {
		this.isJointApplication = false;
		this.isComplete = false;
		this.isAbandoned = false;
		this.isError = false;
		this.isFatalError = false;

        this.newAccounts = new List<DNAAccount>();
        this.errors = new List<String>();
        
		systemInteractionResults = new Map<String, AOInteractionResult>();
    }
    
    public void addExceptionError(String location, Exception e) {
        if (e == null) {
            System.debug('Exception was null');
            return;
        }
        
        addError(location, e.getMessage() + ' line: ' + e.getLineNumber());
    }

	public void addError(String location, String errorMessage) {
		if (location == null) {
            location = '';
        }
        
        this.errors.add(location + ': ' + errorMessage);
	}

	/**
	 * Inspects the the system interactions and parsing errors to determine if the overall state of
	 * this delivery is an error or not.
	 */
	public void detectErrorState() {
		// Determine if there are any system interactions that are in an error state or where the
		// decision is not accepted/approved.
		Boolean systemInteractionsSuccessful = true;
		for (AOInteractionResult result : this.systemInteractionResults.values()) {
			if (result.state == AOInteractionResult.State.Error || (
					result.systemDecision != 'Accept'
					&& result.systemDecision != 'Approve'
					&& result.systemDecision != 'Approved')
				)
			{
				systemInteractionsSuccessful = false;
			}
		}
		this.isError = !systemInteractionsSuccessful || isFatalError;
	}

}