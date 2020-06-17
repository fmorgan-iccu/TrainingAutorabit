public class AOAccountFundingParser implements IAOPayloadParser {

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
		// /root/AvokaSmartForm/AccountsFunding/
        Dom.XmlNode accountsFunding = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
        
        if (accountsFunding == null) {
            throw new XmlException('AccountsFunding node not found in payload.');
        }
		Dom.XmlNode[] fundingElements = accountsFunding.getChildElements();
		if (fundingElements == null) {
            throw new XmlException('AccountsFunding node elements not found in payload.');
        }
		try {
			for (Dom.XmlNode fundingElement : fundingElements) {
				String nodeName = fundingElement.getName();
				String nodeText = fundingElement.getText();

				// Verify that the node contains data that can be converted or deserialized.
				if (String.isBlank(nodeText)) {
					continue;
				}

				switch on nodeName {                
					when 'PropayPaymentType' {
						appInfo.propayPaymentType = nodeText;
					}
					when 'UsingPropay' {
						appInfo.usingProPay = boolean.valueOf(nodeText);                    
					}
					when 'TotalFundAmount' {
						appInfo.totalFundAmount = Double.valueOf(nodeText);
					}
					when 'FundJson' {
						// have to cast to object first, then map string, object due to APEX limitations
						List<Object> objectList = (List<Object>) JSON.deserializeUntyped(nodeText);        
						List<Map<String, Object>> accountFundings = new List<Map<String, Object>>();        
						for (Object obj : objectList) {
							accountFundings.add((Map<String, Object>)obj);
						}                
						
						// set funding amount as the balance for the new DNAAccount
						for (Map<String, Object> accountFunding : accountFundings) {
							for (IAccount account : appInfo.newAccounts) {
								if (account.getAccountNumber() == accountFunding.get('AccountNumberTo')) {
									boolean isDNAAccount = account instanceof DNAAccount;

									if (!isDNAAccount) {
										continue;
									}

									DNAAccount dnaAccount = (DNAAccount)account;
									dnaAccount.setAvailableBalance((Double)accountFunding.get('FundAmount'));
								}
							}
						}                                        
					}
					when else {
						// No match do nothing. Else block is not required, but recommended by sf.
						system.debug('Unexpected nodeName: ' + nodeName);                   
					}                                                                                                  
				}
			}
		} catch (Exception e) {
			appInfo.addExceptionError('AOAccountFundingParser', e);
		}
    }
}