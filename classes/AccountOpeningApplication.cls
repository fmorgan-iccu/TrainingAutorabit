/**
 * Model object that represents an Account Opening Application that should be submitted.
 */
public class AccountOpeningApplication {
    private IPerson person;
    private AccountOpeningProduct product;

    public AccountOpeningApplication(IPerson person, AccountOpeningProduct product) {
        this.person = person;
        this.product = product;
    }

    public IPerson getPerson() {
        return this.person;
    }

    public AccountOpeningProduct getProduct() {
        return this.product;
    }
}