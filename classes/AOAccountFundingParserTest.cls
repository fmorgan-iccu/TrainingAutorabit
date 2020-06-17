@IsTest
private class AOAccountFundingParserTest {
	@IsTest
    private static void testHappyPath() {
		String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><Applicant><NewAccount><item><AccountGroupNumber/><AccountNumber>718595815</AccountNumber><MajorTypeCode>SAV</MajorTypeCode><MinorTypeCode>SREG</MinorTypeCode></item><item><AccountGroupNumber/><AccountNumber>718595823</AccountNumber><MajorTypeCode>CK</MajorTypeCode><MinorTypeCode>CKBA</MinorTypeCode></item></NewAccount><Contact><Email>avokatest123@gmail.com</Email><FirstName>Dan</FirstName><LastName>Black</LastName><DateOfBirth>1953-07-17</DateOfBirth><Ssn>518-66-6021</Ssn><MaskedSsn>6021</MaskedSsn><ApplicantPersona>person</ApplicantPersona><PersonNumber>97958</PersonNumber><Phone>2088551111</Phone><MobilePhone>2222222222</MobilePhone><WorkPhone>3333333333</WorkPhone><MailingStreet>1321 E Time Zone Dr</MailingStreet><MailingStreet2/><MailingCity>Meridian</MailingCity><MailingState>ID</MailingState><MailingPostalCode>83642</MailingPostalCode><MailingCountry>USA</MailingCountry><MailingCountryCode>USA</MailingCountryCode><IDNumber/><IDType>Salesforce Drivers License</IDType><IDIssueState/><IDIssueDate/><IDExpiryDate/></Contact><AccountList/></Applicant><AccountsFunding><FundJson>[{"AccountNumberTo":"718595815","FundAmount":50},{"AccountNumberTo":"718595823","FundAmount":2500}]</FundJson><PropayPaymentType>ACH</PropayPaymentType><TotalFundAmount>2555</TotalFundAmount><UsingPropay>true</UsingPropay></AccountsFunding></AvokaSmartForm></Root>';

        try {
			XPath xpath = new XPath(testData);
			
			// The account funding parser depends on the applicant parser to extract the accounts
			// that are being setup.  The funding parser then updates these accounts with the
			// available amount, which is tested.
			Dom.XmlNode applicantNode = xpath.findFirst('/Root/AvokaSmartForm/Applicant');
			List<Map<String,Object>> applicantPayloads = new List<Map<String,Object>>();
			Map<String, Object> v0ApplicantPayload = new Map<String, Object>();
			v0ApplicantPayload.put(AOConstants.XML_APPLICANT_KEY, applicantNode);
			applicantPayloads.add(v0ApplicantPayload);
			Map<String, Object> v1ApplicantPayload = new Map<String, Object>();
			v1ApplicantPayload.put(AOConstants.XML_APPLICANT_KEY, applicantNode);
			v1ApplicantPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V1);
			applicantPayloads.add(v1ApplicantPayload);
			Map<String, Object> v2ApplicantPayload = new Map<String, Object>();
			v2ApplicantPayload.put(AOConstants.XML_APPLICANT_KEY, applicantNode);
			v2ApplicantPayload.put(AOConstants.XML_VERSION, AOConstants.FormXmlVersion.V2);
			applicantPayloads.add(v2ApplicantPayload);

			for (Map<String, Object> applicantPayload : applicantPayloads) {
				AOApplicantParser applicantParser = new AOApplicantParser();
				AOApplicationInfo appInfo = new AOApplicationInfo();
				applicantParser.parsePayload(applicantPayload, appInfo);

				//Test.startTest();

				Dom.XmlNode accountFunding = xpath.findFirst('/Root/AvokaSmartForm/AccountsFunding');
				Map<String, Object> payload = new Map<String, Object>();
				payload.put(AOConstants.XML_NODE_KEY, accountFunding);

				AOAccountFundingParser parser = new AOAccountFundingParser();
				parser.parsePayload(payload, appInfo);
				
				//Test.stopTest();

				System.assertNotEquals(null, appInfo.propayPaymentType);
				System.assertNotEquals(null, appInfo.usingProPay);
				System.assertEquals(2555, appInfo.totalFundAmount);
				System.assertEquals(2, appInfo.newAccounts.size());
				for (IAccount account : appInfo.newAccounts) {
					DNAAccount dnaAccount = (DNAAccount)account;
					if (dnaAccount.getAccountNumber() == '718595823') {
						System.assertEquals(2500, dnaAccount.getAvailableBalance());
					}
				}

				for (IAccount account: appInfo.NewAccounts) {
					System.assert(account.getAccountNumber() != null, 'Account number was null');
				}
			}
        } catch(Exception e) {
			System.assert(false, 'unexpected threw exception: ' + e + ' ' + e.getLineNumber());
        }
    }

    @IsTest
    private static void testMissingDecision() {
        String testData = '<?xml version="1.0" encoding="UTF-8"?><Root><AvokaSmartForm><AccountsFunding><PropayPaymentType/><AccountNumberFrom/><TotalFundAmount>0</TotalFundAmount><UsingPropay/><AccountToFund><PaymentConfirmed/></AccountToFund><FundJson/></AccountsFunding></AvokaSmartForm></Root>';

		try {
			Test.startTest();

			XPath xpath = new XPath(testData);
			Dom.XmlNode accountFunding = xpath.findFirst('/Root/AvokaSmartForm/AccountsFunding');
			Map<String, Object> payload = new Map<String, Object>();
			payload.put(AOConstants.XML_NODE_KEY, accountFunding);

			AOAccountFundingParser parser = new AOAccountFundingParser();
			AOApplicationInfo appInfo = new AOApplicationInfo();
			parser.parsePayload(payload, appInfo);
			
			Test.stopTest();

			System.assertEquals(null, appInfo.propayPaymentType);
			System.assertEquals(null, appInfo.usingProPay);
			System.assertEquals(0, appInfo.totalFundAmount);

			for (IAccount account: appInfo.NewAccounts) {
				System.assert(account.getAccountNumber() != null, 'Account number was null');
			}
        } catch(Exception e) {
			System.assert(false, 'unexpected threw exception: ' + e + ' ' + e.getLineNumber());
        }
    }
}