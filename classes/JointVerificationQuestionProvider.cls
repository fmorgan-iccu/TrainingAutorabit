public class JointVerificationQuestionProvider implements IVerificationQuestionProvider {
	private List<IAccount> accounts;
    private IPersonDataProvider personDataProvider;
    private PersonVerificationConfiguration verificationConfiguration;
    
    public JointVerificationQuestionProvider(List<IAccount> accounts, PersonVerificationConfiguration verificationConfiguration, IPersonDataProvider personDataProvider) {
        this.accounts = accounts;
        this.verificationConfiguration = verificationConfiguration;
        this.personDataProvider = personDataProvider;
    }
    
    public List<PersonVerificationQuestion> createVerificationQuestions() {
        List<PersonVerificationQuestion> questions = new List<PersonVerificationQuestion>();
        
        List<String> dobList = new List<String>();
        Set<String> joints = new Set<String>();

        for (IAccount account : this.accounts) {
            String accountName = account.getPreferredName();
            
            List<String> roleCodes = this.verificationConfiguration.getAcceptableJointRoleCodes();
            
            // For Joint and POD question
            for (IJointAccountOwner joint : account.getJointOwners()) {
                if (joint.isOrg()) {
                    continue;
                }

                for (String roleCode : roleCodes) {
                    if (roleCode.equals(joint.getRoleCode())) {
                        String accountAnswer = account.getAccountNumber() + ' - ' + accountName;
                        String personAnswer = joint.getFullName() + ' (' + roleCode + ')';
                        String lineBreakAnswer = '';
                        
                        // For getting joint owners and their date of birth
                        String personNumber = joint.getEntityNumber();
                        joints.add(personNumber);
                    }
                }
            }
        }
        
        if (joints.size() > 0) {
            List<IPerson> people = personDataProvider.getPersonDetails(new List<String>(joints));
            
            for (IPerson jointPerson : people) {
                DateTime dob = (DateTime)jointPerson.getDateOfBirth();

                String formattedDOB = ''; // Fix for super-rare issue where DOB is null...

                if (dob != null) {
                    formattedDOB = dob.formatGmt(DateUtils.DATE_FORMAT);
                }

                String firstName = jointPerson.getFirstName();

                if (jointPerson.getPreferredName() != null) {
                    firstName = jointPerson.getPreferredName();
                }
                
                String answer = firstName + ' ' + jointPerson.getLastName() + ' - ' + formattedDOB;
                dobList.add(answer);
                dobList.add(''); // Adds line break
            }
        }
        
        if (dobList.size() > 0) {
            PersonVerificationQuestion question = new PersonVerificationQuestion('What is the Joint Owner\'s DOB?', dobList);
            questions.add(question);
        }

        return questions;
    }
}