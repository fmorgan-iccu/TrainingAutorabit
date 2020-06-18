@IsTest
private class AOFISReportParserTest {

    @IsTest
    private static void testHappyPath() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"I\'m not a permanent resident, but am an employee, employer, student and/or retiree working in Idaho.","system_info":[{"system_name":"FIS","system_display_name":"Qualifile","status":"DECLINE","decision":"DECLINE","everything":"{\\"birthDt18IB45364760\\":\\"01011965\\",\\"chexOk\\":\\"true\\",\\"chexResultId\\":\\"550168683\\",\\"cityNm\\":\\"Chubbuck\\",\\"validGovernmentNumberTxt\\":\\"SSN AVAILABLE FOR RANDOMIZED ISSUANCE              ID THEFT ALERT\\",\\"closureNotFoundCd\\":\\"Y\\",\\"totalClosures\\":\\"0\\",\\"previousInquiriesNotFoundCd\\":\\"Y\\",\\"validDriversLicenseTxt\\":\\"VALID DRIVERS LICENSE FORMAT\\",\\"inquiryTrackingId\\":\\"672780734\\",\\"numberInquiryCustomersTotalQty\\":\\"0\\",\\"previousInquiryTotalQty\\":\\"0\\",\\"previousInquiriesQty\\":\\"No Previous Inquiries Found.\\",\\"unpaidRetailItemsFoundTxt\\":\\"NOTE * THERE IS NO RETAIL INDICATOR                                 \\",\\"unpaidRetailItemsNotFoundTxt\\":\\"True\\",\\"purchasedDebtNotFoundCd\\":\\"Y\\",\\"purchasedDebtTotal\\":\\"0\\",\\"purchasedDebtDisputedQty\\":\\"0\\",\\"purchasedDebtUnpaidQty\\":\\"0\\",\\"purchasedDebtPaidQty\\":\\"0\\",\\"purchaseddebtPartiallyPaidQty\\":\\"0\\",\\"purchasedDebtSoldQty\\":\\"0\\",\\"accountAcceptanceTxt\\":\\"REVIEW\\",\\"creditBureauScoreNbr\\":\\"0000\\",\\"reasonCd\\":\\"Z3\\",\\"reasonTxt\\":\\"INSUFFICIENT DATA FOUND                                     \\",\\"scoreNbr\\":\\"9999\\",\\"consumerDetailReferenceNbr\\":\\"18IB45364760\\",\\"debitIdTheftDetailTxt\\":\\"CONSUMER ID THEFT ALERT\\",\\"countryNm\\":\\"USA\\",\\"firstNm\\":\\"Opalen\\",\\"governmentNbr\\":\\"666686061\\",\\"identificationStateCd\\":\\"ID\\",\\"identificationStateNbr\\":\\"df104474d\\",\\"lastNm\\":\\"Meadows\\",\\"postalPlusFourCd\\":\\"83202\\",\\"stateCd\\":\\"ID\\",\\"streetAddressTxt\\":\\"4400 Central Way\\",\\"transactionTrackingId\\":\\"1536687363945:734:UXAP302U_Z1.FNFIS.COM:\\"}","user_action":"","tracking_number":"HGXQRZ7"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        // The payload above should only have one system_info response to keep this code lean.
        AOApplicationRestRequest.SystemInfo systemInfo = request.applicant.system_info[0];

        Test.startTest();

        AOFISReportParser parser = new AOFISReportParser();
        try {
            parser.parsePayload(systemInfo, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        System.assertNotEquals(null, appInfo.backgroundCheckReport);
        System.assert(appInfo.backgroundCheckReport.containsKey(AOReportParser.REPORT_SUMMARY_KEY), 'Report summary should be present for the report.');
        System.assert(appInfo.backgroundCheckReport.containsKey(AOReportParser.REPORT_DATA_KEY), 'Report data should be present for the report.');

        List<Map<String, Object>> dataElements = (List<Map<String, Object>>)appInfo.backgroundCheckReport.get(AOReportParser.REPORT_DATA_KEY);
        System.assertNotEquals(null, dataElements);
        System.assertEquals(3, dataElements.size());
        System.assertEquals('Consumer Information', dataElements[0].get(AOReportParser.REPORT_TITLE_KEY));
        System.assertEquals('Account Actions', dataElements[1].get(AOReportParser.REPORT_TITLE_KEY));
        System.assertEquals('ChexSystems® History', dataElements[2].get(AOReportParser.REPORT_TITLE_KEY));
    }

    @IsTest
    private static void testError() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"I\'m not a permanent resident, but am an employee, employer, student and/or retiree working in Idaho.","system_info":[{"system_name":"FIS","system_display_name":"Qualifile","status":"DECLINE","decision":"DECLINE","everything":"{","user_action":"","tracking_number":"HGXQRZ7"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        // The payload above should only have one system_info response to keep this code lean.
        AOApplicationRestRequest.SystemInfo systemInfo = request.applicant.system_info[0];

        Test.startTest();

        AOFISReportParser parser = new AOFISReportParser();
        try {
            parser.parsePayload(systemInfo, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        System.assertNotEquals(null, appInfo.backgroundCheckReport);
        System.assert(appInfo.backgroundCheckReport.containsKey(AOReportParser.REPORT_DATA_KEY), 'Report data should be present for the report.');

        List<Map<String, Object>> dataElements = (List<Map<String, Object>>)appInfo.backgroundCheckReport.get(AOReportParser.REPORT_DATA_KEY);
        System.assertNotEquals(null, dataElements);
        System.assertEquals(2, dataElements.size());
        System.assertEquals('Error', dataElements[0].get(AOReportParser.REPORT_TITLE_KEY));
        System.assertEquals('Details', dataElements[1].get(AOReportParser.REPORT_TITLE_KEY));
    }

}