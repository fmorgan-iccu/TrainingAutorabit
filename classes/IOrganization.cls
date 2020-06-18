public interface IOrganization {
    Account getAccount();
    IAddress getAddress();
    String getEmailAddress();
    Date getMembershipDate();
    Date getBusinessEstablishmentDate();
    String getName();
    String getOrgNumber();
    String getOrgType();
    String getPhoneNumber();
    IOrganization getRedactedOrganization();
    String getTaxId();
}