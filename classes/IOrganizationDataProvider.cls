public interface IOrganizationDataProvider {
    IOrganization getOrganizationDetails(String organizationNumber);
    List<IWarningFlag> getWarningFlags(String organizationNumber);
    IOrganization updateOrganizationContactInfo(IOrganization organization, List<IAddress> addresses, List<PhoneNumber> phoneNumbers);
}