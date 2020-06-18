public class ESignVisaOverchargeMapper extends ESignVisaAbstractMapper {
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
            "notes": "This is just freeform text.  Be reasonable.",

            "amountCharged": "$1000.34",
            "correctCharge": "$100.34",
            "contactMerchDate": "4/10/2020",
            "merchRepName": "Jane Smith",
            "contactMethod": "Phone",
            "merchResponse": "A complete fabrication!"
        }

        NOTE:
            - `contactMethod` domain values are as follows:
                - Phone
                - Email
                - In Person
     */

    public ESignVisaOverchargeMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_OVERCHARGE';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String amountCharged = (String)json.get('amountCharged');
        String correctCharge = (String)json.get('correctCharge');
        String contactMerchDate = (String)json.get('contactMerchDate');
        String merchRepName = (String)json.get('merchRepName');
        String contactMethod = (String)json.get('contactMethod');
        String merchResponse = (String)json.get('merchResponse');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Amount_Charged', amountCharged),
            new ESignData.ESignTextData('Correct_Charge', correctCharge),
            new ESignData.ESignTextData('Merchant_Date', contactMerchDate),
            new ESignData.ESignTextData('Merchant_Rep', merchRepName),
            new ESignData.ESignTextData('Merchant_Method', contactMethod),
            new ESignData.ESignTextData('Merchant_Response', merchResponse)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}