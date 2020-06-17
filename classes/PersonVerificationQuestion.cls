/*
 *	Class representing a verification question to ask a member. 
 */
public with sharing class PersonVerificationQuestion {
    private String question;
    private List<String> answers;

    public PersonVerificationQuestion(String question, String answer) {
    		this.question = question;
    		List<String> answers = new List<String>();
    		answers.add(answer);
    		
    		this.answers = answers;
    }
    
    public PersonVerificationQuestion(String question, List<String> answers) {
    		this.question = question;
    		this.answers = answers;
    }
    
    public String getQuestion() {
    		return this.question;
    }

	/*
	 *	Convenience getter for the first question
	 */    
    public String getAnswer() {
    		if (this.answers == null || this.answers.size() == 0) {
    			return null;
    		}

    		return this.answers[0];
    }
    
    public List<String> getAnswers() {
    		return this.answers;
    }
}