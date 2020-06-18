/*
 *	Class that represents a username/password credential for DNA 
 */
public with sharing class DNAAuthenticationCredential implements IPasswordCredential {
    private String username;
    private String password;
    
    public DNAAuthenticationCredential(String username, String password) {
        this.username = username;
        this.password = password;
    }
    
    public String getUsername() {
        return this.username;
    }
    
    public String getPassword() {
        return this.password;
    }
}