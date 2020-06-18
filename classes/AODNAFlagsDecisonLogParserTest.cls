@IsTest
private class AODNAFlagsDecisonLogParserTest {

    @IsTest
    private static void testHappyPath() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"WarningFlagsCheck","system_display_name":"Warning Flags Check","status":"Success","decision":"APPROVE","everything":"{\\r\\n    \\"PersonFlags\\": [{ \\"FlagCode\\": \\"CHOF\\" }],\\r\\n    \\"AccountFlags\\": [\\r\\n        { \\"AccountNumber\\": \\"706614501\\", \\"FlagCode\\": [\\"BRST\\"] },\\r\\n        { \\"AccountNumber\\": \\"706638389\\", \\"FlagCode\\": [\\"FRDA\\"] }\\r\\n    ]\\r\\n}","user_action":"","tracking_number":"RZHZMXR"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), 'Error getting DNA flags: ' + appInfo.errors);
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('Person Flags:  CHOF\n\nAccount Flags: | [706614501 Codes: [BRST ]] | [706638389 Codes: [FRDA ]] ', result.message);
        System.assertEquals('APPROVE', result.systemDecision);
        System.assertEquals('Warning Flags Check', parser.getFriendlyName());
    }

    @IsTest
    private static void testMissingEverything() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"WarningFlagsCheck","system_display_name":"Warning Flags Check","status":"Success","decision":"APPROVE","everything":"","user_action":"","tracking_number":"RZHZMXR"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), 'Error getting DNA flags: ' + appInfo.errors);
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('', result.message);
        System.assertEquals('APPROVE', result.systemDecision);
    }

    @IsTest
    private static void testNullJSONValues() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"T9FH3WF","job_reference_code":"PV4DHML"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"WarningFlagsCheck","system_display_name":"Warning Flags Check","status":"Success","decision":"APPROVE","everything":"{\\"PersonFlag\\":null,\\"AccountFlag\\":null}","user_action":"","tracking_number":"RZHZMXR"}]},"coApplicants":[],"products":[{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}],"fundingInfo":{"from_account_uuid":null,"payment_type":"ACH","is_using_external_processor":true,"opened_accounts":[{"account":{"unique_id":"0af4be6b-be26-4313-80d1-90a5dcc00f55","account_name":null,"account_number":"723216904","balance":100.0,"available_balance":null,"is_active":null,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":100.0,"funding_source":"ACH"},{"account":{"unique_id":"034f9e3f-4c2b-4fe5-8a6f-eaccad29c890","account_name":null,"account_number":"723216894","balance":25.0,"available_balance":null,"is_active":null,"product":{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"}},"from_account":{"unique_id":null,"account_name":null,"account_number":null,"balance":null,"available_balance":null,"is_active":null,"product":{"product_name":null,"major_type":null,"minor_type":null}},"funding_amount":25.0,"funding_source":"ACH"}]},"reports":[],"app_status":"Completed","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AODNAFlagsDecisionLogParser parser = new AODNAFlagsDecisionLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), 'Error getting DNA flags: ' + appInfo.errors);
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('Person Flags: \n\nAccount Flags: ', result.message);
        System.assertEquals('APPROVE', result.systemDecision);
    }

}