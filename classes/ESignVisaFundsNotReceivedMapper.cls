public with sharing class ESignVisaFundsNotReceivedMapper extends ESignVisaAbstractMapper {
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
            "notes": "This is just freeform text.  Be reasonable.",

            "amountRequested": "$400.00",
            "amountReceived": "$380.00",
            "atmLocation": "456 Nickel Ct, Pocatello, ID 83201"
        }

     */

    public ESignVisaFundsNotReceivedMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_FUNDS_NOT_REC';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String amountRequested = (String)json.get('amountRequested');
        String amountReceived = (String)json.get('amountReceived');
        String atmLocation = (String)json.get('atmLocation');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Amount_Requested', amountRequested),
            new ESignData.ESignTextData('Amount_Received', amountReceived),
            new ESignData.ESignTextData('ATM_Location', atmLocation)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}