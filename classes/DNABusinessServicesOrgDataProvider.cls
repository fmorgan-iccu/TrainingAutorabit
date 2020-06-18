public with sharing class DNABusinessServicesOrgDataProvider extends DNABusinessServicesDataProvider implements IOrganizationDataProvider {

    public DNABusinessServicesOrgDataProvider() {
        super();
    }

    public DNABusinessServicesOrgDataProvider(IAuthenticationManager authManager) {
       super(authManager);
    }

    public IOrganization getOrganizationDetails(String organizationNumber) {
        throw new DataServiceException('getOrganizationDetails is not supported by the DNABusinessServicesOrgDataProvider; See DNAOrganizationDataProvider.');
    }

    public IOrganization updateOrganizationContactInfo(IOrganization organization, List<IAddress> addresses, List<PhoneNumber> phoneNumbers) {
        throw new DataServiceException('updateOrganizationContactInfo is not supported by the DNABusinessServicesOrgDataProvider; See DNAOrganizationDataProvider.');
    }

    public List<IWarningFlag> getWarningFlags(String organizationNumber) {
        if (organizationNumber == null) {
            throw new IllegalArgumentException('`organizationNumber` may NOT be null.');
        }

        // Retrieve the warning flags from DNA
        Map<String, Object> warningFlagsMessage = callApi('/Organizations/' + organizationNumber + '/Restrictions/', EndpointManager.HTTP_METHOD_GET, null);
        List<Map<String, Object>> warnings = APIUtils.convertObjectList((List<Object>) warningFlagsMessage.get('MessageBody'));

        // Parse the warning messages.
        List<DNAWarningFlag> warningFlags = new List<DNAWarningFlag>();
        for (Map<String, Object> warning : warnings) {
            String flagCode = (String)warning.get('WarningFlagCode');
            String flagCodeDescription = (String)warning.get('WarningFlagDescription');
            Datetime effectiveDate = DateUtils.convertToDatetime(Date.valueOf((String)warning.get('EffectiveDate')));
            Datetime inactiveDate = warning.containsKey('InactiveDate') ? DateUtils.convertToDatetime(Date.valueOf((String)warning.get('InactiveDate'))) : null;
            DNAWarningFlag warningFlag = new DNAWarningFlag(effectiveDate, flagCode, flagCodeDescription, inactiveDate, null, null, null, null, null);
            warningFlags.add(warningFlag);
        }

        return warningFlags;
    }

    public String getProviderName() {
        return 'DNA';
    }
}