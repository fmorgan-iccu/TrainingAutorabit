public class AOApplicationInfo {

    public String applicationId { get; set; }
    public Id caseId { get; set; }

    public List<String> errors { get; private set; }

    // Data received by the rest interface
    public AOApplicationRestRequest appRequest { get; set; }

    // Funding delivery information
    public Boolean successfullyTransferedFunds {get; set;}

    // CRIF ACTion delivery information
    public Decimal loanTotalAmount { get; set; }
    public List<String> loanErrors { get; set; }
    public List<String> loanApplicationIds { get; set; }
    public List<AOApplicationInfo.AOLoanApplication> loanApplications { get; set; }

    public class AOLoanApplication {
        public Decimal amount { get; set; }
        public String propertyType { get; set; }
        public String propertySubType { get; set; }
        public String purchaseType { get; set; }
        public String vin { get; set; }
    }

    // Experian Precise ID Specific Information
    public List<AOExperianPreciseIDVerifyLogParser.AOAnswer> preciseIDAnswers { get; set; }

    // Account opening system responses parsed into a standard format.
    public Map<String, AOInteractionResult> systemInteractionResults { get; set; }

    // Reports
    public Map<String, Object> creditReport;
    public Map<String, Object> kbaReport;
    public Map<String, Object> backgroundCheckReport;


    public AOApplicationInfo(AOApplicationRestRequest appRequest) {
        this.appRequest = appRequest;
        this.applicationId = appRequest != null ? appRequest.application_id : null;
        this.errors = new List<String>();
        systemInteractionResults = new Map<String, AOInteractionResult>();
    }

    // Convenience function to check for the types of applications.
    public Boolean isYouthApplication() {
        return appRequest.form.type == AOConstants.FORM_YOUTH;
    }
    public Boolean isError() {
        return this.errors.size() > 0;
    }

    // Convenience method for converting the REST account format to an IAccount.
    public List<IAccount> getOpenedAccounts() {
        List<DNAAccount> accounts = new List<DNAAccount>();
        if (appRequest.funding_info == null || appRequest.funding_info.opened_accounts == null) {
            return accounts;
        }
        List<AOApplicationRestRequest.OpenedAccount> openedAccounts = appRequest.funding_info.opened_accounts;
        for (AOApplicationRestRequest.OpenedAccount openedAccount : openedAccounts) {
            if (openedAccount.account.account_number != null) {
                AOApplicationRestRequest.FinancialAccount fa = openedAccount.account;
                AOApplicationRestRequest.FinancialProduct fp = fa.product;
                String accountName = fa.nickname != null ? fa.nickname : fp.product_name;
                DNAAccount a = new DNAAccount(fa.account_number,
                    fa.available_balance != null ? fa.available_balance : fa.balance,
                    null, // Branch name
                    fa.balance,
                    fa.rate != null ? fa.rate.interest_rate : null,
                    null, // Joint owners
                    fp != null ? fp.major_type : null,
                    fp != null ? fp.minor_type : null,
                    accountName,
                    fa.nickname,
                    fa.status);
                accounts.add(a);
            }
        }
        return accounts;
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
        for (AOInteractionResult result : this.systemInteractionResults.values()) {
            if (result.state == AOInteractionResult.State.Error || (
                    result.systemDecision != 'Accept'
                    && result.systemDecision != 'Approve'
                    && result.systemDecision != 'Approved')
                )
            {
                this.addError('System Interaction', 'One or more system processes was not successful.');
                break;
            }
        }
    }

}