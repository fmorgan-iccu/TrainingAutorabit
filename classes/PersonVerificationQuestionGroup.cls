/*
 *	Class representing a group of questions to ask a member.
 */
public with sharing class PersonVerificationQuestionGroup {
    private List<PersonVerificationQuestion> identifyingQuestions;
    private List<PersonVerificationQuestion> outOfWalletQuestions;
    private List<PersonVerificationQuestion> phonePasswordQuestions;
    
    public PersonVerificationQuestionGroup(List<PersonVerificationQuestion> identifyingQuestions, List<PersonVerificationQuestion> outOfWalletQuestions, List<PersonVerificationQuestion> phonePasswordQuestions) {
        this.identifyingQuestions = identifyingQuestions;
        this.outOfWalletQuestions = outOfWalletQuestions;
        this.phonePasswordQuestions = phonePasswordQuestions;
    }
    
    public List<PersonVerificationQuestion> getIdentifyingQuestions() {
        return this.identifyingQuestions;
    }
    
    public List<PersonVerificationQuestion> getOutOfWalletQuestions() {
        return this.outOfWalletQuestions; 
    }
    
    public List<PersonVerificationQuestion> getPhonePasswordQuestions() {
        return this.phonePasswordQuestions;
    }
}