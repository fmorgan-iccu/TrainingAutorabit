public class CDVerificationQuestionProvider implements IVerificationQuestionProvider {
    private List<IAccount> accounts;
    
    public CDVerificationQuestionProvider(List<IAccount> accounts) {
        this.accounts = accounts;
    }
    
    public List<PersonVerificationQuestion> createVerificationQuestions() {
        integer numberOfCDs = 0;

        for (IAccount account : this.accounts) {
            if (account.getMajorType().equals(DNAAccount.MJR_ACCT_CODE_CD)) {
                numberOfCDs += 1;
            }
        }

        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();

        if (numberOfCDs > 0) {
            PersonVerificationQuestion numberOfCDQuestion = new PersonVerificationQuestion('How many CDs do you have with us?', String.valueOf(numberOfCDs));
            questions.add(numberOfCDQuestion);
        }

        return questions;
    }
}