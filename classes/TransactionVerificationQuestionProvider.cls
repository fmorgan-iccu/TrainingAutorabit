public class TransactionVerificationQuestionProvider implements IVerificationQuestionProvider {
	private List<IAccount> accounts;
    private PersonVerificationConfiguration verificationConfiguration;
    
    public TransactionVerificationQuestionProvider(List<IAccount> accounts, PersonVerificationConfiguration verificationConfiguration) {
        this.accounts = accounts;
        this.verificationConfiguration = verificationConfiguration;
    }
    
    public List<PersonVerificationQuestion> createVerificationQuestions() {
        Map<String, DNAMerchantTransaction> frequentTransactions = new Map<String, DNAMerchantTransaction>();
        
        List<String> latestTransactionAnswers = new List<String>();
        List<String> latestCheckAnswers = new List<String>();
        List<String> latestWithdrawalAnswers = new List<String>();
        
        for (IAccount account : this.accounts) {
            boolean isChecking = account.getMajorType().equals(DNAAccount.MJR_ACCT_CODE_CHECKING);
            boolean isCreditCard = account.getMajorType().equals(DNAAccount.MJR_ACCT_CODE_CREDIT_CARD);
            
            IAccountTransaction latestCheck = null;
            IAccountTransaction latestWithdrawal = null;
            
            String accountName = account.getPreferredName();
            List<IAccountTransaction> transactions = account.getTransactions();

            if (transactions == null || transactions.size() == 0) {
                continue;
            }

            // Getting latest check for the account
            // Merchant Volume: We're going to take the merchant description and surface those that have a greater frequency on an account
            // Recent Transactions: Getting the most recent transactions for checking and credit cards
            for (IAccountTransaction trans : transactions) {
                if (isChecking || isCreditCard) {
                    // Fishing out checks
                    if (isChecking) {
                        if (trans.getCheckNumber() != null) {
                            if (latestCheck == null || trans.getEffectiveDate() > latestCheck.getEffectiveDate()) {
                                latestCheck = trans;
                            } else {
                                // skip this check
                            }
                        }
                    }

                    String externalDesc = trans.getExternalDescription();
                    
                    // No need to operate on null/empty description, or if this is a credit transaction
                    if (externalDesc == null || externalDesc.length() == 0 || trans.getIsCredit() == true) {
                        continue;
                    }
                    
                    DNAMerchantTransaction merchTrans = frequentTransactions.get(externalDesc);
                    
                    if (merchTrans == null) {
                        merchTrans = new DNAMerchantTransaction(externalDesc, 0);
                    }
                    
                    merchTrans.setCount(merchTrans.getCount() + 1);
                    
                    frequentTransactions.put(externalDesc, merchTrans);
                }
                
                // Getting withdrawals
                if (trans.getTypeCode() != null && trans.getTypeCode().equals('WTH')) {
                    if (latestWithdrawal == null || latestWithdrawal.getPostDate() < trans.getPostDate()) {
                        latestWithdrawal = trans;
                    }
                }
            }
            
            // Getting most recent transactions
            integer transCount = this.verificationConfiguration.getNumberOfRecentTransactionsToFetch();
            List<IAccountTransaction> transSubset = new List<IAccountTransaction>();
            if (transactions.size() > transCount) {
                integer startIndex = transactions.size() - transCount;
                for (integer i = startIndex; i < transactions.size(); i++) {
                    IAccountTransaction trans = transactions.get(i);
                    transSubset.add(trans);
                }
            } else {
                transSubset.addAll(transactions);
            }
            
            // No need to sub-array if it doesn't have any transactions.
            if (transSubset.size() > 0) {
                latestTransactionAnswers.add(accountName);
                
                for (IAccountTransaction trans : transSubset) {
                    String externalDescription = trans.getExternalDescription();
                    
                    if (externalDescription == null || externalDescription.length() == 0) {
                        continue;
                    }
                    
                    String postDate = trans.getPostDate().format(DateUtils.DATE_FORMAT);
                    latestTransactionAnswers.add(postDate);
                    String formattedAmount = NumberUtils.formatCurrency(trans.getAmount());
                    String answer = externalDescription + ' | ' + formattedAmount;
                    latestTransactionAnswers.add(answer);
                    latestTransactionAnswers.add('');
                }
                
                latestTransactionAnswers.add(''); // Spacer in UI
            }
            
            if (latestCheck != null) {
                String formattedAmount = NumberUtils.formatCurrency(latestCheck.getAmount());
                String checkNumberAnswer = account.getAccountNumber() + ' | ' + accountName + ' | ' + latestCheck.getCheckNumber() + ' | ' + formattedAmount;
                latestCheckAnswers.add(checkNumberAnswer);
            }
            
            if (latestWithdrawal != null) {
                String formattedAmount = NumberUtils.formatCurrency(latestWithdrawal.getAmount());
                String withdrawalAnswer = latestWithdrawal.getPostDate().format(DateUtils.DATE_FORMAT) + ' | ' + formattedAmount;
                latestWithdrawalAnswers.add(accountName);
                latestWithdrawalAnswers.add(withdrawalAnswer);
                latestWithdrawalAnswers.add('');
            }
        }
        
        // Sorting and grouping frequent transactions
        List<String> frequentMerchantsAnswers = new List<String>();
        List<String> frequentTransAnswers = new List<String>();
        List<DNAMerchantTransaction> sortedMerchTrans = new List<DNAMerchantTransaction>(frequentTransactions.values());
        sortedMerchTrans.sort();
        integer thresholdCount = verificationConfiguration.getMerchantFrequencyThresholdCount(); // Gotta have more than this number of transactions to be considered
        for (DNAMerchantTransaction merchTrans : sortedMerchTrans) {
            if (merchTrans.getCount() >= thresholdCount) {
                String answer = '(' + merchTrans.getCount() + ') | ' + merchTrans.getDescription();
                frequentMerchantsAnswers.add(answer);
            }
        }
        
        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();
        
        if (frequentMerchantsAnswers.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('Which merchants have you visited most frequently in the past month?', frequentMerchantsAnswers);
            questions.add(question);
        }
        
        if (latestTransactionAnswers.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('Ask a question related to their most recent transactions, such as: You went out to eat two days ago.  Where was it at?', latestTransactionAnswers);
            questions.add(question);
        }
        
        if (latestCheckAnswers.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('What is the check number -OR- amount of the latest check that has cleared?', latestCheckAnswers);
            questions.add(question);
        }
        
        if (latestWithdrawalAnswers.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('What was the amount of your latest withdrawl?', latestWithdrawalAnswers);
            questions.add(question);
        }
        
        return questions;
    }
}