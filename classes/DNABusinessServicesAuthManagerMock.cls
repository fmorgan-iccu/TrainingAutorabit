@isTest
@TestVisible
private class DNABusinessServicesAuthManagerMock implements IAuthenticationManager {

    public DNABusinessServicesAuthManagerMock() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue('test token', UserSessionCache.DNA_TOKEN);
    }

    public boolean authenticateUser(IAuthenticationCredential credential) {
        return true;
    }
    
    public boolean isUserAuthenticated() {
        UserSessionCache sessionCache = new UserSessionCache();
        return sessionCache.getValue(UserSessionCache.DNA_TOKEN) != null;
    }
    
    public void logOut() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(null, UserSessionCache.DNA_TOKEN);
    }

}