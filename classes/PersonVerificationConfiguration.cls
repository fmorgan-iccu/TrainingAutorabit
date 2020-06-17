/**
 * Class that encapsulates all of the details for configuring parameters for obtaining verification questions for members.
 * Property Descriptions:
 * 
 * acceptableJointRoleCodes - The DNA roles that qualify for questions related to roles on joint accounts.
 * merchantFrequencyThresholdCount - The mimimum number of transactions in the given period to qualify for being 'frequent'
 * numberOfRecentTransactionsToFetch - The maximum number of transactions to return for some questions
 * transactionEndDate - The end date of the search criteria for obtaining transactions
 * transactionStartDate - The start date of the search criteria for obtaining transactions
 */
public class PersonVerificationConfiguration {
    private List<String> acceptableJointRoleCodes;
    private integer merchantFrequencyThresholdCount;
    private integer numberOfRecentTransactionsToFetch;
	private DateTime transactionEndDate;
    private DateTime transactionStartDate;

    public PersonVerificationConfiguration(List<String> acceptableJointRoleCodes, integer merchantFrequencyThresholdCount, integer numberOfRecentTransactionsToFetch, DateTime transactionEndDate, DateTime transactionStartDate) {
        this.acceptableJointRoleCodes = acceptableJointRoleCodes;
        this.merchantFrequencyThresholdCount = merchantFrequencyThresholdCount;
        this.numberOfRecentTransactionsToFetch = numberOfRecentTransactionsToFetch;
        this.transactionEndDate = transactionEndDate;
        this.transactionStartDate = transactionStartDate;
    }

    public List<String> getAcceptableJointRoleCodes() {
        return this.acceptableJointRoleCodes;
    }

    public integer getMerchantFrequencyThresholdCount() {
        return this.merchantFrequencyThresholdCount;
    }
    
    public integer getNumberOfRecentTransactionsToFetch() {
        return this.numberOfRecentTransactionsToFetch;
    }

    public DateTime getTransactionEndDate() {
        return this.transactionEndDate;
    }

    public DateTime getTransactionStartDate() {
        return this.transactionStartDate;
    }
}