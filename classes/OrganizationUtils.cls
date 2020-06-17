public class OrganizationUtils {

	private static Organization org = null;

	public static Organization getOrganizationInfo() {
		// If the organziation info isn't already cached, query and cache it.
		if (OrganizationUtils.org == null) {
			List<Organization> organizations = [
				SELECT id,
					city,
					country,
					name,
					postalCode,
					state,
					street
				FROM Organization
			];
			OrganizationUtils.org = organizations[0];
		}
		return OrganizationUtils.org;
	}

}