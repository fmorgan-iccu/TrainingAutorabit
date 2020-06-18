public with sharing class DNAOrganizationDataProvider extends DNACoreDataProvider implements IOrganizationDataProvider {

    /**
     * Default constructor
     */
    public DNAOrganizationDataProvider() {
        super();
    }

    /**
     * Constructor for specifying the IAuthenticationManager.  Primarily to facilitate unit testing.
     * @authManager The IAuthenticationManager to use
     */
    public DNAOrganizationDataProvider(IAuthenticationManager dnaCoreAuthenticationManager) {
        super(dnaCoreAuthenticationManager);
    }

    /*
     * Gets an org's details
     * @param organizationNumber The org number of the org
     * @return a DNAOrganization instance that conforms to the IOrganization interface
     */
    public DNAOrganization getOrganizationDetails(String organizationNumber) {
        if (organizationNumber == null) {
            throw new IllegalArgumentException('The organization number may not be null.');
        }

        Map<String, Object> orgRequest = new Map<String, Object>();
        orgRequest.put('OrgNumber', organizationNumber);
        orgRequest.put('__type', 'OrgDetailInquiryRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(orgRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> orgMap = responses[0];
        List<Object> errors = (List<Object>)orgMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new InvalidPersonException(message);
        }

        DNAOrganization org = this.parseOrganization(orgMap);

        return org;
    }

    /**
     * Parses an org from DNA
    * @param orgMap The map containing org data.
    * @return Fully mapped DNAOrganization
    */
    private DNAOrganization parseOrganization(Map<String, Object> orgMap) {
        List<Map<String, Object>> rawAddresses = APIUtils.convertObjectList((List<Object>)orgMap.get('Addresses'));
        List<Map<String, Object>> rawEmailAddresses = APIUtils.convertObjectList((List<Object>)orgMap.get('ElectronicAddresses'));
        List<Map<String, Object>> rawPhoneNumbers = APIUtils.convertObjectList((List<Object>)orgMap.get('Phones'));
        List<Map<String, Object>> rawTaxIds = APIUtils.convertObjectList((List<Object>)orgMap.get('OrgTaxIds'));

        DNAAddress address = this.parseAddress(AddressType.PRIMARY, rawAddresses);
        String emailAddress = this.parseEmail('EBUS', rawEmailAddresses);
        String name = (String)orgMap.get('OrgName');
        String orgNumber = String.valueOf((decimal)orgMap.get('OrgNumber'));
        String orgType = (String)orgMap.get('OrgTypeCode');
        String phoneNumber = this.parsePhoneNumber('BUS', rawPhoneNumbers);
        String taxId = this.parseTaxIDs('FEIN', rawTaxIds);

        DNAOrganization org = new DNAOrganization(address, emailAddress, name, orgNumber, orgType, phoneNumber, taxId);

        return org;
    }

    public List<IWarningFlag> getWarningFlags(String organizationNumber) {
        throw new DataServiceException('getWarningFlags is not supported by the DNAOrganizationDataProvider; See DNABusinessServicesOrgDataProvider.');
    }

    /**
     * Updates an Organization's contact information
     * @param organization The org being udpated
     * @param addresses The addresses to update
     * @param phoneNumbers The phone numbers to update
     * @param emailAddresses The email addresses to update
     * @return DNAOrg that was updated.
     */
    public DNAOrganization updateOrganizationContactInfo(IOrganization organization, List<IAddress> addresses, List<PhoneNumber> phoneNumbers) {
        if (organization == null) {
            throw new IllegalArgumentException('Organization may NOT be null.');
        }

        if (addresses == null) {
            throw new IllegalArgumentException('Address may NOT be null.');
        }

        if (phoneNumbers == null) {
            throw new IllegalArgumentException('Phone number may NOT be null.');
        }

        String orgNumber = organization.getOrgNumber();
        String orgName = organization.getName();

        if (orgNumber == null || orgName == null) {
            throw new IllegalArgumentException('Organization number and name may NOT be null.');
        }

        List<Map<String, Object>> mappedAddresses = new List<Map<String, Object>>();
        for (IAddress address : addresses) {
            List<Map<String, Object>> addressLines = new List<Map<String, Object>>();

            if (address.getAddressType() == null) {
                throw new IllegalArgumentException('Address type may not be null.');
            }

            String addrCode = this.addressCodeForAddressType(address.getAddressType());
            if (addrCode == null) {
                throw new IllegalArgumentException('Address type not handled and is null.');
            }

            // The street address can contain numerous lines separated by carriage return and/or new line.
            // The type of the code will be detected from the contents of the address.
            String street = address.getStreet();
            for (String line : street.split('\\r?\\n')) {
                Map<String, Object> addressLine = new Map<String, Object>();
                addressLine.put('Value', line);
                addressLine.put('AddrLineTypCd', getAddressLineTypeCode(line));
                addressLines.add(addressLine);
            }

            Map<String, Object> mappedAddress = new Map<String, Object>();
            mappedAddress.put('AddressLines', addressLines);
            mappedAddress.put('CityName', address.getCity());
            mappedAddress.put('CountryCode', address.getCountryCode());
            mappedAddress.put('IsElectronic', false);
            mappedAddress.put('UseCode', addrCode);
            mappedAddress.put('ShouldUpdate', true); // Always hardcode to `true`
            mappedAddress.put('State', address.getStateCode());
            mappedAddress.put('ZipCode', address.getPostalCode());

            mappedAddresses.add(mappedAddress);
        }

        List<Map<String, Object>> mappedPhones = new List<Map<String, Object>>();
        for (PhoneNumber phone : phoneNumbers) {
            PhoneNumberType phoneType = phone.getPhoneType();
            if (phone.getPhoneType() == null) {
                throw new IllegalArgumentException('Phone type may not be null.');
            }

            // Verify that the phone number has the correct number of digits; yes, it must be a
            // ten digit phone number!  Only the home phone is required.
            Integer phoneLength = phone.getValue().length();
            if ((phoneType == PhoneNumberType.BUSINESS && phoneLength != 10) ||
                (phoneType != PhoneNumberType.BUSINESS && phoneLength != 10 && phoneLength != 0))
            {
                throw new IllegalArgumentException('Phone numbers must be 10-digits.');
            }

            String phoneCode = this.phoneCodeForPhoneNumberType(phoneType);
            if (phoneCode == null) {
                throw new IllegalArgumentException('Phone type not handled and is null.');
            }

            Map<String, Object> mappedPhone = new Map<String, Object>();
            mappedPhone.put('CountryCode', 'USA');
            mappedPhone.put('AreaCode', phone.getAreaCode());
            mappedPhone.put('Exchange', phone.getPrefix());
            mappedPhone.put('Number', phone.getLineNumber());
            mappedPhone.put('ShouldUpdate', true);
            mappedPhone.put('UsageCode', phoneCode);

            mappedPhones.add(mappedPhone);
        }

        Map<String, String> name = new Map<String, String>();
        name.put('orgName', orgName);

        Map<String, Object> updateAccountInfoRequest = new Map<String, Object>();
        updateAccountInfoRequest.put('OrgNumber', orgNumber);
        updateAccountInfoRequest.put('Name', name);
        updateAccountInfoRequest.put('Addresses', mappedAddresses);
        updateAccountInfoRequest.put('Phones', mappedPhones);
        //updateAccountInfoRequest.put('EmailAddresses', mappedEmails);
        updateAccountInfoRequest.put('__type', 'OrgMaintenanceRequest:http://www.opensolutions.com/CoreApi');

        Map<String, Object> request = this.createGenericRequest(updateAccountInfoRequest);
        List<Map<String, Object>> responses = this.callApi(request);

        if (responses == null || responses.size() == 0) {
            return null;
        }

        Map<String, Object> responseMap = responses[0];
        List<Object> errors = (List<Object>)responseMap.get('Errors');
        if (errors != null) {
            String message = this.parseErrors(errors);
            throw new DataServiceException(message);
        }

        return this.getOrganizationDetails(organization.getOrgNumber());
    }

    /**
     * Inspects the contents of an address line to infer the DNA address line type to use.  This process
     * is somewhat subjective, but all of the checks have been developed from the user entered data.
     * @param  addressLine The address line to inspect and determine the type of.
     * @param  isFirstLine Indicates if the line is the first address line.
     * @return             The inferred address line type.
     */
    private String getAddressLineTypeCode(String addressLine) {
        String addrLineType = null;
        if (AddressUtils.isPostOfficeBox(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.POST_OFFICE_BOX_NUMBER);
        } else if (AddressUtils.isApartment(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.APARTMENT_NUMBER);
        } else if (AddressUtils.isBuilding(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.BUILDING_NUMBER);
        } else if (AddressUtils.isSuite(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.SUITE_NUMBER);
        } else if (AddressUtils.isAttention(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.ATTENTION);
        } else if (AddressUtils.isRuralRoute(addressLine)) {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.RURAL_ROUTE_NUMBER);
        } else {
            addrLineType = addressLineCodeForAddressLineType(AddressLineType.STREET);
        }
        return addrLineType;
    }

}