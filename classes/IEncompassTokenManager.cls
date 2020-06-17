public interface IEncompassTokenManager {
	EncompassToken getToken();
    void clearToken();
    void setToken(EncompassToken token);
}