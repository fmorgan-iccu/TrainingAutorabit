public class AOFISReportParser extends AOReportParser {
	public override String getReportName() {
        return 'FIS Qualifile';
    }
    
    public override void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        try {
            if (payload == null || appInfo == null) {
                throw new IllegalArgumentException('Payload nor ApplicationInfo can be null.');
            }
            
            Map<String, Object> data = (Map<String, Object>)payload.get(RAW_DATA_KEY);

            if (data == null) {
                throw new IllegalArgumentException('Data was not present in the payload map.');
            }
            
            Map<String, Object> consumerInfoSection = this.createDataElement('Consumer Information', this.parseConsumerInformation(data));
            Map<String, Object> accountActionsSection = this.createDataElement('Account Actions', this.parseAccountActions(data));
            Map<String, Object> chexSection = this.createDataElement('ChexSystems® History', this.parseChexSystems(data));
            
            List<Map<String, Object>> summary = new List<Map<String, Object>>{
                consumerInfoSection,
                accountActionsSection
            };
                
            List<Map<String, Object>> sections = new List<Map<String, Object>>{
                consumerInfoSection,
                accountActionsSection,
                chexSection
            };
            
        	Map<String, Object> report = this.createReport(summary, sections);
            
        	appInfo.backgroundCheckReport = report;
        } catch (Exception e) {
            if (appInfo != null) {
                appInfo.backgroundCheckReport = this.createExceptionMap(e);
            }
        }
    }
    
    private List<List<Map<String, Object>>> parseConsumerInformation(Map<String, Object> data) {
        List<Map<String, Object>> addressInfo = new List<Map<String, Object>>();
        
        String firstName = (String)data.get('firstNm');
        String lastName = (String)data.get('lastNm');
        
        if (firstName != null && lastName != null) {
            String name = firstName + ' ' + lastName;
            addressInfo.add(this.createDataElement('', name, REPORT_FULL_WIDTH));
        }
        
        String street = (String)data.get('streetAddressTxt');
        if (street != null) {
            addressInfo.add(this.createDataElement('', street, REPORT_FULL_WIDTH));
        }

        String city = (String)data.get('cityNm');
        String state = (String)data.get('stateCd');
        String zip = (String)data.get('postalPlusFourCd');
        
        String cityStateZip = AddressUtils.combineCityStateZip(city, state, zip);
   
        if (cityStateZip != null) {
            addressInfo.add(this.createDataElement('', cityStateZip, REPORT_FULL_WIDTH));
        }
        
        List<Map<String, Object>> dlInfo = new List<Map<String, Object>>();
        
        String dlState = (String)data.get('identificationStateCd');
        if (dlState == null) {
            dlState = 'Unknown';
        }
        dlInfo.add(this.createDataElement('DL State', dlState));

        String dlNumber = (String)data.get('identificationStateNbr');
        if (dlNumber == null) {
            dlNumber = 'Unknown';
        }
        dlInfo.add(this.createDataElement('DL#', dlNumber));

        return new List<List<Map<String, Object>>> {
            addressInfo,
            dlInfo
        };
    }
    
    private List<List<Map<String, Object>>> parseAccountActions(Map<String, Object> data) {
        List<Map<String, Object>> accountActions = new List<Map<String, Object>>();
        
        Map<String, Object> accountAcceptanceTxt = this.parseField(data, 'accountAcceptanceTxt', 'Account Acceptance');
        this.addDataElementToList(accountAcceptanceTxt, accountActions);
        
        Map<String, Object> reasonTxt = this.parseField(data, 'reasonTxt', 'Reason');
        this.addDataElementToList(reasonTxt, accountActions);
        
        Map<String, Object> reasonCd = this.parseField(data, 'reasonCd', 'Reason Code');
        this.addDataElementToList(reasonCd, accountActions);
        
        Map<String, Object> closureReasonCategoryTxt = this.parseField(data, 'closureReasonCategoryTxt', 'Closure Reason Category');
        this.addDataElementToList(closureReasonCategoryTxt, accountActions);
        
        Map<String, Object> closureReasonTxt = this.parseField(data, 'closureReasonTxt', 'Closure Reason');
        this.addDataElementToList(closureReasonTxt, accountActions);
        
        Map<String, Object> originalChargeOffAmt = this.parseField(data, 'originalChargeOffAmt', 'Original Charge Off Amount');
        this.addDataElementToList(originalChargeOffAmt, accountActions);
        
        Map<String, Object> reportedDt = this.parseField(data, 'reportedDt', 'Reported Date');
        this.addDataElementToList(reportedDt, accountActions);
        
        Map<String, Object> customerNm = this.parseField(data, 'customerNm', 'Institution Name');
        this.addDataElementToList(customerNm, accountActions);
        
		Map<String, Object> accountActionTxt1 = this.parseField(data, 'accountActionTxt1', 'Account Action');
        this.addDataElementToList(accountActionTxt1, accountActions);  
        
        Map<String, Object> scoreNbr = this.parseField(data, 'scoreNbr', 'Score Number');
        this.addDataElementToList(scoreNbr, accountActions);  
        
        return new List<List<Map<String, Object>>> {
            accountActions
        };
    }
    
    private List<List<Map<String, Object>>> parseChexSystems(Map<String, Object> data) {
        List<Map<String, Object>> chexInfo = new List<Map<String, Object>>();
        
        String previousInquiries = (String)data.get('previousInquiriesQty');
        if (previousInquiries != null) {
            chexInfo.add(this.createDataElement('', previousInquiries));
        }
        
        Map<String, Object> purchasedDebtTotal = this.parseField(data, 'purchasedDebtTotal', 'Purchase Debt Total');
        this.addDataElementToList(purchasedDebtTotal, chexInfo);
        
        Map<String, Object> purchasedDebtDisputedQty = this.parseField(data, 'purchasedDebtDisputedQty', 'Purchased Debt Disputed');
        this.addDataElementToList(purchasedDebtDisputedQty, chexInfo);
        
        Map<String, Object> purchasedDebtUnpaidQty = this.parseField(data, 'purchasedDebtUnpaidQty', 'Purchased Debt Unpaid');
        this.addDataElementToList(purchasedDebtUnpaidQty, chexInfo);
        
        Map<String, Object> purchasedDebtPaidQty = this.parseField(data, 'purchasedDebtPaidQty', 'Purchased Debt Paid');
        this.addDataElementToList(purchasedDebtPaidQty, chexInfo);
        
        Map<String, Object> purchasedDebtSoldQty = this.parseField(data, 'purchasedDebtSoldQty', 'Purchased Debt Sold');
        this.addDataElementToList(purchasedDebtSoldQty, chexInfo);
        
        Map<String, Object> totalClosures = this.parseField(data, 'totalClosures', 'Total Closures');
        this.addDataElementToList(totalClosures, chexInfo);
        
        Map<String, Object> unpaidRetailItemsFoundTxt = this.parseField(data, 'unpaidRetailItemsFoundTxt', 'Unpaid Retail Items');
        this.addDataElementToList(unpaidRetailItemsFoundTxt, chexInfo);

        return new List<List<Map<String, Object>>> {
            chexInfo
        };
    }

    /* Utility Methods */

    private Map<String, Object> parseField(Map<String, Object> data, String key, String title) {
        String value = (String)data.get(key);
        
        if (value == null) {
            return null;
        }

        return this.createDataElement(title, value.trim());
    }
}