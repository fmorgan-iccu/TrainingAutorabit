public with sharing class ESignVisaRefundMapper extends ESignVisaAbstractMapper {
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


            "refundAcknowledged": false,
            "merchantDate": "4/30/2020",
            "merchantRepresentative": "Billy",
            "merchantContactMethod":  "Phone",
            "returnDate": "4/30/2020",
            "returnedVia": "In Person",
            "merchantResponse": "This is more freeform text.  Be reasonable."
        }

        NOTE:
            - The domain values for `merchantContactMethod` are:
                - Phone
                - Email
                - In Person
            - The domain values for `returnedVia` are:
                - DHL
                - In Person
                - FedEx
                - UPS
                - USPS
     */

    public ESignVisaRefundMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_REF_NOT_PROC';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String wasRefundAcked = this.convertBooleanToYesNo((Boolean)this.jsonData.get('refundAcknowledged'));
        String merchantDate = (String)json.get('merchantDate');
        String merchantRep = (String)json.get('merchantRepresentative');
        String contactMethod = (String)json.get('merchantContactMethod');
        String returnDate = (String)json.get('returnDate');
        String returnedVia = (String)json.get('returnedVia');
        String merchantResponse = (String)json.get('merchantResponse');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Refund_Acknowledgment', wasRefundAcked),
            new ESignData.ESignTextData('Merchant_Date', merchantDate),
            new ESignData.ESignTextData('Merchant_Rep', merchantRep),
            new ESignData.ESignTextData('Merchant_Method', contactMethod),
            new ESignData.ESignTextData('Return_Date', returnDate),
            new ESignData.ESignTextData('Return_Method', returnedVia),
            new ESignData.ESignTextData('Merchant_Response', merchantResponse)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}