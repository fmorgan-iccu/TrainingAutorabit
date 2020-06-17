public virtual class AOCRIFCreateAppDecisionLogParser extends AOSystemDecisionLogParser {
    /**
     * A NodePair object desribes a node's name and its namespace.
     */
    public class NodePair {
        public String nodeName { get; private set; }
        public String namespace { get; private set; }
        
        public NodePair(String nodeName, String namespace) {
            this.nodeName = nodeName;
            this.namespace = namespace;
        }
    }
    
    public override virtual String getSystemName() {
        return 'CreateApp';
    }
    
    public List<NodePair> subArray(List<NodePair> dataList, Integer startIndex) {
        List<NodePair> subArray = new List<NodePair>();
        for (Integer i = startIndex; i < dataList.size(); i++) {
            subArray.add(dataList[i]);
        }
        
        return subArray;
    }
    
    public override virtual AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;
        
        try {
            String xmlString = decisionLogEntry.everything;
            this.parseXML(xmlString, appInfo);

            if (appInfo.loanApplicationIds == null) {
                message = 'Application IDs not found.';
            } else {
                message = 'Application IDs: ' + appInfo.loanApplicationIds;
            }
            
            if (appInfo.loanErrors != null && appInfo.loanErrors.size() > 0) {
                message = message + '\nErrors:';

                for (String error : appInfo.loanErrors) {
                    message +=  error + ';';
                }
            }

            state = AOInteractionResult.State.SUCCESS;
        } catch(Exception e) {
            message = 'Unable to read CRIF application number: ' + e.getMessage() + ': ' + e.getLineNumber();
            state = AOInteractionResult.State.ERROR;
        }
        
        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
    
    @TestVisible
    private void parseXML(String xmlString, AOApplicationInfo appInfo) {
        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.load(xmlString);
        
        Dom.XmlNode envelope = xmlDoc.getRootElement();
        
        if (envelope == null) {
            return;
        }
        
        List<String> errors = this.getErrors(envelope);
        
        if (errors != null && errors.size() > 0) {
            appInfo.loanErrors = errors;
            return;
        }
        
        List<String> appIDs = this.getAppIds(envelope);
        appInfo.loanApplicationIds = appIDs;
        
        List<NodePair> applicationsPairs = new NodePair[]{
            new NodePair('Body', 'http://schemas.xmlsoap.org/soap/envelope/'),
            new NodePair('SubmitExResponse', 'http://tempuri.org/'),
            new NodePair('SubmitExResult', 'http://tempuri.org/'),
            new NodePair('body', 'BizTalkMessage'),
            new NodePair('actionAPI', ''),
            new NodePair('createApp', null),
            new NodePair('appImportResponse', 'Messages'),
            new NodePair('applications', 'Messages')
        };
        
        Dom.XmlNode applicationsNode =  this.recurseNode(envelope, applicationsPairs);
        Decimal totalAmount = 0.0;
        
        if (applicationsNode != null) {
            List<AOApplicationInfo.AOLoanApplication> apps = new List<AOApplicationInfo.AOLoanApplication>();
            
            for (Dom.XmlNode applicationNode : applicationsNode.getChildElements()) {
                if (applicationNode.getName() != 'application') {
                    continue;
                }
                
                AOApplicationInfo.AOLoanApplication app = new AOApplicationInfo.AOLoanApplication();
                app.amount = this.getAmount(applicationNode);
                this.getPropertyTypes(applicationNode, app);
                app.vin = this.getVIN(applicationNode);
                app.purchaseType = this.getPurchaseType(applicationNode);
                
                totalAmount += app.amount;
                
                apps.add(app);
            }
            
            appInfo.loanTotalAmount = totalAmount;
            appInfo.loanApplications = apps;
        }
    }

    public override virtual String getFriendlyName() {
        return 'CRIF ACTion - Create Application';
    }
    
    public virtual List<NodePair> getAppIdNodePairs() {
        List<NodePair> pairs = new NodePair[]{
            new NodePair('Body', 'http://schemas.xmlsoap.org/soap/envelope/'),
            new NodePair('SubmitExResponse', 'http://tempuri.org/'),
            new NodePair('SubmitExResult', 'http://tempuri.org/'),
            new NodePair('body', 'BizTalkMessage'),
            new NodePair('actionAPI', ''),
            new NodePair('createApp', null),
            new NodePair('appImportResponse', 'Messages'),
            new NodePair('appIDs', 'Messages')
		};

        return pairs;
    }
    
    public virtual List<NodePair> getErrorNodePairs() {
        List<NodePair> pairs = new NodePair[]{
            new NodePair('Body', 'http://schemas.xmlsoap.org/soap/envelope/'),
            new NodePair('SubmitExResponse', 'http://tempuri.org/'),
            new NodePair('SubmitExResult', 'http://tempuri.org/'),
            new NodePair('body', 'BizTalkMessage'),
            new NodePair('actionAPI', ''),
            new NodePair('createApp', null),
            new NodePair('errors', null)
		};

        return pairs;
    }
    
    /**
     * Encapsulates all the logic of digging into the XML to retrieve the list of App IDs.
     */
    private List<String> getAppIds(Dom.XmlNode rootNode) {
        List<NodePair> nodePairs = this.getAppIdNodePairs();
        
        Dom.XmlNode appIdNodes = this.recurseNode(rootNode, nodePairs);
        
        if (appIdNodes == null) {
            return null;
        }
        
        List<String> appIds = new List<String>();
        
        for (Dom.XmlNode node : appIdNodes.getChildElements()) {
            String appId = node.getText();
            
            if (appId != null) {
                appIds.add(appId);
            }
        }
        
        return appIds;
    }
    
    private Decimal getAmount(Dom.XmlNode applicationNode) {
        Decimal amount = 0.0;
        
        if (applicationNode == null) {
            return null;
        }
        
        Dom.XmlNode detailsNode = applicationNode.getChildElement('appDetails', 'App');

        if (detailsNode == null) {
            return null;
        }
        
        for (Dom.XmlNode detailsChild : detailsNode.getChildElements()) {
            List<NodePair> amountPairs = new NodePair[]{
            new NodePair('appDetailRequestedAmts', 'App'),
                new NodePair('appDetailRequestedAmt', 'App')
            };
                        
            Dom.XmlNode amountNode = this.recurseNode(detailsChild, amountPairs);
            
            if (amountNode == null) {
                continue;
            }
            
            String foundAmount = amountNode.getAttribute('requestedAmount', 'App');
            
            if (foundAmount == null || foundAmount.length() == 0) {
                continue;
            }
            
            amount += Decimal.valueOf(foundAmount);
        }
            
        return amount;
    }
    
    private void getPropertyTypes(Dom.XmlNode applicationNode, AOApplicationInfo.AOLoanApplication app) {
        if (applicationNode == null) {
            return;
        }
        
        Dom.XmlNode detailsNode = applicationNode.getChildElement('appDetails', 'App');
            
        if (detailsNode == null) {
            return;
        }
        
        for (Dom.XmlNode detailsChild : detailsNode.getChildElements()) {
            Dom.XmlNode detailProperties = detailsChild.getChildElement('appDetailProperties', 'App');
            
            if (detailProperties == null) {
                continue;
            }
            
            for (Dom.XmlNode detailProperty : detailProperties.getChildElements()) {
                Integer attributeCount = detailProperty.getAttributeCount();
                
                Map<String, String> attributes = APIUtils.parseXMLNodeAttributes(detailProperty);
                
                String propertyType = attributes.get('propertyType');
                if (propertyType != null && propertyType.length() > 0) {
                    app.propertyType = propertyType;
                }
                
                String propertySubType = attributes.get('propertySubType');
                if (propertySubType != null && propertySubType.length() > 0) {
                    app.propertySubType = propertySubType;
                }
                
            } // detailPoperty Loop
        } // detailsChild Loop
    }
    
    private String getVIN(Dom.XmlNode applicationNode) {
        if (applicationNode == null) {
            return null;
        }

        for (Dom.XmlNode appChild : applicationNode.getChildElements()) {
            if (appChild.getName() != 'vehicleValuations') {
                continue;
            }

            for (Dom.XmlNode valuationsChild : appChild.getChildElements()) {
                if (valuationsChild.getName() != 'vehicleValuation') {
                    continue;
                }
                
                Map<String, String> attributes = APIUtils.parseXMLNodeAttributes(valuationsChild);
                String vin = attributes.get('vin');
                
                if (vin != null && vin.length() > 0) {
                    return vin;
                }
            }
        }

        return null;
    }
    
    private String getPurchaseType(Dom.XmlNode applicationNode) {
        if (applicationNode == null) {
            return null;
        }

        Dom.XmlNode details = applicationNode.getChildElement('appDetails', 'App');

        if (details == null) {
            return null;
        }
        
        Dom.XmlNode appDetailVehicle = details.getChildElement('appDetailVehicle', 'App');
        
        if (appDetailVehicle == null) {
            return null;
        }
        
        Map<String, String> attributes = APIUtils.parseXMLNodeAttributes(appDetailVehicle);
        String purchaseType = attributes.get('requestType');

        return purchaseType;
    }
    
    @TestVisible
    private List<String> getErrors(Dom.XmlNode rootNode) {
        //System.debug('>>>>> Attempting to get errors.');
        List<NodePair> nodePairs = this.getErrorNodePairs();
        //System.debug('>>>> Node pairs: ' + nodePairs);
        
        Dom.XmlNode errorsNode = this.recurseNode(rootNode, nodePairs);
        
        if (errorsNode == null) {
            //System.debug('>>>>> No errors node found!');
            return new List<String>();
        }

        List<String> errors = new List<String>();
        
        for (Dom.XmlNode errorNode : errorsNode.getChildElements()) {
            String error = errorNode.getText();
            
            if (error != null) {
                errors.add(error);
            }
        }
        
        return errors;
    }    
    
    /**
     * Recursively walks a DOM tree to find a node outlined in the list of NodePair objects.
     */
    private Dom.XmlNode recurseNode(Dom.XmlNode node, List<NodePair> nodePairs) {
        if (node == null) {
            return null;
        }
        
        // We have arrived!
        if (nodePairs.size() == 0) {
            return node;
        }

        NodePair pair = nodePairs.get(0);
        Dom.XmlNode child = node.getChildElement(pair.nodeName, pair.namespace);
        
        List<NodePair> subArray = this.subArray(nodePairs, 1);
        
        return this.recurseNode(child, subArray);
    }
    
}