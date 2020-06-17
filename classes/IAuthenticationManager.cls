/*
 *	Interface for a class that manages authentication for a data resource.
 */
public interface IAuthenticationManager {
	boolean authenticateUser(IAuthenticationCredential credential);
	boolean isUserAuthenticated();
	void logOut();
}