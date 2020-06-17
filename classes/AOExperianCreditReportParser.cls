public class AOExperianCreditReportParser extends AOReportParser {
    private static final Map<String, String> scoreFactorCodes = new Map<String, String>{
        '04'  => 'THE BALANCES ON YOUR ACCOUNTS ARE TOO HIGH COMPARED TO LOAN LIMITS',
        '05'  => 'TOO MANY OF THE DELINQUENCIES ON YOUR ACCOUNTS ARE RECENT',
        '06'  => 'YOU HAVE TOO MANY ACCOUNTS THAT WERE OPENED RECENTLY',
        '07'  => 'YOU HAVE TOO MANY DELINQUENT OR DEROGATORY ACCOUNTS',
        '08'  => 'YOU HAVE EITHER TOO FEW LOANS OR TOO MANY LOANS WITH RECENT DELINQUENCIES',
        '09'  => 'THE MOST SERIOUS PAYMENT STATUS ON YOUR ACCTS IS DELINQUENT OR DEROGATORY',
        '10'  => 'YOU HAVE NOT PAID ENOUGH OF YOUR ACCOUNTS ON TIME',
        '11'  => 'THE TOTAL OF YOUR DELINQUENT OR DEROGATORY ACCOUNT BALANCES IS TOO HIGH',
        '12'  => 'THE DATE THAT YOU OPENED YOUR OLDEST ACCOUNT IS TOO RECENT',
        '13'  => 'YOUR MOST RECENTLY OPENED ACCOUNT IS TOO NEW',
        '14'  => 'LACK OF SUFFICIENT CREDIT HISTORY',
        '15'  => 'NEWEST DELINQUENT/DEROGATORY PAYMENT STATUS ON YOUR ACCTS IS TOO RECENT',
        '16'  => 'THE TOTAL OF ALL BALANCES ON YOUR OPEN ACCOUNTS IS TOO HIGH',
        '17'  => 'BALANCE ON PREVIOUSLY DELINQUENT ACCTS ARE TOO HIGH COMPARED TO LOAN AMTS',
        '18'  => 'TOTAL OF BALANCES ON ACCTS NEVER LATE IS TOO HIGH COMPARED TO LOAN AMTS',
        '21'  => 'NO OPEN ACCOUNTS IN YOUR CREDIT FILE',
        '22'  => 'NO RECENTLY REPORTED ACCOUNT INFORMATION',
        '23'  => 'LACK OF SUFFICIENT RELEVANT ACCOUNT INFORMATION',
        '29'  => 'TOO MANY OF YOUR OPEN BANK CARD OR REVOLVING ACCOUNTS HAVE A BALANCE',
        '30'  => 'TOO FEW OF YOUR BANK CARD OR OTHER REVOLVING ACCOUNTS HAVE HIGH LIMITS',
        '31'  => 'TOO MANY BANK CARD OR OTHER REVOLVING ACCOUNTS WERE OPENED RECENTLY',
        '32'  => 'BALANCES ON BANKCARD/REVOLVING ACCTS TOO HIGH COMPARED TO CREDIT LIMITS',
        '33'  => 'YOUR WORST BANKCARD OR REVOLVING ACCOUNTS STATUS IS DELINQUENT/DEROGATORY',
        '34'  => 'TOTAL OF ALL BALANCES ON BANK CARD OR REVOLVING ACCOUNTS IS TOO HIGH',
        '35'  => 'YOUR HIGHEST BANKCARD OR REVOLVING ACCOUNT BALANCE IS TOO HIGH',
        '36'  => 'YOUR LARGEST CREDIT LIMIT ON OPEN BANKCARD OR REVOLVING ACCOUNTS IS TOO LOW',
        '39'  => 'AVAILABLE CREDIT ON YOUR OPEN BANKCARD OR REVOLVING ACCOUNTS IS TOO LOW',
        '40'  => 'THE DATE YOU OPENED YOUR OLDEST BANK CARD OR REVOLVING ACCT IS TOO RECENT',
        '42'  => 'THE DATE YOU OPENED YOUR NEWEST BANK CARD OR REVOLVING ACCT IS TOO RECENT',
        '43'  => 'LACK OF SUFFICIENT CREDIT HISTORY ON BANK CARD OR REVOLVING ACCOUNTS',
        '44'  => 'TOO MANY BANKCARD OR REVOLVING ACCOUNTS WITH DELINQUENT/DEROGATORY STATUS',
        '45'  => 'TOTAL BALANCES TOO HIGH ON DELINQUENT/DEROGATORY BANKCARD/REVOLVING ACCTS',
        '47'  => 'NO OPEN BANK CARD OR REVOLVING ACCOUNTS IN YOUR CREDIT FILE',
        '48'  => 'NO BANKCARD OR REVOLVING RECENTLY REPORTED ACCOUNT INFORMATION',
        '49'  => 'LACK OF SUFFICIENT RELEVANT BANKCARD OR REVOLVING ACCOUNT INFORMATION',
        '53'  => 'THE WORST STATUS ON YOUR REAL ESTATE ACCOUNTS IS DELINQUENT OR DEROGATORY',
        '54'  => 'THE AMT OF BALANCE PAID DOWN ON YOUR OPEN REAL ESTATE ACCOUNTS IS TOO LOW',
        '55'  => 'OPEN REAL ESTATE ACCT BALANCES ARE TOO HIGH COMPARED TO THEIR LOAN AMTS',
        '57'  => 'TOO MANY REAL ESTATE ACCTS WITH DELINQUENT OR DEROGATORY PAYMENT STATUS',
        '58'  => 'THE TOTAL OF ALL BALANCES ON YOUR OPEN REAL ESTATE ACCOUNTS IS TOO HIGH',
        '61'  => 'NO OPEN REAL ESTATE ACCOUNTS IN YOUR CREDIT FILE',
        '62'  => 'NO RECENTLY REPORTED REAL ESTATE ACCOUNT INFORMATION',
        '63'  => 'LACK OF SUFFICIENT RELEVANT REAL ESTATE ACCOUNT INFORMATION',
        '64'  => 'NO OPEN FIRST MORTGAGE ACCOUNTS IN YOUR CREDIT FILE',
        '65'  => 'LACK OF SUFFICIENT RELEVANT FIRST MORTGAGE ACCOUNT INFORMATION',
        '66'  => 'YOUR OPEN AUTO ACCOUNT BALANCES ARE TOO HIGH COMPARED TO THEIR LOAN AMTS',
        '68'  => 'NO OPEN AUTO ACCOUNTS IN YOUR CREDIT FILE',
        '69'  => 'LACK OF SUFFICIENT RELEVANT AUTO ACCOUNT INFORMATION',
        '71'  => 'YOU HAVE NOT PAID ENOUGH OF YOUR INSTALLMENT ACCOUNTS ON TIME',
        '72'  => 'TOO MANY INSTALLMENT ACCTS WITH A DELINQUENT OR DEROGATORY PAYMENT STATUS',
        '73'  => 'THE WORST STATUS ON YOUR INSTALLMENT ACCOUNTS IS DELINQUENT OR DEROGATORY',
        '74'  => 'THE BALANCE AMOUNT PAID DOWN ON YOUR OPEN INSTALLMENT ACCOUNTS IS TOO LOW',
        '75'  => 'THE INSTALLMENT ACCOUNT THAT YOU OPENED MOST RECENTLY IS TOO NEW',
        '76'  => 'YOU HAVE INSUFFICIENT CREDIT HISTORY ON INSTALLMENT LOANS',
        '77'  => 'NEWEST DELINQUENT OR DEROGATORY STATUS ON INSTALLMENT ACCTS IS TOO RECENT',
        '78'  => 'BALANCES ON INSTALLMENT ACCTS ARE TOO HIGH COMPARED TO THEIR LOAN AMOUNTS',
        '79'  => 'TOO MANY OF THE DELINQUENCIES ON YOUR INSTALLMENT ACCOUNTS ARE RECENT',
        '81'  => 'NO OPEN INSTALLMENT ACCOUNTS IN YOUR CREDIT FILE',
        '83'  => 'LACK OF SUFFICIENT RELEVANT INSTALLMENT ACCOUNT INFORMATION',
        '84'  => 'NUMBER OF INQUIRIES IMPACTED YOUR SCORE, BUT EFFECT WAS NOT SIGNIFICANT',
        '85'  => 'YOU HAVE TOO MANY INQUIRIES ON YOUR CREDIT REPORT.',
        '86'  => 'YOUR CREDIT REPORT CONTAINS TOO MANY DEROGATORY PUBLIC RECORDS',
        '87'  => 'YOUR CREDIT REPORT CONTAINS TOO MANY UNSATISFIED PUBLIC RECORDS',
        '88'  => 'ONE OR MORE DEROGATORY PUBLIC RECORDS IN YOUR CREDIT FILE IS TOO RECENT',
        '90'  => 'TOO FEW DISCHARGED BANKRUPTCIES',
        '93'  => 'THE WORST STATUS ON YOUR STUDENT LOAN ACCTS IS DELINQUENT OR DEROGATORY',
        '94'  => 'THE BALANCE AMOUNT PAID DOWN ON YOUR OPEN STUDENT LOAN ACCTS IS TOO LOW',
        '95'  => 'YOU HAVE TOO MANY COLLECTION AGENCY ACCOUNTS THAT ARE UNPAID',
        '96'  => 'THE TOTAL YOU OWE ON COLLECTION AGENCY ACCOUNTS IS HIGH',
        '97'  => 'YOU HAVE TOO FEW CREDIT ACCOUNTS',
        '98'  => 'THERE IS A BANKRUPTCY ON YOUR CREDIT REPORT'
    };
    
    public AOExperianCreditReportParser() {
    }
    
    public override String getReportName() {
        return 'Experian Credit Score';
    }

    public override void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        try {
            if (payload == null || appInfo == null) {
                throw new IllegalArgumentException('Payload nor ApplicationInfo can be null.');
            }
            
            XPath xpath = (XPath)payload.get(RAW_DATA_KEY);

            if (xpath == null) {
                throw new IllegalArgumentException('Xpath was not present in the payload map.');
            }
            
            Map<String, Object> personalDetailsSection = this.createDataElement('Personal Details', this.parsePersonalDetails(xpath));
            Map<String, Object> addressesSection = this.createDataElement('Addresses', this.parseAddresses(xpath));
            Map<String, Object> employmentSection = this.createDataElement('Employment', this.parseEmployment(xpath));
            Map<String, Object> publicRecordsSection = this.createDataElement('Public Records', this.parsePublicRecords(xpath));
            Map<String, Object> tradesSection = this.createDataElement('Trades', this.parseTrades(xpath));
            Map<String, Object> inquiriesSection = this.createDataElement('Inquiries', this.parseInquiries(xpath));
            Map<String, Object> messagesSection = this.createDataElement('Messages', this.parseMessages(xpath));
            Map<String, Object> scoreSummarySection = this.createDataElement('Score Summary', this.parseScoreSummary(xpath));

            List<Map<String, Object>> summary = new List<Map<String, Object>> {
                scoreSummarySection
            };

            List<Map<String, Object>> sections = new List<Map<String, Object>> {
                personalDetailsSection,
                addressesSection,
                employmentSection,
                scoreSummarySection,
                publicRecordsSection,
                tradesSection,
                inquiriesSection,
                messagesSection
            };

            appInfo.creditReport = this.createReport(summary, sections);
        } catch (Exception e) {
            if (appInfo != null) {
                appInfo.creditReport = this.createExceptionMap(e);
            }
        }
    }

    private List<List<Map<String, Object>>> parseAddresses(XPath xpath) {
        List<List<Map<String, Object>>> addresses = new List<List<Map<String, Object>>>();
        List<Dom.XmlNode> addressNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/AddressInformation');
        
        if (addressNodes == null || addressNodes.size() == 0) {
            return addresses;
        }
        
        for (Dom.XmlNode addressNode : addressNodes) {
            List<Map<String, Object>> address = new List<Map<String, Object>>();
            
            String street = '';
            Dom.XmlNode streetPrefixNode = addressNode.getChildElement('StreetPrefix', addressNode.getNamespace());
            Dom.XmlNode streetNode = addressNode.getChildElement('StreetName', addressNode.getNamespace());
            Dom.XmlNode streetSuffixNode = addressNode.getChildElement('StreetSuffix', addressNode.getNamespace());
            Dom.XmlNode cityNode = addressNode.getChildElement('City', addressNode.getNamespace());
            Dom.XmlNode stateNode = addressNode.getChildElement('State', addressNode.getNamespace());
            Dom.XmlNode zipNode = addressNode.getChildElement('Zip', addressNode.getNamespace());

            if (streetPrefixNode != null) {
                street = street + streetPrefixNode.getText() + ' ';
            }
            
            if (streetNode != null) {
                street = street + streetNode.getText() + ' ';
            }
            
            if (streetSuffixNode != null) {
                street = street + streetSuffixNode.getText();
            }
            
            if (street.length() > 0) {
                address.add(this.createDataElement('', street, REPORT_FULL_WIDTH));
            }
            
            String city = null;
            if (cityNode != null) {
                city = cityNode.getText();
            }
            
            String state = null;
            if (stateNode != null) {
                state = stateNode.getText();
            }
            
            String zip = null;
            if (zipNode != null) {
                zip = zipNode.getText();
            }

            String cityStateZip = AddressUtils.combineCityStateZip(city, state, zip);
   
            if (cityStateZip != null) {
                address.add(this.createDataElement('', cityStateZip, REPORT_FULL_WIDTH));
            }

            Map<String, Object> reportStart = this.dateNodeParse(addressNode, 'FirstReportedDate', 'First Report Date');
            this.addDataElementToList(reportStart, address);
            
            Map<String, Object> reportEnd = this.dateNodeParse(addressNode, 'LastUpdatedDate', 'Last Updated Date');
            this.addDataElementToList(reportEnd, address);
            
            Map<String, Object> reportSub = this.simpleNodeParse(addressNode, 'LastReportingSubcode', 'Last Reporting Subcode');
            this.addDataElementToList(reportSub, address);
            
            addresses.add(address);
        }
        
        return addresses;
    }
    
    private List<List<Map<String, Object>>> parseEmployment(XPath xpath) {
        List<Dom.XmlNode> employmentNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/EmploymentInformation');
        
        List<List<Map<String, Object>>> employmentList = new List<List<Map<String, Object>>>();
        
        if (employmentNodes == null || employmentNodes.size() == 0) {
            return employmentList;
        }
        
        for (Dom.XmlNode employementNode : employmentNodes) {
            List<Map<String, Object>> employment = new List<Map<String, Object>>();
            
            Map<String, Object> name = this.simpleNodeParse(employementNode, 'Name', 'Name');
            name.put(REPORT_WIDTH_KEY, REPORT_FULL_WIDTH);
            this.addDataElementToList(name, employment);
            
            Map<String, Object> reportStart = this.dateNodeParse(employementNode, 'FirstReportedDate', 'First Report Date');
            this.addDataElementToList(reportStart, employment);
            
            Map<String, Object> reportEnd = this.dateNodeParse(employementNode, 'LastUpdatedDate', 'Last Updated Date');
            this.addDataElementToList(reportEnd, employment);

            employmentList.add(employment);
        }
        
        return employmentList;
    }
    
    private Map<String, Object> parseInquiries(XPath xpath) {
        List<Dom.XmlNode> inquiryNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/Inquiry');
        
        if (inquiryNodes == null || inquiryNodes.size() == 0) {
            return new Map<String, Object>();
        }
        
        List<String> headers = new List<String> {
            'Date',
            'Institution',
            'KOB'
        };
        
        List<List<String>> rows = new List<List<String>>();
            
        for (Dom.XmlNode inquiryNode : inquiryNodes) {            
            List<String> row = new List<String>();

            List<Map<String, Object>> inquiry = new List<Map<String, Object>>();

            String inquiryDate = this.dateNodeParseValue(inquiryNode, 'Date');
            this.addValueToList(inquiryDate, row);

            String institution = this.simpleNodeParseValue(inquiryNode, 'SubscriberDisplayName');
            this.addValueToList(institution, row);

            String kob = this.simpleAttributeNodeParseValue(inquiryNode, 'KOB', 'code');
            this.addValueToList(kob, row);

            rows.add(row);
        }
        
        Map<String, Object> table = this.createTable(headers, rows);
        
        return table;
    }
    
    private List<List<Map<String, Object>>> parseMessages(XPath xpath) {
        List<Dom.XmlNode> messageNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/InformationalMessage');
        
        List<List<Map<String, Object>>> messages = new List<List<Map<String, Object>>>();
        
        if (messageNodes == null || messageNodes.size() == 0) {
            return messages;
        }
        
        for (Dom.XmlNode messageNode : messageNodes) {
            List<Map<String, Object>> message = new List<Map<String, Object>>();
            Dom.XmlNode numberNode = messageNode.getChildElement('MessageNumber', messageNode.getNamespace());
            Dom.XmlNode textNode = messageNode.getChildElement('MessageText', messageNode.getNamespace());
            
            message.add(this.createDataElement(numberNode.getText(), textNode.getText(), REPORT_FULL_WIDTH));
            
            messages.add(message);
        }
        
        return messages;
    }

    private List<List<Map<String, Object>>> parsePersonalDetails(XPath xpath) {
        List<List<Map<String, Object>>> details = new List<List<Map<String, Object>>>();
        
        Dom.XmlNode ssnNode = xpath.findFirst('/NetConnectResponse/Products/CreditProfile/SSN');

		List<Map<String, Object>> detailGroup = new List<Map<String, Object>>();
        Map<String, Object> ssn = this.simpleNodeParse(ssnNode, 'Number', 'SSN');
        if (ssn != null) {
            detailGroup.add(ssn);
        }
        
        details.add(detailGroup);

        return details;
    }
    
    private List<List<Map<String, Object>>> parsePublicRecords(XPath xpath) {       
        List<Dom.XmlNode> publicRecordNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/PublicRecord');
        
        List<List<Map<String, Object>>> publicRecords = new List<List<Map<String, Object>>>();
            
        if (publicRecordNodes == null || publicRecordNodes.size() == 0) {
            return publicRecords;
        }
        
        for (Dom.XmlNode publicRecordNode : publicRecordNodes) {
            List<Map<String, Object>> publicRecord = new List<Map<String, Object>>();
            
            Map<String, Object> status = this.simpleAttributeNodeParse(publicRecordNode, 'Status', 'code', 'Status');
            this.addDataElementToList(status, publicRecord);

            Map<String, Object> statusDate = this.dateNodeParse(publicRecordNode, 'StatusDate', 'Status Date');
            this.addDataElementToList(statusDate, publicRecord);
            
            Map<String, Object> filingDate = this.dateNodeParse(publicRecordNode, 'FilingDate', 'Filing Date');
            this.addDataElementToList(filingDate, publicRecord);
            
            Map<String, Object> amount = this.simpleNodeIntegerParse(publicRecordNode, 'Amount', 'Amount');
            this.addDataElementToList(amount, publicRecord);
            
            Map<String, Object> court = this.simpleAttributeNodeParse(publicRecordNode, 'Court', 'name', 'Court');
            this.addDataElementToList(court, publicRecord);
            
            Map<String, Object> ecoa = this.simpleAttributeNodeParse(publicRecordNode, 'ECOA', 'code', 'ECOA Code');
            this.addDataElementToList(ecoa, publicRecord);
            
            publicRecords.add(publicRecord);
        }
            
        return publicRecords;
    }
    
	/**
	 * Finds the Experian V3 risk model score summary.
	 */
    private List<List<Map<String, Object>>> parseScoreSummary(XPath xpath) {
		Dom.XmlNode[] modelIndicatorNode = xpath.find('/NetConnectResponse/Products/CreditProfile/RiskModel/ModelIndicator[@code=V3]');
		if (modelIndicatorNode == null) {
			return new List<List<Map<String, Object>>>();
		}

		Dom.XmlNode riskModelNode = modelIndicatorNode[0].getParent();
        if (riskModelNode == null) {
            return new List<List<Map<String, Object>>>();
        }

		List<Map<String, Object>> scoreSummary = new List<Map<String, Object>>();
        
        Map<String, Object> model = this.simpleAttributeNodeParse(riskModelNode, 'ModelIndicator', 'code', 'Model Indicator');
        this.addDataElementToList(model, scoreSummary);
        
        Map<String, Object> score = this.simpleNodeParse(riskModelNode, 'Score', 'Score');
        this.addDataElementToList(score, scoreSummary);
        
        List<Map<String, Object>> scoreFactors = new List<Map<String, Object>>();
        
        Map<String, Object> factor1 = this.parseScoreFactor(riskModelNode, 'ScoreFactorCodeOne');
        this.addDataElementToList(factor1, scoreFactors);
        
        Map<String, Object> factor2 = this.parseScoreFactor(riskModelNode, 'ScoreFactorCodeTwo');
        this.addDataElementToList(factor2, scoreFactors);
        
        Map<String, Object> factor3 = this.parseScoreFactor(riskModelNode, 'ScoreFactorCodeThree');
        this.addDataElementToList(factor3, scoreFactors);
        
        Map<String, Object> factor4 = this.parseScoreFactor(riskModelNode, 'ScoreFactorCodeFour');
        this.addDataElementToList(factor4, scoreFactors);

        return new List<List<Map<String, Object>>> {
            scoreSummary,
            scoreFactors
        };
    }

    private Map<String, Object> parseTrades(XPath xpath) {
        List<Dom.XmlNode> tradeNodes = xpath.find('/NetConnectResponse/Products/CreditProfile/TradeLine');

        if (tradeNodes == null || tradeNodes.size() == 0) {
            return new Map<String, Object>();
        }
        
        List<String> headers = new List<String> {
            'Institution',
            'Open',
            'Open Date',
            'Type',
            'Balance Amount',
            'Terms Duration',
            'Status Date',
            'Account #',
            'Balance Date',
            'Amount Past Due',
            'Last Payment Date',
            'KOB',
            'Payment History'
        };
            
        List<List<String>> rows = new List<List<String>>();
        
        for (Dom.XmlNode tradeNode : tradeNodes) {
            List<String> row = new List<String>();

            String institution = this.simpleNodeParseValue(tradeNode, 'SubscriberDisplayName');
            this.addValueToList(institution, row);
            
            String openClosed = this.simpleAttributeNodeParseValue(tradeNode, 'OpenOrClosed', 'code');
            this.addValueToList(openClosed, row);
            
            String openDate = this.dateNodeParseValue(tradeNode, 'OpenDate');
            this.addValueToList(openDate, row);
            
            String revolvingOrInstallment = this.simpleAttributeNodeParseValue(tradeNode, 'RevolvingOrInstallment', 'code');
            this.addValueToList(revolvingOrInstallment, row);
            
            String balanceAmount = this.simpleNodeIntegerParseValue(tradeNode, 'BalanceAmount');
            this.addValueToList(balanceAmount, row);
            
            String termsDuration = this.simpleAttributeNodeParseValue(tradeNode, 'TermsDuration', 'code');
            this.addValueToList(termsDuration, row);
            
            String statusDate = this.dateNodeParseValue(tradeNode, 'StatusDate');
            this.addValueToList(statusDate, row);

            String accountNumber = this.simpleNodeParseValue(tradeNode, 'AccountNumber');
            this.addValueToList(accountNumber, row);
            
            String balanceDate = this.dateNodeParseValue(tradeNode, 'BalanceDate');
            this.addValueToList(balanceDate, row);
            
            String pastDueAmount = this.simpleNodeIntegerParseValue(tradeNode, 'AmountPastDue');
            this.addValueToList(pastDueAmount, row);

            String lastPaymentDate = this.dateNodeParseValue(tradeNode, 'LastPaymentDate');
            this.addValueToList(lastPaymentDate, row);
            
            String kob = this.simpleAttributeNodeParseValue(tradeNode, 'KOB', 'code');
            this.addValueToList(kob, row);
            
            String paymentProfile = this.simpleNodeParseValue(tradeNode, 'PaymentProfile');
            this.addValueToList(paymentProfile, row);
            
            List<Dom.XmlNode> amountNodes = new List<Dom.XmlNode>();
            
            for (Dom.XmlNode child : tradeNode.getChildren()) {
                if (child.getName() == 'Amount') {
                    amountNodes.add(child);
                }
            }

            rows.add(row);
        }
        
        Map<String, Object> table = this.createTable(headers, rows);
        
        return table;
    }
    
    /* Utility Methods */
     
    private String formatDate(Date sfDate) {
        if (sfDate == null) {
            return null;
        }

		String formattedDate = sfDate.format();
        return formattedDate;
    }
    
    private Date parseReportDate(String experianDate) {
        if (experianDate == null || experianDate.length() != 8) {
            return null;
        }
        
        Integer month = Integer.valueOf(experianDate.substring(0, 2));
        Integer day = Integer.valueOf(experianDate.substring(2, 4));
        Integer year = Integer.valueOf(experianDate.substring(4));

        Date sfDate = Date.newInstance(year, month, day);

        return sfDate;
    }

    private Map<String, Object> simpleNodeParse(Dom.XmlNode parentNode, String childElementName, String title) {
        String value = this.simpleNodeParseValue(parentNode, childElementName);
        
        return this.createDataElement(title, value);
    }
    
    private String simpleNodeParseValue(Dom.XmlNode parentNode, String childElementName) {
        Dom.XmlNode childNode = parentNode.getChildElement(childElementName, parentNode.getNamespace());
        if (childNode == null) {
            return null;
        }
        
        String value = childNode.getText().trim();
        
        if (value.length() == 0) {
            return null;
        }
        
        return value;
    }
    
    private Map<String, Object> simpleNodeIntegerParse(Dom.XmlNode parentNode, String childElementName, String title) {
        String value = this.simpleNodeIntegerParseValue(parentNode, childElementName);

        return this.createDataElement(title, value);
    }
    
    private String simpleNodeIntegerParseValue(Dom.XmlNode parentNode, String childElementName) {
        Dom.XmlNode childNode = parentNode.getChildElement(childElementName, parentNode.getNamespace());
        if (childNode == null) {
            return null;
        }

        String value = childNode.getText();

        try {
            Integer intValue = Integer.valueOf(value);
            value = String.valueOf(intValue);
        } catch (Exception e) {
            // DO NOTHING
        }

        return value;
    }
    
    private Map<String, Object> simpleAttributeNodeParse(Dom.XmlNode parentNode, String childElementName, String attributeName, String title) {
        String attributeValue = this.simpleAttributeNodeParseValue(parentNode, childElementName, attributeName);

        if (attributeValue == null) {
            return null;
        }
        
        return this.createDataElement(title, attributeValue);
    }
    
    private String simpleAttributeNodeParseValue(Dom.XmlNode parentNode, String childElementName, String attributeName) {
        Dom.XmlNode childNode = parentNode.getChildElement(childElementName, parentNode.getNamespace());
        if (childNode == null) {
            return null;
        }
        
        Integer attributeCount = childNode.getAttributeCount();
        String attributeValue = null;
        
        for (Integer i = 0; i < attributeCount; i++) {
            String key = childNode.getAttributeKeyAt(i);
            
            if (key == attributeName) {
                String keyNamespace = childNode.getAttributeKeyNsAt(i);
                attributeValue = childNode.getAttributeValue(key, keyNamespace);

                break;
            }
        }

        return attributeValue;
    }
    
    private Map<String, Object> dateNodeParse(Dom.XmlNode parentNode, String childElementName, String title) {
        String formattedDate = this.dateNodeParseValue(parentNode, childElementName);

        if (formattedDate == null) {
            return null;
        }
        
        return this.createDataElement(title, formattedDate);
    }
    
    private String dateNodeParseValue(Dom.XmlNode parentNode, String childElementName) {
        String value = this.simpleNodeParseValue(parentNode, childelementName);
        String formattedDate = this.formatDate(this.parseReportDate(value));
        
        return formattedDate;
    }
    
    private Map<String, Object> parseScoreFactor(Dom.XmlNode parentNode, String factorName) {
        Dom.XmlNode factorCodeNode = parentNode.getChildElement(factorName, parentNode.getNamespace());
        if (factorCodeNode == null) {
            return null;
        }

        String factorCode = factorCodeNode.getText();
        String factorDescription = AOExperianCreditReportParser.scoreFactorCodes.get(factorCode);
        
        return this.createDataElement(factorCode, factorDescription, REPORT_FULL_WIDTH);
    }

}