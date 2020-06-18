public class AOPrimaryAppCreditScoreLogParser extends AOExperianCreditScoreDecisionLogParser {

    public override String getSystemName() {
        return 'GetPrimaryApplicantCreditReport';
    }

    public override String getFriendlyName() {
        return 'Primary Applicant Credit Score';
    }

}