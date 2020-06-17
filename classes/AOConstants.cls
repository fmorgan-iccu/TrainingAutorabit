public class AOConstants {
    public static final String XML_VERSION = 'XmlVersion';
    public static final String XML_FORM_KEY = 'XmlForm';
    public static final String XML_NODE_KEY = 'xmlNode';
    public static final String XML_APPLICANT_KEY = 'xmlApplicantNode';
    public static final String XML_TRIAGE_APPLICANT_KEY = 'xmlTriageApplicantNode';
    public static final String XML_YOUTH_APPLICANT_KEY = 'xmlYouthApplicantNode';
    public static final String XML_GUARDIAN_APPLICANT_KEY = 'xmlGuardianNode';
    public static final String PRODUCT_MAJOR_TYPE_CRIF = 'CRIF';
    public static final String PRODUCT_MINOR_TYPE_HELOC = 'HELOC';  // TODO:  This needs to be set to the right code; placeholder until the product service supports it.
    public enum FormXmlVersion {NONE, V1, V2} //Using this will require an update on TM to be just the number eg 1 vs v1
    public static FormXmlVersion getFormXmlVersion(String version) {
        if (version == null) {
            return FormXmlVersion.NONE;
        }
        if (version == FormXmlVersion.V1.name().toLowerCase()) { //First version of seed XML released has this as the first version
            return FormXmlVersion.V1;
        }
        for (FormXmlVersion value : FormXmlVersion.values()) {
            if (value.ordinal() == Integer.valueOf(version)) {
                return value;
            }
        }
        
        return FormXmlVersion.NONE; //Default if it doesn't make a match
    }
}