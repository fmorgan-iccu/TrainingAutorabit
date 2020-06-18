public class AOConstants {
    public static final String ACCOUNT_OPENING_STATUS_READY = 'Ready';
    public static final String ACCOUNT_OPENING_STATUS_FAILED = 'Failed';
    public static final String ACCOUNT_OPENING_STATUS_COMPLETE = 'Complete';

    public static final String FORM_YOUTH = 'youth';
    public static final String FORM_JOINT = 'joint';

    public static final String OPPORTUNITY_ROLE_GUARANTOR = 'Guarantor';
    public static final String OPPORTUNITY_ROLE_JOINT = 'Joint';
    public static final String OPPORTUNITY_ROLE_PRIMARY_BORROWER = 'Primary Borrower';

    public static final String APP_STATUS_COMPLETE = 'complete';
    public static final String APP_STATUS_IN_PROGRESS = 'inprogress';
    public static final String APP_STATUS_IN_REVIEW = 'inreview';
    public static final String APP_STATUS_ERROR = 'error';
    public static final String APP_STATUS_ABANDONED = 'abandoned';

    public static final String XML_VERSION = 'XmlVersion';
    public static final String XML_FORM_KEY = 'XmlForm';
    public static final String XML_NODE_KEY = 'xmlNode';

    public static final String PRODUCT_MAJOR_TYPE_CRIF = 'CRIF';
    public static final String PRODUCT_MINOR_TYPE_HELOC = 'HELOC';  // TODO:  This needs to be set to the right code; placeholder until the product service supports it.

    public enum FormXmlVersion {NONE, V1, V2, V3}
    public static FormXmlVersion getFormXmlVersion(String version) {
        if (version == null) {
            return FormXmlVersion.NONE;
        }
        if (version == FormXmlVersion.V1.name().toLowerCase()) { //First version of seed XML released has this as the first version
            return FormXmlVersion.V1;
        }
        try {
            for (FormXmlVersion value : FormXmlVersion.values()) { // This requires version 2+ to be only numeric
                if (value.ordinal() == Integer.valueOf(version)) {
                    return value;
                }
            }
        } catch (Exception e) {
            // Not a valid integer so allow it to default to NONE below.
        }

        return FormXmlVersion.NONE; //Default if it doesn't make a match
    }
}