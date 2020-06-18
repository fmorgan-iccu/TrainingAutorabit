public class ESignVisaPaidByOtherMeansMapper extends ESignVisaAbstractMapper {
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

            "usedSameAccount": true,
            "checkNumber": "123456789",
            "achAccountNumber": "4889998348853",
            "cardNumber": "983498734",
            "proof": "Check",
            "contactMerchDate": "4/10/2020",
            "merchRepName": "Jane Smith",
            "contactMethod": "Phone",
            "merchResponse": "A complete fabrication!"
        }

        NOTE:
            - `proof` domain values are as follows:
                - Check
                - ACH
                - Card
                - Cash
            - `contactMethod` domain values are as follows:
                - Phone
                - Email
                - In Person
     */

    public ESignVisaPaidByOtherMeansMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_PAID_OTHER_MEANS';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String usedSameAccount = this.convertBooleanToYesNo((Boolean)json.get('usedSameAccount'));
        String checkNumber = (String)json.get('checkNumber');
        String accountNumber = (String)json.get('achAccountNumber');
        String cardNumber = (String)json.get('cardNumber');
        String contactMerchDate = (String)json.get('contactMerchDate');
        String merchRepName = (String)json.get('merchRepName');
        String contactMethod = (String)json.get('contactMethod');
        String merchResponse = (String)json.get('merchResponse');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Same_Account', usedSameAccount),
            new ESignData.ESignTextData('Proof_Check', checkNumber),
            new ESignData.ESignTextData('Proof_ACH', accountNumber),
            new ESignData.ESignTextData('Proof_Card', cardNumber),
            new ESignData.ESignTextData('Merchant_Date', contactMerchDate),
            new ESignData.ESignTextData('Merchant_Rep', merchRepName),
            new ESignData.ESignTextData('Merchant_Method', contactMethod),
            new ESignData.ESignTextData('Merchant_Response', merchResponse)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        Map<String, Object> json = this.jsonData;

        String proof = (String)json.get('proof');

        return new List<ESignData.ESignSelectData> {
            new ESignData.ESignSelectData('Radio_Proof', proof, true)
        };
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}