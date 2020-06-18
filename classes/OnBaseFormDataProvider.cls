public with sharing class OnBaseFormDataProvider extends OnBaseDataProvider {

    public class AutoForm {
        public String member_number { get; private set; }
        public String account_number { get; private set; }
        public String companyCity { get; private set; }
        public String companyName { get; private set; }
        public String companyPostalCode { get; private set; }
        public String companyState { get; private set; }
        public String companyStreetAddress { get; private set; }
        public String make { get; private set; }
        public String city { get; private set; }
        public String postal_code { get; private set; }
        public String memberState { get; private set; }
        public String memberStreetAddress { get; private set; }
        public String model { get; private set; }
        public String payoffAmount { get; private set; }
        public String perDiem { get; private set; }
        public String payoffDate { get; private set; }
        public String year { get; private set; }
        public String vin { get; private set; }

        public AutoForm(
            String member_number,
            String account_number,
            String companyCity,
            String companyName,
            String companyPostalCode,
            String companyState,
            String companyStreetAddress,
            String make,
            String city,
            String postal_code,
            String memberState,
            String memberStreetAddress,
            String model,
            String payoffAmount,
            String perDiem,
            String payoffDate,
            String year,
            String vin)
        {
            this.member_number = member_number;
            this.account_number = account_number;
            this.companyCity = companyCity;
            this.companyName = companyName;
            this.companyPostalCode = companyPostalCode;
            this.companyState = companyState;
            this.companyStreetAddress = companyStreetAddress;
            this.make = make;
            this.city = city;
            this.postal_code = postal_code;
            this.memberState = memberState;
            this.memberStreetAddress = memberStreetAddress;
            this.model = model;
            this.payoffAmount = payoffAmount;
            this.perDiem = perDiem;
            this.payoffDate = payoffDate;
            this.year = year;
            this.vin = vin;
        }
    }

    public class TitleForm {
        public String account_number { get; set; }
        public String member_number { get; set; }
        public String city { get; set; }
        public String company_name { get; set; }
        public String postal_code { get; set; }
        public String state { get; set; }
        public String address { get; set; }
        public String collateral_make { get; set; }
        public String collateral_model { get; set; }
        public Integer collateral_year { get; set; }
        public String vin { get; set; }
        public String member_first_name { get; set; }
        public String member_last_name { get; set; }
        public String payoff_type { get; set; }
        public String third_party_name { get; set; }
        public String attn { get; set; }
        public String third_party_street { get; set; }
        public String third_party_city { get; set; }
        public String third_party_state { get; set; }
        public String third_party_postal_code { get; set; }
        public String non_dna_street { get; set; }
        public String non_dna_city { get; set; }
        public String non_dna_state { get; set; }
        public String non_dna_postal_code { get; set; }
        public String buyers_name { get; set; }
        public String buyers_street { get; set; }
        public String buyers_city { get; set; }
        public String buyers_state { get; set; }
        public String buyers_postal_code { get; set; }
        public Integer new_loan_number { get; set; }
        public String action_to_take { get; set; }
        public Integer buyers_iccu_number { get; set; }
        public String check_box_verification { get; set; }
        public String created_by { get; set; }
    }

    public OnBaseFormDataProvider() {
        super();
    }

    public void saveAutoPayoffForm(AutoForm autoForm) {
        if (autoForm == null) {
            return;
        }

        // Build up the structure of the request.
        String requestBody = JSON.serialize(autoForm);

        // Call the autoPayoff request; all errors will be thrown.
        callApi('/autoPayoff', requestBody);
    }

    public void saveTitleReleaseForm(TitleForm titleReleaseForm) {
        if (titleReleaseForm == null) {
            throw new IllegalArgumentException('The `titleReleaseForm` must be provided.');
        }

        // Build up the structure of the request.
        String requestBody = JSON.serialize(titleReleaseForm);

        // Call the titleRelease request; all errors will be thrown.
         Map<String, Object> apiResponse = callApi('/titlerelease', requestBody);

        // TODO add in error handling for the response from the OnBase API
    }
}