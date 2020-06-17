/**
 *	Authentication manager for authenticating with CRIF Action.  Since Action is not secured with credentials, the implementation of this class will be pretty bare...
 */
public with sharing class CRIFActionAuthenticationManager implements IAuthenticationManager {
    public boolean authenticateUser(IAuthenticationCredential credential) {
    		return true;
    }

	public boolean isUserAuthenticated() {
		return true;		
	}
	
	public void logOut() {
		// DO NOTHING
	}
}