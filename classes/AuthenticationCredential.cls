/*
*	Class representing a username and password, implementing IAuthenticationCredential
*/
public with sharing class AuthenticationCredential implements IPasswordCredential {
    public String username { get; private set; }
    public String password { get; private set; }
    
    public String getUsername() {
        return this.username;
    }
    
    public String getPassword() {
        return this.password;
    }
    
    public AuthenticationCredential(String username, String password) {
        this.username = username;
        this.password = password;
    }    
}