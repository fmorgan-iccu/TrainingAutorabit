public class ESignVisaMerchNotAsDescMapper extends ESignVisaAbstractMapper {
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

            "disputeReason": "Counterfeit Merchandise",
            "reasonDesc": "It was pure chafa!",
            "contactMerchDate": "4/10/2020",
            "merchRepName": "Jane Smith",
            "contactMethod": "Phone",
            "wasReturned": true,
            "returnedVia": "DHL",
            "merchResponse": "A complete fabrication!",
            "previousNegotiation": true,
            "nogitiationDescription": "Some description"
        }

        NOTE:
            - `disputeReason` domain values are as follows:
                - Counterfeit Merchandise
                - Damaged/Defective Merchandise
                - Misrepresentation/Not as Described
                - Quality Issues
            - `contactMethod` domain values are as follows:
                - Phone
                - Email
                - In Person
            - `returnedVia` domain values are as follows:
                - DHL
                - In Person
                - FedEx
                - UPS
                - USPS
     */

    public ESignVisaMerchNotAsDescMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_MERCH_NOT_AS_DESC';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        Map<String, Object> json = this.jsonData;

        String disputeReason = (String)json.get('disputeReason');
        String reasonDesc = (String)json.get('reasonDesc');
        String contactMerchDate = (String)json.get('contactMerchDate');
        String merchRepName = (String)json.get('merchRepName');
        String contactMethod = (String)json.get('contactMethod');
        String wasReturned = this.convertBooleanToYesNo((Boolean)json.get('wasReturned'));
        String returnedVia = (String)json.get('returnedVia');
        String merchResponse = (String)json.get('merchResponse');
        String wasPreviousNegotiation = this.convertBooleanToYesNo((Boolean)json.get('previousNegotiation'));
        String negotiationDescription = (String)json.get('nogitiationDescription');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Dispute_Reason', disputeReason),
            new ESignData.ESignTextData('Reason', reasonDesc),
            new ESignData.ESignTextData('Merchant_Date', contactMerchDate),
            new ESignData.ESignTextData('Merchant_Rep', merchRepName),
            new ESignData.ESignTextData('Merchant_Method', contactMethod),
            new ESignData.ESignTextData('Merchant_Returned', wasReturned),
            new ESignData.ESignTextData('Merchant_Response', merchResponse),
            new ESignData.ESignTextData('Return_Method', returnedVia),
            new ESignData.ESignTextData('Ongoing_Negotiations', wasPreviousNegotiation),
            new ESignData.ESignTextData('Negotiation_Description', negotiationDescription)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }
}