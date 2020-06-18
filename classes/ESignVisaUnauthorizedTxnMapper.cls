public class ESignVisaUnauthorizedTxnMapper extends ESignVisaAbstractMapper {

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


            "wasAtmTransaction": false,
            "wasWithinIdaho": false,
            "cardStatus": "Lost",
            "isCardBlocked": true,
            "wasReportedToPolice": false,
            "dateLossDiscovered": "4/30/2020",
            "dateLossReported": "4/30/2020",
            "dateOfFirstFraud": "4/30/2020",
            "authorityName": "Sgt. Pepper",
            "authorityPhone": "555-555-5555",
            "authorityReportNumber": "THX1138",
            "unauthorizedUser": "Johnny Smith",
            "unauthorizedUserAddress": "123 Penny Lane"
        }

        NOTE:
            - `cardStatus` has the following domain values:
                - Lost
                - Stolen
                - In my Possession
     */

    public ESignVisaUnauthorizedTxnMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override Boolean usesTransactionData() {
        return true;
    }

    public override String getFormName() {
        return 'VISA_UNAUTHORIZED';
    }

    public override List<ESignData.ESignTextData> getTextData() {
        String wasAtmTxn = this.convertBooleanToYesNo((Boolean)this.jsonData.get('wasAtmTransaction'));
        String wasWithinIdaho = this.convertBooleanToYesNo((Boolean)this.jsonData.get('wasWithinIdaho'));
        String isCardBlocked = this.convertBooleanToYesNo((Boolean)this.jsonData.get('isCardBlocked'));
        String wasReportedToPolice = this.convertBooleanToYesNo((Boolean)this.jsonData.get('wasReportedToPolice'));
        String cardStatus = (String)this.jsonData.get('cardStatus');
        String dateLossDiscovered = (String)this.jsonData.get('dateLossDiscovered');
        String dateLossReported = (String)this.jsonData.get('dateLossReported');
        String dateOfFirstFraud = (String)this.jsonData.get('dateOfFirstFraud');
        String authorityName = (String)this.jsonData.get('authorityName');
        String authorityPhone = (String)this.jsonData.get('authorityPhone');
        String authorityReportNumber = (String)this.jsonData.get('authorityReportNumber');
        String unauthorizedUser = (String)this.jsonData.get('unauthorizedUser');
        String unauthorizedUserAddress = (String)this.jsonData.get('unauthorizedUserAddress');

        return new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('ATM_Transaction', wasAtmTxn),
            new ESignData.ESignTextData('In_Idaho', wasWithinIdaho),
            new ESignData.ESignTextData('Card_Blocked', isCardBlocked),
            new ESignData.ESignTextData('Police_Reported', wasReportedToPolice),
            new ESignData.ESignTextData('Card_Status', cardStatus),
            new ESignData.ESignTextData('Loss_Date', dateLossDiscovered),
            new ESignData.ESignTextData('Reported_Date', dateLossReported),
            new ESignData.ESignTextData('First_Date', dateOfFirstFraud),
            new ESignData.ESignTextData('Authority', authorityName),
            new ESignData.ESignTextData('Authority_Phone', authorityPhone),
            new ESignData.ESignTextData('Authority_Report', authorityReportNumber),
            new ESignData.ESignTextData('Unauthorized_User', unauthorizedUser),
            new ESignData.ESignTextData('Unauthorized_Address', unauthorizedUserAddress)
        };
    }

    public override List<ESignData.ESignSelectData> getRadioData() {
        return new List<ESignData.ESignSelectData>();
    }

    public override List<ESignData.ESignSelectData> getCheckData() {
        return new List<ESignData.ESignSelectData>();
    }

}