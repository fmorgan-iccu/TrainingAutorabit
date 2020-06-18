@isTest
private class TMTransactionApplicantTest {
    @isTest
    private static void testHappyPath() {
        String email = 'email';
        String firstName = 'firstName';
        String lastName = 'lastName';
        String routeName = '66';

        TMTransactionApplicant applicant = new TMTransactionApplicant(email, firstName, lastName, routeName);
        System.assert(email.equals(applicant.getEmail()));
        System.assert(firstName.equals(applicant.getFirstName()));
        System.assert(lastName.equals(applicant.getLastName()));
        System.assert(routeName.equals(applicant.getRouteName()));
    }
}