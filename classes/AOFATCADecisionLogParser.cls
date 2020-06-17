public class AOFATCADecisionLogParser extends AOSystemDecisionLogParser {
    public override String getSystemName() {
        return 'FATCA';
    }
    
    public override String getFriendlyName() {
        return this.getSystemName();
    }
    
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
		String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        String everything = decisionLogEntry.everything;
        
        try {
            Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(everything);

            String noBackupWitholding = (String)json.get('noBackupWithholding');
            String noAccountsOutsideUS = (String)json.get('noAccountsOutsideUS');
            String exemptPayeeCode = (String)json.get('exemptPayeeCode');
            exemptPayeeCode = exemptPayeeCode != null ? exemptPayeeCode : 'N/A';
            String ssnAndUsPersonCertified = (String)json.get('ssnAndUsPersonCertified');
            String fatcaReportingCode = (String)json.get('fatcaReportingCode');

            message = 'No backup withholding: ' + noBackupWitholding + '; No accounts outside US: ' + noAccountsOutsideUS + '; Exempt payee code: ' + exemptPayeeCode + '; SSN and US person certified: ' + ssnAndUsPersonCertified + '; FATCA reporting code: ' + fatcaReportingCode;
            state = AOInteractionResult.State.SUCCESS;
        } catch (Exception e) {
            state = AOInteractionResult.State.ERROR;
            message = 'Unable to parse message: ' + e.getMessage();
        }

        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
}