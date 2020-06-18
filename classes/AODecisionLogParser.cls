public class AODecisionLogParser {

    private static final String PRIMARY_APPLICANT = 'primaryApplicant';
    private static final String JOINT_APPLICANT = 'jointApplicant';


    public void parsePayload(AOApplicationInfo appInfo) {
        AOConstants.FormXmlVersion xmlVersion = AOConstants.getFormXmlVersion(appInfo.appRequest.version);
        switch on xmlVersion {
            when V3 {
                parsePayloadDefault(appInfo);
            }
            when else {
                parsePayloadDefault(appInfo);
            }
        }
    }

    public void parsePayloadDefault(AOApplicationInfo appInfo) {
        AOApplicationRestRequest appRequest = appInfo.appRequest;
        if (appRequest.applicant.system_info == null) {
            throw new XmlException('Applicant system_info is missing.');
        }

        // Identify the application product
        AOApplicationRestRequest.FinancialProduct product = null;
        if (appRequest.products != null && appRequest.products.size() > 0) {
            product = appRequest.products[0];
        }

        // Determine if the form requires the system responses to be shown for both the applicant and the co-applicant.
        Boolean hasApplicantSystemInfo =
            appRequest.applicant.system_info != null &&
            appRequest.applicant.system_info.size() > 0;
        Boolean hasCoApplicantSystemInfo =
            appRequest.co_applicants != null &&
            appRequest.co_applicants.size() > 0 &&
            appRequest.co_applicants[0].system_info != null;
        Boolean showAllApplicantSystemInfo = hasApplicantSystemInfo && hasCoApplicantSystemInfo;

        // Parse the applicants system information responses and prefix the title if necessary.
        List<AOApplicationRestRequest.SystemInfo> applicantSystemInfo = appRequest.applicant.system_info;
        String applicantPrefix = showAllApplicantSystemInfo ? 'Applicant' : null;
        List<AOSystemDecisionLogParser> parsers = AODecisionLogSubparserFactory.getSubparsers(applicantSystemInfo, applicantPrefix);
        for (AOSystemDecisionLogParser parser : parsers) {
            parser.parsePayload(applicantSystemInfo, appInfo);
        }

        // Parse the co-applicants system information responses and prefix the title if necessary.
        if (hasCoApplicantSystemInfo) {
            List<AOApplicationRestRequest.SystemInfo> coApplicantSystemInfo = appRequest.co_applicants[0].system_info;
            applicantPrefix = showAllApplicantSystemInfo ? 'Co-Applicant' : null;
            parsers = AODecisionLogSubparserFactory.getSubparsers(coApplicantSystemInfo, applicantPrefix);
            for (AOSystemDecisionLogParser parser : parsers) {
                parser.parsePayload(coApplicantSystemInfo, appInfo);
            }
        }
    }

}