public interface IPasswordCredential extends IAuthenticationCredential {
	String getUsername();
    String getPassword();
}