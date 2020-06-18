/**
 * Model object representing a recipient on an eSignature process.
 */
public class ESignRecipient {
    /**
     * id The unique identifier of the recipient
     */
    public String id { get; private set; }

    /**
     * name The full name of the individual
     */
    public String name { get; private set; }

    /**
     * email The email address of the individual
     */
    public String email { get; private set; }

    /**
     * role The role of the individual on the template
     */
    public String role { get; private set; }
    
    /**
     * data The data of the recipient to be displayed on a template
     */
    public ESignData data { get; private set; }

    public ESignRecipient(String id, String name, String email, String role, ESignData data) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.data = data;
    }
}