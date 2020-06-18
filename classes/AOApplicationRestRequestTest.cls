@IsTest
private with sharing class AOApplicationRestRequestTest {

    @IsTest
    private static void testParsePayload() {
        String jsonPayload = '{"applicant":{"person":{"first_name":"justin","last_name":"hanley","birth_date":"1988-01-01","tax_id":"555-55-5555","primary_address":{"line_1":"123 main","line_2":"apt 1","city":"riverbank","state":"CA","postal_code":"83201"},"email":"test@test.com","user_fields":[{"code":"TEST1","value":"abc"}]},"persona":"member","system_info":[{"system_name":"ACMECredit","system_display_name":"ACME Credit Pull","status":"success","decision":"ACCEPT","everything":"","user_action":"nothing to see here...","tracking_number":"S2F4G7"},{"system_name":"ACME Prefill","system_display_name":"ACME Prefill service","status":"success","decision":"ACCEPT","everything":"","user_action":"prefill successful, data matched","tracking_number":"S2F4G7"}]},"co_applicants":[{"person":{"first_name":"theo","last_name":"hanley","birth_date":"2000-01-01","tax_id":"666666666","primary_address":{"line_1":"123 main","line_2":"apt 1","city":"riverbank","state":"CA","postal_code":"83201"},"email":"test2@test.com"},"persona":"person"}],"products":[{"product_name":"Share Savings","major_type":"SAV","minor_type":"SREG"},{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}],"funding_info":{"payment_type":"iccu","total_funding_amount":20.2,"opened_accounts":[{"account":{"nickname":"sally\'s checking","account_number":"123458965","balance":0,"available_balance":0,"is_active":true,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"},"user_fields":[{"code":"TEST2","value":"123"}]},"from_account":{"nickname":"sally\'s checking","account_number":"1232456789","balance":20.2,"available_balance":20.2,"is_active":true,"product":{"product_name":"Free Checking","major_type":"CK","minor_type":"CKBA"}},"funding_amount":20}]},"reports":[{"report_name":"credit report","raw_report":"850 best ever!"}],"form":{"name":"OnlineAccountOpening","tracking_code":"NRTL5P2","job_reference_code":"NRTL5P2","url":"https://test.iccu.avoka-transact.com/apps/secure/form.htm?submitKey=7d0d72a41dfe8aba616181774f153ecb"},"promotions":[{"code":"SHOW-ME-THE-MONEY"}],"app_status":"complete","version":"version1","external_crm_id":"dasdfjkh12k3hlkjdshfl1u34rlksdjf34rjlh"}';

        Test.startTest();

        AOApplicationRestRequest payload = AOApplicationRestRequest.parse(jsonPayload);

        // Test the convenience methods for getting user fields.
        Map<String, String> personUserFields = payload.getPersonUserFieldMap(payload.applicant.person);
        Map<String, String> accountUserFields = payload.getFinancialAccountUserFieldMap(payload.funding_info.opened_accounts[0].account);

        Test.stopTest();

        System.assertNotEquals(null, payload);
        System.assertEquals('justin', payload.applicant.person.first_name);
        System.assertEquals('555-55-5555', payload.applicant.person.tax_id);
        System.assertEquals(1, personUserFields.size());
        System.assertEquals('abc', personUserFields.get('TEST1'));
        System.assertEquals('iccu', payload.funding_info.payment_type);
        System.assertEquals(20.0, payload.funding_info.opened_accounts[0].funding_amount);
        System.assertEquals(1, accountUserFields.size());
        System.assertEquals('123', accountUserFields.get('TEST2'));
    }

}