public class AOCRIFDecisionLogParser extends AOCRIFCreateAppDecisionLogParser {
        
    public override String getSystemName() {
        return 'CrifDecisioning';
    }
    
    public override List<NodePair> getAppIdNodePairs() {
        List<NodePair> pairs = new NodePair[]{
            new NodePair('Body', 'http://schemas.xmlsoap.org/soap/envelope/'),
			new NodePair('SubmitExResponse', 'http://tempuri.org/'),
            new NodePair('SubmitExResult', 'http://tempuri.org/'),
			new NodePair('body', 'BizTalkMessage'),
			new NodePair('actionAPI', ''),
			new NodePair('sendToDecisioning', null),
			new NodePair('appImportResponse', 'Messages'),
			new NodePair('appIDs', 'Messages')
        };
        
        return pairs;
    }
    
    public override String getFriendlyName() {
        return 'CRIF ACTion - Decisioning';
    }
    
    public override List<NodePair> getErrorNodePairs() {
        List<NodePair> pairs = new NodePair[]{
            new NodePair('Body', 'http://schemas.xmlsoap.org/soap/envelope/'),
            new NodePair('SubmitExResponse', 'http://tempuri.org/'),
            new NodePair('SubmitExResult', 'http://tempuri.org/'),
            new NodePair('body', 'BizTalkMessage'),
            new NodePair('actionAPI', ''),
            new NodePair('sendToDecisioning', null),
            new NodePair('errors', null)
		};

        return pairs;
    }
}