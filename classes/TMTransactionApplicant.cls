public class TMTransactionApplicant {
    private String email;
    private String firstName;
    private String lastName;
    private String routeName;
    
    public TMTransactionApplicant(String email, String firstName, String lastName, String routeName) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.routeName = routeName;
    }
    
    public String getEmail() {
        return this.email;
    }
    
    public String getFirstName() {
        return this.firstName;
    }
    
    public String getLastName() {
        return this.lastName;
    }
    
    public String getRouteName() {
        return this.routeName;
    }
}