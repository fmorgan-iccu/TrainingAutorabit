public class LoanVerificationQuestionProvider implements IVerificationQuestionProvider {
	private List<IAccount> accounts;
    
    public LoanVerificationQuestionProvider(List<IAccount> accounts) {
        this.accounts = accounts;
    }
    
    public List<PersonVerificationQuestion> createVerificationQuestions() {
        List<String> nextDueDateAnswers = new List<String>();
        
        for (IAccount account : this.accounts) {
            if (account.getNextPaymentDate() != null) {
				DateTime nextDate = account.getNextPaymentDate();
                String formattedDate = nextDate.format(DateUtils.DATE_FORMAT);
                String accountName = account.getPreferredName();

                String answer = account.getAccountNumber() + ' - ' + accountName + ' - ' + formattedDate;
                nextDueDateAnswers.add(answer);
            }
        }
        
        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();
        
        if (nextDueDateAnswers.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('When is the next due date of your loan?', nextDueDateAnswers);
            questions.add(question);
        }
        
        return questions;
    }
}