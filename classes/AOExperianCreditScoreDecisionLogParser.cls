public class AOExperianCreditScoreDecisionLogParser extends AOSystemDecisionLogParser {
    private static final String creditScoreRegex = 'Score:\\s(\\d{1,4})'; // Uses 'Score: ' to help match, but not capture.
    private static final Pattern creditScorePattern = Pattern.compile(creditScoreRegex);

    public override String getSystemName() {
        return 'ExperianCreditScore';
    }
    
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
		String message = null;
		AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;
        
		try {
            String everything = decisionLogEntry.everything;

            if (everything.contains('found in SFDC Contact')) { // Situation where they are getting the score directly from SF.
                Matcher matcher = creditScorePattern.matcher(everything);

                if (matcher.find() && matcher.groupCount() == 1) {  // Sanity check to make sure that we actually got something...
                    String match = matcher.group(1);
                    
                    Integer creditScore = Integer.valueOf(match);
                    appInfo.creditScore = creditScore;
                    
                    message = everything.trim();
                    state = AOInteractionResult.State.SUCCESS;
                    return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
                }
            }

            try { 
                String xmlString = everything;
                XPath xpath = new XPath(xmlString);
                
				// Find the V3 risk model credit score
				String creditScore = null;
				Dom.XmlNode[] modelIndicatorNode = xpath.find('/NetConnectResponse/Products/CreditProfile/RiskModel/ModelIndicator[@code=V3]');
				if (modelIndicatorNode != null) {
					Dom.XmlNode riskModelNode = modelIndicatorNode[0].getParent();
					if (riskModelNode != null) {
						Dom.XmlNode scoreNode = riskModelNode.getChildElement('Score', 'http://www.experian.com/ARFResponse');
						if (scoreNode != null) {
							creditScore = scoreNode.getText();
						}
					}
				}
                
                if (creditScore == null) {
                    return this.notPresentResult('Unable to find credit score in payload.', decisionLogEntry);
                }
                
                message = 'Credit score: ' + creditScore;
                state = AOInteractionResult.State.SUCCESS;

                // Attempt to convert the credit score to a number.
                appInfo.creditScore = Integer.valueOf(creditScore);
                
                IAOPayloadParser creditReportParser = new AOExperianCreditReportParser();
                Map<String, Object> reportPayload = new Map<String, Object> {
                    AOReportParser.RAW_DATA_KEY => xpath
                };

                creditReportParser.parsePayload(reportPayload, appInfo);
            } catch(Exception e) {
                appInfo.addExceptionError('Experian Credit Score parser', e);
                state = AOInteractionResult.State.ERROR;
            }
        } catch(Exception e) {
            message = 'Unable to read Experian credit score data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }
        
        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
    
    public override String getFriendlyName() {
        return 'Experian Credit Score';
    }

    private AOInteractionResult notPresentResult(String message, AODecisionLogEntry decisionLogEntry) {
        return new AOInteractionResult(this.getFriendlyName(), AOInteractionResult.State.NOT_PRESENT, message, decisionLogEntry.decision);
    }
}