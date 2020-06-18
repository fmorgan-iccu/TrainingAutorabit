@IsTest
private class AOYouthPrefillLogParserTest {

    @IsTest
    private static void testHappyPath() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"79VNBGP","job_reference_code":"XZFCGH3"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"YouthContactService","system_display_name":"Youth Contact Service","status":"APPROVE","decision":"APPROVE","everything":"","user_action":"","tracking_number":"T4HRH9D"}]},"coApplicants":[],"products":[],"fundingInfo":{},"reports":[],"app_status":"inprogress","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOYouthPrefillLogParser parser = new AOYouthPrefillLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), appInfo.errors);
        System.assertEquals(AOInteractionResult.State.SUCCESS, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('Successful', result.message);
        System.assertEquals('APPROVE', result.systemDecision);
        System.assertEquals('YouthContactService', parser.getSystemName());
        System.assertEquals('Youth Prefill', parser.getFriendlyName());
    }

    @IsTest
    private static void testFailureWithMessage() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"79VNBGP","job_reference_code":"XZFCGH3"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"YouthContactService","system_display_name":"Youth Contact Service","status":"","decision":"FAIL","everything":"","user_action":"Testing failure","tracking_number":"T4HRH9D"}]},"coApplicants":[],"products":[],"fundingInfo":{},"reports":[],"app_status":"inprogress","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOYouthPrefillLogParser parser = new AOYouthPrefillLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), appInfo.errors);
        System.assertEquals(AOInteractionResult.State.ERROR, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('Testing failure', result.message);
        System.assertEquals('FAIL', result.systemDecision);
    }

    @IsTest
    private static void testFailureWithoutMessage() {
        String testData = '{"form":{"name":"accountsandfunding","tracking_code":"79VNBGP","job_reference_code":"XZFCGH3"},"applicant":{"person":{"first_name":"Paul","last_name":"Ferguson","birth_date":"1958-01-01","tax_id":"666-37-1340","primary_address":{"line_1":"4400 Central Way","line_2":"Ste 510","city":"Chubbuck","state":"ID","country":"USA","postal_code":"83202"},"identification":{"type":"drivers_license","id_number":"101800775","issuing_authority":"CO","issue_date":"2018-01-01","expire_date":"2028-01-01"},"credit_score":{"score":null,"score_date":null},"home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"dmagill@iccu.com"},"persona":"Unknown","membership_eligibility":"","system_info":[{"system_name":"YouthContactService","system_display_name":"Youth Contact Service","status":"","decision":"FAIL","everything":"","user_action":"","tracking_number":"T4HRH9D"}]},"coApplicants":[],"products":[],"fundingInfo":{},"reports":[],"app_status":"inprogress","version":"3","external_crm_id":null}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOYouthPrefillLogParser parser = new AOYouthPrefillLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(0, appInfo.errors.size(), appInfo.errors);
        System.assertEquals(AOInteractionResult.State.ERROR, result.state);
        System.assertNotEquals(null, result.message);
        System.assertEquals('Youth prefill failed for an unknown reason', result.message);
        System.assertEquals('FAIL', result.systemDecision);
    }

}