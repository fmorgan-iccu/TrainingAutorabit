public interface IAOPayloadParser {
    
    void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo);
    
}