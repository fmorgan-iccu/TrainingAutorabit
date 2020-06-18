public class ESignACHDisputeMapper extends ESignAbstractMapper {
    /**
        This mapper expects a format as follows:

            {
                "name": "John Smith",
                "taxId": "666-66-6666",
                "email": "noreply@iccu.com",
                "memberNumber": "9999999999999",
                "accountNumber": "88888888888888",
                "companies": [{
                    "name": "Idaho Power",
					"reason": "NOT_AUTHORIZED",
                    "transactions": [{
                        "date": "4/23/2020",
                        "amount": "$123.23"
                    }]
                }, {
                    "name": "CITY OF POCATELLO",
					"reason": "DIFFERENT_AMOUNT",
                    "transactions": [{
                        "date": "4/20/2020",
                        "amount": "$12,123.23"
                    }]
                }]
            }

		The domain values for `reason` are:
			NOT_AUTHORIZED
			REVOKED_AUTHORIZATION
			BEFORE_AUTHORIZATION
			DIFFERENT_AMOUNT
			INCOMPLETE_TXN
			ELECTRONIC_CHECK
     */

    public ESignACHDisputeMapper(String jsonRepresentation) {
        super(jsonRepresentation);
    }

    public override ESignSendCeremonyRequest mapRequest() {
        Map<String, Object> json = this.jsonData;

        String createdBy = UserInfo.getUserEmail();
        String name = (String)json.get('name');
        String accountNumber = (String)json.get('accountNumber');
        String memberNumber = (String)json.get('memberNumber');
        String taxId = (String)json.get('taxId');
        String email = (String)json.get('email');

        List<Map<String, Object>> companies = APIUtils.convertObjectList((List<Object>)json.get('companies'));

        DocumentTemplate__mdt docTemplate = this.getTemplateMetadata('ACH_DISPUTE');
        String templateId = docTemplate.templateId__c;

        if (companies == null || companies.size() == 0) {
            throw new IllegalArgumentException('Companies cannot be null or empty!');
        }

        List<ESignTemplate> templates = new List<ESignTemplate>();

        Integer sequence = 1; // start at 1 and increment
        String recipientId = '1';
        String role = 'Borrower1';

        for (Map<String, Object> company : companies) {
            String companyName = (String)company.get('name');

            List<ESignData.ESignTextData> textData = new List<ESignData.ESignTextData> {
                new ESignData.ESignTextData('Team_Member', createdBy),
                new ESignData.ESignTextData('Member_Number', memberNumber),
                new ESignData.ESignTextData('Borrower1_Name', name),
                new ESignData.ESignTextData('Account_Number', accountNumber),
                new ESignData.ESignTextData('Tax_ID', taxId),
                new ESignData.ESignTextData('Merchant_Name', companyName)
            };

            List<Map<String, Object>> txns = APIUtils.convertObjectList((List<Object>)company.get('transactions'));
            Integer txnCount = 1; // Start at 1 and increment

            for (Map<String, Object> txn : txns) {
                String dateKey = 'Trans_Date' + String.valueOf(txnCount);
                String amountKey = 'Trans_Amount' + String.valueOf(txnCount);

                String txnDate = (String)txn.get('date');
                String txnAmount = (String)txn.get('amount');

                ESignData.ESignTextData dateData = new ESignData.ESignTextData(dateKey, txnDate);
                ESignData.ESignTextData amountData = new ESignData.ESignTextData(amountKey, txnAmount);

                textData.add(dateData);
                textData.add(amountData);

                txnCount += 1;
            }

            String reason = (String)company.get('reason');

            List<ESignData.ESignSelectData> radioData = new List<ESignData.ESignSelectData>{
                new ESignData.ESignSelectData('Authorize_Options', reason, true)
            };

            ESignData data = new ESignData(textData, radioData,  new List<ESignData.ESignSelectData>());

            List<ESignRecipient> recipients = new List<ESignRecipient>{
                new ESignRecipient(recipientId, name, email, role, data)
            };

            ESignTemplate template = new ESignTemplate(templateId, sequence, recipients);
            templates.add(template);

            sequence += 1;
        }

        String subject = docTemplate.emailSubject__c;
        List<ESignCustomField> customFields = new List<ESignCustomField>();

        ESignCeremony ceremony = new ESignCeremony(subject, templates, customFields);
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);

        return request;
    }
}