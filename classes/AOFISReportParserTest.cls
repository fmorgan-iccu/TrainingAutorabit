@IsTest
private class AOFISReportParserTest {
	@IsTest
    private static void testHappyPath() {
        String testData = '{"birthDt":"01011965","chexOk":"true","chexResultId":"550168683","cityNm":"Chubbuck","validGovernmentNumberTxt":"SSN AVAILABLE FOR RANDOMIZED ISSUANCE              ID THEFT ALERT","closureNotFoundCd":"Y","totalClosures":"0","previousInquiriesNotFoundCd":"Y","validDriversLicenseTxt":"VALID DRIVERS LICENSE FORMAT","inquiryTrackingId":"672780734","numberInquiryCustomersTotalQty":"0","previousInquiryTotalQty":"0","previousInquiriesQty":"No Previous Inquiries Found.","unpaidRetailItemsFoundTxt":"NOTE * THERE IS NO RETAIL INDICATOR                                 ","unpaidRetailItemsNotFoundTxt":"True","purchasedDebtNotFoundCd":"Y","purchasedDebtTotal":"0","purchasedDebtDisputedQty":"0","purchasedDebtUnpaidQty":"0","purchasedDebtPaidQty":"0","purchaseddebtPartiallyPaidQty":"0","purchasedDebtSoldQty":"0","accountAcceptanceTxt":"REVIEW","creditBureauScoreNbr":"0000","reasonCd":"Z3","reasonTxt":"INSUFFICIENT DATA FOUND                                     ","scoreNbr":"9999","consumerDetailReferenceNbr":"18IB45364760","debitIdTheftDetailTxt":"CONSUMER ID THEFT ALERT","countryNm":"USA","firstNm":"Opalen","governmentNbr":"666686061","identificationStateCd":"ID","identificationStateNbr":"df104474d","lastNm":"Meadows","postalPlusFourCd":"83202","stateCd":"ID","streetAddressTxt":"4400 Central Way","transactionTrackingId":"1536687363945:734:UXAP302U_Z1.FNFIS.COM:"}';
        Map<String, Object> testJson = (Map<String, Object>) JSON.deserializeUntyped(testData);
        
        try {
            Map<String, Object> payload = new Map<String, Object>{
                AOReportParser.RAW_DATA_KEY => testJson
            };
            AOApplicationInfo appInfo = new AOApplicationInfo();
                
            AOFISReportParser parser = new AOFISReportParser();
            parser.parsePayload(payload, appInfo);
            
            System.assert(appInfo.backgroundCheckReport != null, 'Report was null!');
            
            String output = JSON.serialize(appInfo.backgroundCheckReport);
            System.debug(output);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    @IsTest
    private static void testUnhappyPath() {
        AOFISReportParser parser = new AOFISReportParser();
        AOApplicationInfo appInfo = new AOApplicationInfo();
        
        try {
            // Null payload
            parser.parsePayload(null, appInfo);
            Map<String, Object> report = appInfo.backgroundCheckReport;
            System.assert(report != null, 'Report was null with null payload!');
            
            // Null app info; no assertions, it just shouldn't throw an exception
            parser.parsePayload(new Map<String, Object>(), null);
            
            // Missing Map
            parser.parsePayload(new Map<String, Object>(), appInfo);
            report = appInfo.backgroundCheckReport;
            System.assert(report != null, 'Report was null with empty payload!');
            
            // Missing all data
            Map<String, Object> payload = new Map<String, Object> {
                AOReportParser.RAW_DATA_KEY => new Map<String, Object>()
            };
            parser.parsePayload(payload, appInfo);
            report = appInfo.backgroundCheckReport;
            System.assert(report != null, 'Report was null with missing data!');
        } catch (Exception e) {
            System.assert(false, 'Unexpected Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}