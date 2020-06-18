@IsTest
private class AOFATCADecisionLogParserTest {

    @IsTest
    private static void testHappyPath() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"I\'m not a permanent resident, but am an employee, employer, student and/or retiree working in Idaho.","system_info":[{"system_name":"FATCA","system_display_name":"FATCA Response","status":"Success","decision":"APPROVE","everything":"{\\"noBackupWithholding\\":\\"Yes\\",\\"noAccountsOutsideUS\\":\\"Yes\\",\\"exemptPayeeCode\\":null,\\"ssnAndUsPersonCertified\\":\\"Yes\\",\\"fatcaReportingCode\\":\\"7890\\"}","user_action":"null","tracking_number":"X76BWNV"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOFATCADecisionLogParser parser = new AOFATCADecisionLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        String expectedMessage = 'No backup withholding: Yes; No accounts outside US: Yes; Exempt payee code: N/A; SSN and US person certified: Yes; FATCA reporting code: 7890';
        System.assertEquals(expectedMessage, result.message);
    }

}