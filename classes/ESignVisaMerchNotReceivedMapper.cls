public class ESignVisaMerchNotReceivedMapper extends ESignVisaAbstractMapper {
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

            "deliveryDate": "5/1/2020",
            "productDesc": "Lego 75275 A-wing Starfighter",
            "contactMerchDate": "4/10/2020",
            "merchRepName": "Jane Smith",
            "contactMethod": "Phone",
            "merchResponse": "A complete fabrication!",
            "hasBondingAuthority": false,
            "shippedWrong": false,
            "returnedMerchandise": true
        }

        NOTE:
            - `contactMethod` domain values are as follows:
                - Phone
                - Email
                - In Person
     */

    public ESignVisaMerchNotReceivedMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_MERCH_NOT_REC';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String deliveryDate = (String)json.get('deliveryDate');
        String productDesc = (String)json.get('productDesc');
        String contactMerchDate = (String)json.get('contactMerchDate');
        String merchRepName = (String)json.get('merchRepName');
        String contactMethod = (String)json.get('contactMethod');
        String merchResponse = (String)json.get('merchResponse');
        String hasBondingAuthority = this.convertBooleanToYesNo((Boolean)json.get('hasBondingAuthority'));
        String shippedWrong = this.convertBooleanToYesNo((Boolean)json.get('shippedWrong'));
        String returnedMerchandise = this.convertBooleanToYesNo((Boolean)json.get('returnedMerchandise'));

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Delivery_Date', deliveryDate),
            new ESignData.ESignTextData('Product_Description', productDesc),
            new ESignData.ESignTextData('Merchant_Date', contactMerchDate),
            new ESignData.ESignTextData('Merchant_Rep', merchRepName),
            new ESignData.ESignTextData('Merchant_Method', contactMethod),
            new ESignData.ESignTextData('Merchant_Response', merchResponse),
            new ESignData.ESignTextData('BondInsScheme', hasBondingAuthority),
            new ESignData.ESignTextData('Wrong_Late', shippedWrong),
            new ESignData.ESignTextData('Return_Merchandise', returnedMerchandise)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}