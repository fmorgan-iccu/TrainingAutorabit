@isTest
@TestVisible
private class DNAAuthenticationManagerMock implements IAuthenticationManager {

    public DNAAuthenticationManagerMock() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue('test ticket', UserSessionCache.DNA_TICKET);
    }

    public boolean authenticateUser(IAuthenticationCredential credential) {
        return true;
    }
    
    public boolean isUserAuthenticated() {
        UserSessionCache sessionCache = new UserSessionCache();
        return sessionCache.getValue(UserSessionCache.DNA_TICKET) != null;
    }
    
    public void logOut() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(null, UserSessionCache.DNA_TICKET);
    }
}