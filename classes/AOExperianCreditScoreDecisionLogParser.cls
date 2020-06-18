public virtual class AOExperianCreditScoreDecisionLogParser extends AOSystemDecisionLogParser {
    private static final String creditScoreRegex = 'Score:\\s(\\d{1,4})'; // Uses 'Score: ' to help match, but not capture.
    private static final Pattern creditScorePattern = Pattern.compile(creditScoreRegex);

    public override virtual String getSystemName() {
        return 'ExperianCreditScore';
    }

    public override AOInteractionResult processLogEntry(AOApplicationRestRequest.SystemInfo systemInfo, AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        try {
            String everything = systemInfo.everything;

            if (everything.contains('found in SFDC Contact')) { // Situation where they are getting the score directly from SF.
                Matcher matcher = creditScorePattern.matcher(everything);
                if (matcher.find() && matcher.groupCount() == 1) {  // Sanity check to make sure that we actually got something...
                    message = everything.trim();
                    state = AOInteractionResult.State.SUCCESS;
                    return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
                }
            }

            try {
                XPath xpath = new XPath(everything);

                // Verify that the RiskModel is present
                Dom.XmlNode[] riskModelNode = xpath.find('/NetConnectResponse/Products/CreditProfile/RiskModel');
                if (riskModelNode.size() == 0) {
                    state = AOInteractionResult.State.SUCCESS;
                    message = 'No risk information available.';
                    if (appInfo.appRequest.applicant.person.credit_score != null) {
                        message = message + ' Response Code: ' + appInfo.appRequest.applicant.person.credit_score.score;
                    }
                    return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
                }

                // Find the V3 risk model credit score
                String creditScore = null;
                Dom.XmlNode[] modelIndicatorNode = xpath.find('/NetConnectResponse/Products/CreditProfile/RiskModel/ModelIndicator[@code=V3]');
                if (modelIndicatorNode != null) {
                    Dom.XmlNode modelNode = modelIndicatorNode[0].getParent();
                    if (modelNode != null) {
                        Dom.XmlNode scoreNode = modelNode.getChildElement('Score', 'http://www.experian.com/ARFResponse');
                        if (scoreNode == null) {
                            scoreNode = modelNode.getChildElement('Score', null);
                        }
                        if (scoreNode != null) {
                            creditScore = scoreNode.getText();
                        }
                    }
                }

                if (creditScore == null) {
                    return new AOInteractionResult(this.getFriendlyName(), AOInteractionResult.State.NOT_PRESENT, 'Unable to find credit score in payload.', systemInfo.decision);
                }

                message = 'Credit score: ' + creditScore;
                state = AOInteractionResult.State.SUCCESS;

                AOExperianCreditReportParser creditReportParser = new AOExperianCreditReportParser();
                creditReportParser.parsePayload(systemInfo, appInfo);
            } catch(Exception e) {
                appInfo.addExceptionError('Experian Credit Score parser', e);
                state = AOInteractionResult.State.ERROR;
            }
        } catch(Exception e) {
            message = 'Unable to read Experian credit score data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, systemInfo.decision);
    }

    public override virtual String getFriendlyName() {
        return 'Experian Credit Score';
    }

}