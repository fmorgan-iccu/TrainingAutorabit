public class AOFormParser implements IAOPayloadParser {

    public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        // Retrieve the raw XmlForm in string format and construct an XPath parsers to assist
        // in extracting the appropriate nodes for each sub-parser.
        String xmlFormPayload = (String) payload.get(AOConstants.XML_FORM_KEY);
        if (xmlFormPayload == null) {
            throw new XmlException('Unable to find ' + AOConstants.XML_FORM_KEY);
        }
        XPath xpath = new XPath(xmlFormPayload);
        
        Boolean isYouthApplication = false;
        
        try {
            Dom.XmlNode parentNode = xpath.findFirst('/Root/AvokaSmartForm/Parent/ParentFName');
            isYouthApplication = (parentNode != null);
        } catch (Exception e) {
            // DO NOTHING AND CONTINUE
        }
        
        appInfo.isYouthApplication = isYouthApplication;

        AOConstants.FormXmlVersion xmlVersion = AOConstants.FormXmlVersion.V1;
        try {
            Dom.XmlNode versionNode = xpath.findFirst('/Root/xmlVersion');
            xmlVersion = AOConstants.getFormXmlVersion(versionNode.getText());
        } catch(Exception e) {
            System.debug('The xmlVersion not found');
        }
        System.debug('[AOFormParser] xmlVersion: ' + xmlVersion);

		// Validate the XML document contains the AvokaSmartForm node.  It it doesn't, the entire
		// XML document will be considered invalid.
        Dom.XmlNode smartFormNode = xpath.findFirst('/Root/AvokaSmartForm');
        if (smartFormNode == null) {
            throw new XmlException('Unable to find AvokaSmartForm');
        }

		// Determine if the application is for an applicant or a joint applicant.
		Dom.XmlNode isJointFlowNode = xpath.findFirst('/Root/AvokaSmartForm/isJointFlow');
        Map<String, Object> jointPayload = new Map<String, Object>();
        jointPayload.put(AOConstants.XML_NODE_KEY, isJointFlowNode);
        jointPayload.put(AOConstants.XML_VERSION, xmlVersion);
   
        AOJointApplicationParser jointParser = new AOJointApplicationParser();
        jointParser.parsePayload(jointPayload, appInfo);

		// Identify the applicant
        if (appInfo.isYouthApplication) {
            String youthApplicantXPath = '/Root/AvokaSmartForm/Applicant';
            String guardianApplicantXPath = '/Root/AvokaSmartForm/Parent';
            
            Dom.XmlNode youthNode = xpath.findFirst(youthApplicantXPath);
            Dom.XmlNode guardianNode = xpath.findFirst(guardianApplicantXPath);
            
            if (youthNode != null && guardianNode != null) {
                Map<String, Object> applicantPayload = new Map<String, Object>();
                applicantPayload.put(AOConstants.XML_YOUTH_APPLICANT_KEY, youthNode);
                applicantPayload.put(AOConstants.XML_GUARDIAN_APPLICANT_KEY, guardianNode);
                applicantPayload.put(AOConstants.XML_VERSION, xmlVersion);
                AOApplicantParser applicantParser = new AOApplicantParser();
                applicantParser.parsePayload(applicantPayload, appInfo);
            }
        } else {
            Dom.XmlNode applicantNode = xpath.findFirst('/Root/AvokaSmartForm/Applicant');
            Dom.XmlNode triageApplicantNode = xpath.findFirst('/Root/AvokaSmartForm/Triage/Applicant');
            if (applicantNode != null || triageApplicantNode != null) {
                Map<String, Object> applicantPayload = new Map<String, Object>();
                applicantPayload.put(AOConstants.XML_APPLICANT_KEY, applicantNode);
                applicantPayload.put(AOConstants.XML_TRIAGE_APPLICANT_KEY, triageApplicantNode);
                applicantPayload.put(AOConstants.XML_VERSION, xmlVersion);
                AOApplicantParser applicantParser = new AOApplicantParser();
                applicantParser.parsePayload(applicantPayload, appInfo);
            }
        }
        
        // Identify the AccountsFunding
        Dom.XmlNode accountsFundingNode = xpath.findFirst('/Root/AvokaSmartForm/AccountsFunding');
        if (accountsFundingNode != null) {                           
            Map<String, Object> accountsFundingPayload = new Map<String, Object>();
            accountsFundingPayload.put(AOConstants.XML_NODE_KEY, accountsFundingNode);
            accountsFundingPayload.put(AOConstants.XML_VERSION, xmlVersion);
            AOAccountFundingParser accountFundingParser = new AOAccountFundingParser();
            accountFundingParser.parsePayload(accountsFundingPayload, appInfo);		
        }

        // Identify the product that the applicant has selected, if any.
        String productSelectionXPath = '/Root/AvokaSmartForm/TriageFlow/ProductSelection';
        
        Dom.XmlNode productSelectionNode = xpath.findFirst(productSelectionXPath);
        if (productSelectionNode != null) {
			Map<String, Object> productPayload = new Map<String, Object>();
			productPayload.put(AOConstants.XML_NODE_KEY, productSelectionNode);
            productPayload.put(AOConstants.XML_VERSION, xmlVersion);
			AOProductParser productParser = new AOProductParser();
			productParser.parsePayload(productPayload, appInfo);
		}
        
        // Identify the decision that Avoka has made
        String decisionLogXpath = '/Root/AvokaSmartForm/DecisionLog';
        if (xmlVersion == AOConstants.FormXmlVersion.V2) {
            decisionLogXpath = '/Root/ServiceData/DecisionLog';
        }
        System.debug('[AOFormParser] decisionLogXpath: ' + decisionLogXpath);
        Dom.XmlNode decisionLogNode = xpath.findFirst(decisionLogXpath);
        System.debug('[AOFormParser] decisionLogNode: ' + decisionLogNode.getText());
        Map<String, Object> decisionPayload = new Map<String, Object>();
        decisionPayload.put(AOConstants.XML_NODE_KEY, decisionLogNode);
        decisionPayload.put(AOConstants.XML_VERSION, xmlVersion);
        AODecisionLogParser decisionLogParser = new AODecisionLogParser();
        decisionLogParser.parsePayload(decisionPayload, appInfo);

        // Identify the current smart form link.
        // Only used for the normal flow
        Dom.XmlNode smartFormJobNode = xpath.findFirst('/Root/AvokaSmartForm/SFMData/SystemProfile/Job');
        if (smartFormJobNode != null) {
			Map<String, Object> jobPayload = new Map<String, Object>();
			jobPayload.put(AOConstants.XML_NODE_KEY, smartFormJobNode);
            jobPayload.put(AOConstants.XML_VERSION, xmlVersion);
			AOJobParser jobParser = new AOJobParser();
			jobParser.parsePayload(jobPayload, appInfo);
		}
        
        // Identify the promo code, if present
        Dom.XmlNode promoCodeNode = xpath.findFirst('/Root/AvokaSmartForm/PromoCode');
        if (promoCodeNode != null) {
            Map<String, Object> promoPayload = new Map<String, Object>();
            promoPayload.put(AOConstants.XML_NODE_KEY, promoCodeNode);
            promoPayload.put(AOConstants.XML_VERSION, xmlVersion);
            AOPromoCodeParser jobParser = new AOPromoCodeParser();
            jobParser.parsePayload(promoPayload, appInfo);
        }

		// Identify if a fatal error has occurred.
		Dom.XmlNode fatalErrorNode = xpath.findFirst('/Root/AvokaSmartForm/SFMData/NarrativeMeta/FatalError');
        if (fatalErrorNode != null) {
			Map<String, Object> fatalErrorPayload = new Map<String, Object>();
            fatalErrorPayload.put(AOConstants.XML_NODE_KEY, fatalErrorNode);
            fatalErrorPayload.put(AOConstants.XML_VERSION, xmlVersion);
            AOFatalErrorParser fatalErrorParser = new AOFatalErrorParser();
            fatalErrorParser.parsePayload(fatalErrorPayload, appInfo);
        }
        
        // Pull out the custom info, if present.
        Dom.XmlNode rootNode = xpath.findFirst('/Root');
        if (rootNode != null) {
            Map<String, Object> customPayload = new Map<String, Object>();
            customPayload.put(AOConstants.XML_NODE_KEY, rootNode);
            customPayload.put(AOConstants.XML_VERSION, xmlVersion);
            AOCustomInfoParser customParser = new AOCustomInfoParser();
            customParser.parsePayload(customPayload, appInfo);
        }
    }

    private void parseBaseFields(Dom.XmlNode rootNode, AOApplicationInfo appInfo) {
    }
    
}