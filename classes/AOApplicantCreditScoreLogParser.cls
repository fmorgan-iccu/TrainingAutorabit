public class AOApplicantCreditScoreLogParser extends AOExperianCreditScoreDecisionLogParser {

    public override String getSystemName() {
        return 'GetApplicantCreditReport';
    }

    public override String getFriendlyName() {
        return 'Experian Credit Score';
    }

}