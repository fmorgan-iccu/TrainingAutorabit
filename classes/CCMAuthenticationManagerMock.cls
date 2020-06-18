@isTest
@TestVisible
private class CCMAuthenticationManagerMock implements IAuthenticationManager {

    public CCMAuthenticationManagerMock() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue('test token', UserSessionCache.CCM);
    }

    public boolean authenticateUser(IAuthenticationCredential credential) {
        return true;
    }
    
    public boolean isUserAuthenticated() {
        UserSessionCache sessionCache = new UserSessionCache();
        return sessionCache.getValue(UserSessionCache.CCM) != null;
    }
    
    public void logOut() {
        UserSessionCache sessionCache = new UserSessionCache();
        sessionCache.setValue(null, UserSessionCache.CCM);
    }
}