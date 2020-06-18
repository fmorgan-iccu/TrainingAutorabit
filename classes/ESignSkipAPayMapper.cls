public class ESignSkipAPayMapper extends ESignAbstractMapper {

    /**
        This mapper expects a format as follows:

            {
                "name": "John Smith",
                "email": "noreply@iccu.com",
                "memberNumber": "9999999999999",
                "addressLine1": "123 Penny Lane",
                "city": "Pocatello",
                "state": "ID",
                "postalCode": "83201",
                "accounts": [
                    {
                        "accountNumber": "88888888888888",
                        "accountDescription": "VISA Credit Card",
                        "unpaidBalance": "5,456",
                        "paymentAmount": "144",
                        "skipDate": "5/1/2020",
                        "letterDate": "4/23/2020",
                        "skipMonth": "05",
                        "loanType": "visa"
                    }
                ]
            }

			`loanType` domain values:
				visa
				consumer

			NOTES:
				- All amounts do NOT contain a $, as these are baked into the template
				- skipMonth MUST have a leading 0 for single digit months
     */

    private static final String LOAN_TYPE_VISA			= 'visa';
    private static final String LOAN_TYPE_CONSUMER		= 'consumer';
    private static final String LOAN_DOC_TYPE_VISA		= '1059';
    private static final String LOAN_DOC_TYPE_CONSUMER	= '300';

	public ESignSkipAPayMapper(String jsonRepresentation) {
        super(jsonRepresentation);
    }

    public override ESignSendCeremonyRequest mapRequest() {
        Map<String, Object> json = this.jsonData;

        DocumentTemplate__mdt docTemplate = this.getTemplateMetadata('SKIP_A_PAY');

        String createdBy = UserInfo.getUserEmail();
        String name = (String)json.get('name');
        String email = (String)json.get('email');
        String memberNumber = (String)json.get('memberNumber');
        String addressLine1 = (String)json.get('addressLine1');
        String city = (String)json.get('city');
        String state = (String)json.get('state');
        String postal = (String)json.get('postalCode');
        String cityStateZip = city + ', ' + state + '  ' + postal;

        List<Map<String, Object>> rawAccounts = APIUtils.convertObjectList((List<Object>)json.get('accounts'));

        List<ESignTemplate> templates = new List<ESignTemplate>();
        for (Map<String, Object> rawAccount : rawAccounts) {
            String accountNumber = (String)rawAccount.get('accountNumber');
            String accountDescription = (String)rawAccount.get('accountDescription');
            String unpaidBalance = (String)rawAccount.get('unpaidBalance');
            String paymentAmount = (String)rawAccount.get('paymentAmount');
            String skipDate = (String)rawAccount.get('skipDate');
            String letterDate = (String)rawAccount.get('letterDate');
            String skipMonth = (String)rawAccount.get('skipMonth');
            String loanType = (String)rawAccount.get('loanType');
            String docType = null;
            String checkboxKey = null;

            if (loanType == ESignSkipAPayMapper.LOAN_TYPE_VISA) {
                docType = ESignSkipAPayMapper.LOAN_DOC_TYPE_VISA;
                checkboxKey = 'Checkbox_Visa';
            } else if (loanType == ESignSkipAPayMapper.LOAN_TYPE_CONSUMER) {
                docType = ESignSkipAPayMapper.LOAN_DOC_TYPE_CONSUMER;
                checkboxKey = 'Checkbox_Consumer';
            } else {
                throw new IllegalArgumentException('Invalid loanType: ' + loanType);
            }

            List<ESignData.ESignTextData> textData = new List<ESignData.ESignTextData> {
                new ESignData.ESignTextData('Team_Member', createdBy),
                new ESignData.ESignTextData('Letter_Date', letterDate),
                new ESignData.ESignTextData('Skip_Date', skipDate),
                new ESignData.ESignTextData('Borrower1_Name', name),
                new ESignData.ESignTextData('Address_Line1', addressLine1),
                new ESignData.ESignTextData('City_State_Zip', cityStateZip),
                new ESignData.ESignTextData('Account_Number', accountNumber),
                new ESignData.ESignTextData('Account_Description', accountDescription),
                new ESignData.ESignTextData('Unpaid_Balance', unpaidBalance),
                new ESignData.ESignTextData('Payment_Amount', paymentAmount),
                new ESignData.ESignTextData('Skip_Month', skipMonth),
                new ESignData.ESignTextData('Doc_Type', docType)
            };

            List<ESignData.ESignSelectData> checkData = new List<ESignData.ESignSelectData> {
                new ESignData.ESignSelectData(checkboxKey, checkboxKey, true)
            };

            String recipientId = '1';
            String role = 'Borrower1';
            ESignData data = new ESignData(textData, new List<ESignData.ESignSelectData>(),  checkData);

            List<ESignRecipient> recipients = new List<ESignRecipient> {
                new ESignRecipient(recipientId, name, email, role, data)
            };

            String templateId = docTemplate.templateId__c;
            Integer sequence = 1;

            templates.add(new ESignTemplate(templateId, sequence, recipients));
        }

        String subject = docTemplate.emailSubject__c;
        List<ESignCustomField> customFields = new List<ESignCustomField>();

        ESignCeremony ceremony = new ESignCeremony(subject, templates, customFields);
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);

        return request;
    }
}