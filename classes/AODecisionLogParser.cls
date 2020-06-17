public class AODecisionLogParser implements IAOPayloadParser {
    
    private static final String PRIMARY_APPLICANT = 'primaryApplicant';
    private static final String JOINT_APPLICANT = 'jointApplicant';
    
    
    public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        AOConstants.FormXmlVersion xmlVersion = (AOConstants.FormXmlVersion)payload.get(AOConstants.XML_VERSION);
        switch on xmlVersion {
            when V1 {
                parsePayloadV1(payload, appInfo);
            }
            when V2 {
                parsePayloadV2(payload, appInfo);
            }
            when else {
                parsePayloadDefault(payload, appInfo);
            }
        }
    }

    public void parsePayloadV1(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadV2(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadDefault(Map<String, Object> payload, AOApplicationInfo appInfo) {
        if (appInfo.isYouthApplication == null) { // Defensive measure.  It's set by the form parser, but causes hiccups for unit tests that don't set this.
            appInfo.isYouthApplication = false;
        }
        
        Dom.XmlNode decisionLogNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
        if (decisionLogNode == null) {
            throw new XmlException('DecisionLog node was not present.');
        }
        
        // Parse the JSON into the respective nodes for the child parsers to process.
        String decisionLogJSON = decisionLogNode.getText();
        Map<String, Object> decisionLogMap = (Map<String, Object>) JSON.deserializeUntyped(decisionLogJSON);

        if (appInfo.productMajorCode == AOConstants.PRODUCT_MAJOR_TYPE_CRIF || appInfo.isYouthApplication) { // CRIF has special handling where we need to parse both the applicant and co-applicant
            List<String> applicantNodeNames = new List<String> {PRIMARY_APPLICANT, JOINT_APPLICANT};
            
            for (String nodeName : applicantNodeNames) {
                Map<String, Object> applicantData = (Map<String, Object>)decisionLogMap.get(nodeName);
                
                if (applicantData == null) {
                    continue;
                }
                
                // Makes an entry unique in the appInfo and visually distinguishes them in the UI.
                String ownerPrefix = nodeName == PRIMARY_APPLICANT ? 'Applicant' : 'Co-Applicant';

                List<IAOPayloadParser> parsers = AODecisionLogSubparserFactory.getSubparsers(applicantData, ownerPrefix);

                for (IAOPayloadParser parser : parsers) {
                    //System.debug('Calling parsePayload for ' + String.valueOf(parser).split(':')[0]);
                    parser.parsePayload(applicantData, appInfo);
                }
            }
        } else { // Just parse the respective applicant (joint OR primary)
            // Verify the applicant node is present.
            String applicantNodeName = appInfo.isJointApplication ? JOINT_APPLICANT : PRIMARY_APPLICANT;
            Map<String, Object> applicantData = (Map<String, Object>)decisionLogMap.get(applicantNodeName);
            if (applicantData == null) {
                throw new XmlException('The ' + applicantNodeName + ' node is missing in DecisionLog.');
            }
            
            // Get the built list of parsers based on form code
            List<IAOPayloadParser> parsers = AODecisionLogSubparserFactory.getSubparsers(applicantData, null);
            
            for (IAOPayloadParser parser : parsers) {
                //System.debug('Calling parsePayload for ' + String.valueOf(parser).split(':')[0]);
                parser.parsePayload(applicantData, appInfo);
            }
        }
        
        
        
        // NOTE: Parse the top level decision node entries, if any.
        // appInfo.XXX = (String) decisionLogMap.txnStatus; // This is an example but is not needed at this time.
    }
    
}