@IsTest
private class AOSFDCDesicionLogParserTest {

    @IsTest
    private static void testHappyPath() {
        String testData = '{"applicant":{"person":{"tax_id":"599-99-1112","first_name":"Aaron","last_name":"Hansen","birth_date":"1982-01-03","home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"avokatest123@iccu.com","identification":{"type":"drivers_license","id_number":"DB195346C","issuing_authority":"ID","issue_date":"1988-07-06","expire_date":"1988-07-06"},"primary_address":{"line_1":"123 Main Street","line_2":"","city":"Twin Falls","state":"ID","postal_code":"83301","country":"USA","is_preferred":true},"user_fields":[]},"persona":"unknown","membership_eligibility":"","system_info":[{"system_name":"SFDC","everything":"","status":"success","decision":"APPROVE","tracking_number":"XHCVWHN","system_display_name":"SFDC-Email Check"}]},"co_applicants":[],"products":[{"product_name":"Premier Rewards Visa","major_type":"CRIF","minor_type":"134"}],"promotions":[],"funding_info":{},"reports":[],"app_status":"complete","version":"3","form":{"name":"accountsandfunding","tracking_code":"ZXK7TTF","job_reference_code":"ZXK7TTF","url":"https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=7d0d72a41dfe8aba616181774f1539a1"},"application_id":""}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOSFDCDesicionLogParser parser = new AOSFDCDesicionLogParser();
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
        System.assertEquals(0, appInfo.errors.size(), 'Error: ' + appInfo.errors);
        System.assertEquals('SFDC e-mail check complete', result.message);
    }

    @IsTest
    private static void testFailedDecision() {
        String testData = '{"applicant":{"person":{"tax_id":"599-99-1112","first_name":"Aaron","last_name":"Hansen","birth_date":"1982-01-03","home_phone":{"country_code":null,"phone_number":"3081231234","extension":null},"mobile_phone":{"country_code":null,"phone_number":null,"extension":null},"work_phone":{"country_code":null,"phone_number":null,"extension":null},"email":"avokatest123","identification":{"type":"drivers_license","id_number":"DB195346C","issuing_authority":"ID","issue_date":"1988-07-06","expire_date":"1988-07-06"},"primary_address":{"line_1":"123 Main Street","line_2":"","city":"Twin Falls","state":"ID","postal_code":"83301","country":"USA","is_preferred":true},"user_fields":[]},"persona":"unknown","membership_eligibility":"","system_info":[{"system_name":"SFDC","everything":"","status":"success","decision":"FAIL","tracking_number":"XHCVWHN","system_display_name":"SFDC-Email Check"}]},"co_applicants":[],"products":[{"product_name":"Premier Rewards Visa","major_type":"CRIF","minor_type":"134"}],"promotions":[],"funding_info":{},"reports":[],"app_status":"complete","version":"3","form":{"name":"accountsandfunding","tracking_code":"ZXK7TTF","job_reference_code":"ZXK7TTF","url":"https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=7d0d72a41dfe8aba616181774f1539a1"},"application_id":""}';
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(testData);
        AOApplicationInfo appInfo = new AOApplicationInfo(request);

        Test.startTest();

        AOSFDCDesicionLogParser parser = new AOSFDCDesicionLogParser();
        try {
            parser.parsePayload(request.applicant.system_info, appInfo);
        } catch(Exception e) {
            System.assert(false, 'Threw an exception: ' + e + ' stack trace: ' + e.getStackTraceString());
        }

        Test.stopTest();

        String systemName = parser.getSystemName();
        AOInteractionResult result = appInfo.systemInteractionResults.get(systemName);

        System.assertNotEquals(null, result);
        System.assertEquals(AOInteractionResult.State.ERROR, result.state);
        System.assertEquals(0, appInfo.errors.size(), 'Error: ' + appInfo.errors);
        System.assertEquals('SFDC e-mail check failed', result.message);
    }
}