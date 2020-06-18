public class CDVerificationQuestionProvider implements IVerificationQuestionProvider {
    private List<IAccount> accounts;
    private String personNumber;

    public CDVerificationQuestionProvider(String personNumber, List<IAccount> accounts) {
        this.accounts = accounts;
        this.personNumber = personNumber;
    }

    public List<PersonVerificationQuestion> createVerificationQuestions() {
        integer numberOfCDs = 0;

        for (IAccount account : this.accounts) {
            if (account.getMajorType().equals(DNAAccount.MJR_ACCT_CODE_CD)) {
                // Find CD accounts we are Owner on
                for (IJointAccountOwner joint : account.getJointOwners()) {
                    String roleCode = joint.getRoleCode();
                    String entityNumber = joint.getEntityNumber();

                    if (roleCode.equals('OTAX') && entityNumber.equals(personNumber)) {
                        numberOfCDs += 1;
                    }
                }
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