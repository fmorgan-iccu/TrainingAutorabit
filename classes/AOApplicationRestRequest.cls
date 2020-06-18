public class AOApplicationRestRequest {

    public Applicant applicant;
    public List<Applicant> co_applicants;
    public List<FinancialProduct> products;
    public List<Promotion> promotions;
    public FundingInfo funding_info;
    public List<Reports> reports;
    public String app_status;
    public String version;
    public Form form;
    public String application_id;
    public String related_application_id; // TODO:  Need to adjust the RAML spec!
    public String role_type;
    public Map<String, String> preselected_product_options;

    public class AccountRole {
        public String role_code;
        public String entity_number;
        public String entity_type;
    }

    public class Address {
        public String line_1;
        public String line_2;
        public String city;
        public String state;
        public String postal_code;
        public String country;
        public Boolean is_preferred;
    }

    public class Applicant {
        public Person person;
        public String persona;
        public String membership_eligibility;
        public List<SystemInfo> system_info;
    }

    public class Branch {
        public String name;
        public Integer branch_number;
        public Address address;
    }

    public class CreditScore {
        public Integer score;
        public String score_date;
    }

    public class ExternalAccount {
        public String external_account_number;
        public Integer external_organization_number;
        public String external_organization_type;
    }

    public class FinancialAccount {
        public String nickname;
        public String account_number;
        public FinancialProduct product;
        public Double balance;
        public Branch branch;
        public Double available_balance;
        public String contract_date;
        public String status;
        public List<AccountRole> roles;
        public List<UserField> user_fields;
        public Rate rate;
        public String ownership_code;
        public ExternalAccount external_account;
    }

    public class FinancialProduct {
        public String product_name;
        public String major_type;
        public String minor_type;
    }

    public class Form {
        public String name;
        public String purpose;  // TODO:  Need to adjust the RAML spec!  This could be "openaccount" or "addrole", etc.
        public String type;
        public String tracking_code;
        public String job_reference_code;
        public String url;
    }

    public class FundingInfo {
        public String payment_type;
        public Double total_funding_amount;
        public List<OpenedAccount> opened_accounts;
    }

    public class OpenedAccount {
        public FinancialAccount account;
        public FinancialAccount from_account;
        public Double funding_amount;
    }

    public class Person {
        public String person_number;
        public String member_number;
        public Integer member_group_code;
        public String tax_id;
        public String first_name;
        public String middle_name;
        public String last_name;
        public String birth_date;
        public Phone home_phone;
        public Phone mobile_phone;
        public Phone work_phone;
        public String email;
        public PersonIdentification identification;
        public Address primary_address;
        public CreditScore credit_score;
        public List<UserField> user_fields;
    }

    public class PersonIdentification {
        public String type;
        public String id_number;
        public String issuing_authority;
        public String issue_date;
        public String expire_date;
    }

    public class Phone {
        public String country_code;
        public String extension;
        public String phone_number;
    }

    public class Promotion {
        public String code;
    }

    public class Rate {
        public String rate_type;
        public Double interest_rate;
        public Double minimum_interest_rate;
        public Double maximum_interest_rate;
        public Double margin_fixed;
        public Integer amortization_term;
        public String balance_category;
        public String interest_method;
        public String rate_class;
    }

    public class Reports {
        public String report_name;
        public String raw_report;
    }

    public class SystemInfo {
        public String system_name;
        public String system_display_name;
        public String status;
        public String decision;
        public String everything;
        public String user_action;
        public String tracking_number;
    }

    public class UserField {
        public String code;
        public String value;
    }

    public static AOApplicationRestRequest parse(String json) {
        return (AOApplicationRestRequest) System.JSON.deserialize(json, AOApplicationRestRequest.class);
    }

    /**
     * Convenience functions to get a Map of user fields from the REST request for a person or financial account.
     */

    public Map<String, String> getPersonUserFieldMap(Person p) {
        return getUserFieldMap(p.user_fields);
    }

    public Map<String, String> getFinancialAccountUserFieldMap(FinancialAccount fa) {
        return getUserFieldMap(fa.user_fields);
    }

    private Map<String, String> getUserFieldMap(List<UserField> userFields) {
        Map<String, String> userFieldMap = new Map<String, String>();
        for (UserField uf : userFields) {
            userFieldMap.put(uf.code, uf.value);
        }
        return userFieldMap;
    }

}