public class ESignSubsequentActionMapper extends ESignAbstractMapper {

    /**
        This mapper expects a format as follows:

            {
                "iccu": {
                    "accountNumber": "99999999999",
                    "requestDate": "4/24/2020",
                    "collateralDescription": "2020 CHEVY CAMERO",
                    "vin": "IDSPISPOPD",

                    "releaseBorrower": true,
                    "releaseDate": "5/1/2020",
                    "releaseName": "John Smith",
                    "borrowerNumber": "8888888888888",

                    "loanModification": true,
                    "unpaidBalance": "5,567.34",
                    "interestRate": "16.78",
                    "interestStartDate": "5/1/2020",
                    "modMonthlyPayment": true,
                    "modRate": false,
                    "modNone": false,
                    "monthlyPayment1": "786.36",
                    "dueDate1": "5/1/2020",
                    "monthlyPayment2": "400.00",
                    "modReason1": "xxxxxxxx",
                    "modReason2": "",

                    "creditProtection": true,
                    "makeMorePayments": true,
                    "increasePayments": false,
                    "monthlyPayment3": "456.34",

                    "cancelationOfInsurance": true,
                    "lifeInsurance": true,
                    "lifeName1": "Billy Smith",
                    "lifeName2": "Jane Smith",

                    "creditDisability": true,
                    "creditName1": "Billy Smith"
                },
                "borrowers": [
                    {
                        "name": "John Smith",
                        "email": "jsmith@example.com"
                    },
                    {
                        "name": "Jane Smith",
                        "email": "jsmith1@example.com"
                    },
                    {
                        "name": "Billy Smith",
                        "email": "bsmith@example.com"
                    }
                ]
            }

        NOTES:
            - You must have at LEAST 1 and can have AT MOST 3 borrowers.  They will be added
              to the document in the order in which they appear in the array.
            - Amounts leave off the $ since they are baked into the document.
 */


    public ESignSubsequentActionMapper(String jsonPayload) {
        super(jsonPayload);
    }

    public override ESignSendCeremonyRequest mapRequest() {
        Map<String, Object> json = this.jsonData;

        DocumentTemplate__mdt docTemplate = this.getTemplateMetadata('SUBSEQUENT_ACTION');

        List<Map<String, Object>> rawBorrowers = APIUtils.convertObjectList((List<Object>)json.get('borrowers'));
        Map<String, Object> rawIccu = (Map<String, Object>)json.get('iccu');

        ESignRecipient iccuRecipient = this.getICCUSigner(rawIccu, docTemplate);
        List<ESignRecipient> recipients = this.getMemberRecipients(rawBorrowers);

        // Add the names of the borrowers to the ICCU text data
        Integer borrowerIndex = 1;
        for (ESignRecipient borrower : recipients) {
            String key = 'Borrower' + String.valueOf(borrowerIndex) + '_Name';
            String value = borrower.name;

            ESignData.ESignTextData borrowerName =  new ESignData.ESignTextData(key, value);

            List<ESignData.ESignTextData> textData = iccuRecipient.data.textData;
            textData.add(borrowerName);


            borrowerIndex += 1;
        }

        // Add the ICCU recipient with the others for the template
        recipients.add(iccuRecipient);

        String templateId = docTemplate.templateId__c;
        Integer sequence = 1;
        ESignTemplate template = new ESignTemplate(templateId, sequence, recipients);

        String subject = docTemplate.emailSubject__c;
        List<ESignTemplate> templates = new List<ESignTemplate> {
            template
        };

        ESignCeremony ceremony = new ESignCeremony(subject, templates, new List<ESignCustomField>());
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(ceremony);

        return request;
    }

