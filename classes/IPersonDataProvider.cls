/*
 *	Interface for describing a class that accesses person details.
 */
public interface IPersonDataProvider {
    IPerson getPersonDetails(String personNumber);
    List<IPerson> getPersonDetails(List<String> personNumbers);
    List<IPersonWarningFlag> getPersonWarningFlags(String personNumber);
    List<PersonVerificationQuestion> getPhonePassword(String personNumber);
    PersonVerificationQuestionGroup getVerificationQuestions(IPerson person, PersonVerificationConfiguration verificationConfiguration);
    String getProviderName();
    IAuthenticationManager getAuthenticationManager();
    void updatePersonPhonePassword(IPerson person, String password, String passwordHint);
	IPerson updatePersonContactInfo(IPerson person, List<IAddress> addresses, List<PhoneNumber> phoneNumbers, List<EmailAddress> emailAddresses);
}