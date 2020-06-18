/**
 * Abstract mapper for VISA dispute forms.
 */
public abstract class ESignVisaAbstractMapper extends ESignAbstractMapper {

    /**

        {
            "memberName": "John Smith",
            "memberNumber": "987654321",
            "phoneNumber": "555-555-5555",
            "email": "noreply@iccu.com",
            "accountNumber": "9999999999999999",
            "pan": "1234123412341234",
            "street": "123 Penny Lane",
            "city": "Pocatello",
            "state": "ID",
            "postalCode": "83201",
            "transactions": [
                {
                    "merchant": "Bob's Crab Shack",
                    "date": "4/30/2020",
                    "amount": "$45.66"
                }
            ],
            "notes": "This is just freeform text.  Be reasonable."
        }

     */

    public ESignVisaAbstractMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public abstract Boolean usesTransactionData();

    public abstract String getFormName();

    public abstract List<ESignData.ESignTextData> getTextData();

    public abstract List<ESignData.ESignSelectData> getRadioData();

    public abstract List<ESignData.ESignSelectData> getCheckData();

    public override ESignSendCeremonyRequest mapRequest() {
        Map<String, Object> json = this.jsonData;

        String createdBy = UserInfo.getUserEmail();
        String memberName = (String)json.get('memberName');
        String memberNumber = (String)json.get('memberNumber');
        String phoneNumber = (String)json.get('phoneNumber');
        String email = (String)json.get('email');
        String accountNumber = (String)json.get('accountNumber');
        String pan = (String)json.get('pan');
        String street = (String)json.get('street');
        String city = (String)json.get('city');
        String state = (String)json.get('state');
        String postal = (String)json.get('postalCode');
        String cityStateZip = '' + city + ', ' + state + '  ' + postal;
        String notes = (String)json.get('notes');

        List<Map<String, Object>> rawTxns = APIUtils.convertObjectList((List<Object>)json.get('transactions'));

        List<ESignData.ESignTextData> textData = new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Team_Member', createdBy),
            new ESignData.ESignTextData('Member_Name', memberName),
            new ESignData.ESignTextData('Member_Number', memberNumber),
            new ESignData.ESignTextData('Phone_Number', phoneNumber),
            new ESignData.ESignTextData('Email', email),
            new ESignData.ESignTextData('Account_Number', accountNumber),
            new ESignData.ESignTextData('PAN', pan),
            new ESignData.ESignTextData('Address1', street),
            new ESignData.ESignTextData('City_State_Zip', cityStateZip),
            new ESignData.ESignTextData('Notes', notes)
        };

        textData.addAll(this.getTextData());

        if (this.usesTransactionData() && rawTxns != null) {
            Integer index = 1; // Intentionally staring with 1

            for (Map<String, Object> rawTxn : rawTxns) {
                String merchant = (String)rawTxn.get('merchant');
                String txnDate = (String)rawTxn.get('date');
                String amount = (String)rawTxn.get('amount');

                String merchantKey = 'Merchant' + String.valueOf(index);
                String dateKey = 'Date' + String.valueOf(index);
                String amountKey = 'Amount' + String.valueOf(index);

                textData.add(new ESignData.ESignTextData(merchantKey, merchant));
                textData.add(new ESignData.ESignTextData(dateKey, txnDate));
                textData.add(new ESignData.ESignTextData(amountKey, amount));

                index += 1;
            }
        }

        List<ESignData.ESignSelectData> radioData = new List<ESignData.ESignSelectData>();
        radioData.addAll(this.getRadioData());
        List<ESignData.ESignSelectData> checkData = new List<ESignData.ESignSelectData>();
        checkData.addAll(this.getCheckData());
        ESignData data = new ESignData(textData, radioData, checkData);

        String id = '1';
        String role = 'Member1';
        ESignRecipient recipient = new ESignRecipient(id, memberName, email, role, data);

        String formName = this.getFormName();
        DocumentTemplate__mdt docTemplate = this.getTemplateMetadata(formName);
        String templateId = docTemplate.templateId__c;
        Integer sequence = 1;
        List<ESignRecipient> recipients = new List<ESignRecipient> {
            recipient
        };
        List<ESignTemplate> templates = new List<ESignTemplate> {
            new ESignTemplate(templateId, sequence, recipients)
        };

        String subject = docTemplate.emailSubject__c;
        ESignCeremony ceremony = new ESignCeremony(subject, templates, new List<ESignCustomField>());

        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);

        return request;
    }

    public String convertBooleanToYesNo(Boolean isTrue) {
        return isTrue ? 'Yes' : 'No';
    }

}