    private ESignRecipient getICCUSigner(Map<String, Object> json, DocumentTemplate__mdt template) {
        String createdBy = UserInfo.getUserEmail();
        String accountNumber = (String)json.get('accountNumber');
        String requestDate = (String)json.get('requestDate');
        String collateralDescription = (String)json.get('collateralDescription');
        String vin = (String)json.get('vin');

        Boolean releaseBorrower = (Boolean)json.get('releaseBorrower');
        String releaseDate = (String)json.get('releaseDate');
        String releaseName = (String)json.get('releaseName');
        String borrowerNumber = (String)json.get('borrowerNumber');

        Boolean isLoanModification = (Boolean)json.get('loanModification');
        String unpaidBalance = (String)json.get('unpaidBalance');
        String interestRate = (String)json.get('interestRate');
        String interestStartDate = (String)json.get('interestStartDate');
        Boolean modMonthlyPayment = (Boolean)json.get('modMonthlyPayment');
        Boolean modRate = (Boolean)json.get('modRate');
        Boolean modNone = (Boolean)json.get('modNone');
        String monthlyPayment1 = (String)json.get('monthlyPayment1');
        String dueDate1 = (String)json.get('dueDate1');
        String monthlyPayment2 = (String)json.get('monthlyPayment2');
        String modReason1 = (String)json.get('modReason1');
        String modReason2 = (String)json.get('modReason2');

        Boolean creditProtection = (Boolean)json.get('creditProtection');
        Boolean makeMorePayments = (Boolean)json.get('makeMorePayments');
        Boolean increasePayments = (Boolean)json.get('increasePayments');
        String monthlyPayment3 = (String)json.get('monthlyPayment3');

        Boolean cancelationOfInsurance = (Boolean)json.get('cancelationOfInsurance');
        Boolean lifeInsurance = (Boolean)json.get('lifeInsurance');
        String lifeName1 = (String)json.get('lifeName1');
        String lifeName2 = (String)json.get('lifeName2');

        Boolean creditDisability = (Boolean)json.get('creditDisability');
        String creditName1 = (String)json.get('creditName1');

        /** Begin Text Data */

        List<ESignData.ESignTextData> textData = new List<ESignData.ESignTextData> {
            new ESignData.ESignTextData('Team_Member', createdBy),
            new ESignData.ESignTextData('Account_Number', accountNumber),
            new ESignData.ESignTextData('Request_Date', requestDate),
            new ESignData.ESignTextData('Collateral_Description', collateralDescription),
            new ESignData.ESignTextData('VIN', vin),
            new ESignData.ESignTextData('Release_Date', releaseDate),
            new ESignData.ESignTextData('Release_Name', releaseName),
            new ESignData.ESignTextData('Borrower#', borrowerNumber),
            new ESignData.ESignTextData('Unpaid_Balance', unpaidBalance),
            new ESignData.ESignTextData('Interest_Rate', interestRate),
            new ESignData.ESignTextData('Interest_StartDate', interestStartDate),
            new ESignData.ESignTextData('Monthly_Payment1', monthlyPayment1),
            new ESignData.ESignTextData('Due_Date1', dueDate1),
            new ESignData.ESignTextData('Monthly_Payment2', monthlyPayment2),
            new ESignData.ESignTextData('Mod_Reason1', modReason1),
            new ESignData.ESignTextData('Mod_Reason2', modReason2),
            new ESignData.ESignTextData('Monthly_Payment3', monthlyPayment3),
            new ESignData.ESignTextData('Life_Name1', lifeName1),
            new ESignData.ESignTextData('Life_Name2', lifeName2),
            new ESignData.ESignTextData('Credit_Name1', creditName1),
            new ESignData.ESignTextData('ActionType', 'RELEASE')
        };

        /** End Text Data */

        /** Begin Radio Data */

        List<ESignData.ESignSelectData> radioData = new List<ESignData.ESignSelectData>();

        String paymentModName = 'Payment_Modification';

        if (modMonthlyPayment == true) {
            radioData.add(new ESignData.ESignSelectData(paymentModName, 'MOD_MONTHLY_PAYMENT', true));
        }
        if (modRate == true) {
            radioData.add(new ESignData.ESignSelectData(paymentModName, 'MOD_RATE', true));
        }
        if (modNone == true) {
            radioData.add(new ESignData.ESignSelectData(paymentModName, 'MOD_NONE', true));
        }

        String creditInsuranceName = 'Subsequent_Radio';
        if (makeMorePayments == true) {
            radioData.add(new ESignData.ESignSelectData(creditInsuranceName, 'Make_More_Payments', true));
        } else if (increasePayments == true) {
            radioData.add(new ESignData.ESignSelectData(creditInsuranceName, 'Increase_Monthly_Payment', true));
        }

        /** End Radio Data */

        /** Begin Check Data */

        List<ESignData.ESignSelectData> checkData = new List<ESignData.ESignSelectData> {
            new ESignData.ESignSelectData('Release_Checkbox', 'Release_Checkbox', releaseBorrower),
            new ESignData.ESignSelectData('Modification_Checkbox', 'Modification_Checkbox', isLoanModification),
            new ESignData.ESignSelectData('Subsequent_Checkbox', 'Subsequent_Checkbox', creditProtection),
            new ESignData.ESignSelectData('Cancellation_Checkbox', 'Cancellation_Checkbox', cancelationOfInsurance),
            new ESignData.ESignSelectData('Life_Checkbox', 'Life_Checkbox', lifeInsurance),
            new ESignData.ESignSelectData('Credit_Checkbox', 'Credit_Checkbox', creditDisability)
        };

        /** End Check Data */

        String id = '0';
        String name = template.defaultRecipientName__c;
        String email = template.defaultRecipientEmail__c;
        String role = 'ICCU1';
        ESignData data = new ESignData(textData, radioData, checkData);
        ESignRecipient recipient = new ESignRecipient(id, name, email, role, data);

        return recipient;
    }

    private List<ESignRecipient> getMemberRecipients(List<Map<String, Object>> rawBorrowers) {
        List<ESignRecipient> recipients = new List<ESignRecipient>();

        Integer i = 1;
        for (Map<String, Object> borrower : rawBorrowers) {
            String id = String.valueOf(i);
            String name = (String)borrower.get('name');
            String email = (String)borrower.get('email');
            String role = 'Borrower' + String.valueOf(i);
            ESignData data = ESignData.empty();

            if (name == null || email == null) {
                continue;
            }

            recipients.add(new ESignRecipient(id, name, email, role, data));

            i += 1;
        }

        return recipients;
    }
}