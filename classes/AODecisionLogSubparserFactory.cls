/**
 * Factory class that assembles the exact subparsers needed for a given application form.
 */
public class AODecisionLogSubparserFactory {

    /**
     * Get's a list of known parsers for the decision log.
     * @param applicantData Map of the data for a specific applicant
     * @param ownerPrefix The optional prefix used to distinguish entries in Decision Log Results
     */
    public static List<AOSystemDecisionLogParser> getSubparsers(List<AOApplicationRestRequest.SystemInfo> systemInfo, String ownerPrefix) {
        List<AOSystemDecisionLogParser> knownParsers = new AOSystemDecisionLogParser[]{
            new AOSFDCDesicionLogParser(),
            new AOEligibilityDecisionLogParser(),
            new AOExperianPreciseIDLogParser(),
            new AOExperianPreciseIDVerifyLogParser(),
            new AOFISDecisionLogParser(),
            new AOExperianCreditScoreDecisionLogParser(),
            new AOCRIFCreateAppDecisionLogParser(),
            new AOCRIFDecisionLogParser(),
            new AOFATCADecisionLogParser(),
            new AOPrefillDecisionLogParser(),
            new AOMonetaryTransDecisionLogParser(),
            new AOFundAccountsByGroupParser(),
            new AODNAFlagsDecisionLogParser(),
            new AOPrimaryAppCreditScoreLogParser(),
            new AOApplicantCreditScoreLogParser(),
            new AOApplicantPreciseIDLogParser(),
            new AOApplicantPreciseIDVerifyLogParser(),
            new AOYouthPrefillLogParser()
        };

        // Build the map of parsers
        Map<String, AOSystemDecisionLogParser> parserMap = new Map<String, AOSystemDecisionLogParser>();
        for (AOSystemDecisionLogParser parser : knownParsers) {
            parser.ownerPrefix = ownerPrefix;
            parserMap.put(parser.getSystemName(), parser);
        }

        // Build up a list of the parsers needed for the systemInfo.
        List<String> systemNames = new List<String>();
        for (AOApplicationRestRequest.SystemInfo si : systemInfo) {
            systemNames.add(si.system_name);
        }

        // Iterate over all the keys in the data and pluck out the appropriate parser to use
        List<AOSystemDecisionLogParser> parsersToUse = new List<AOSystemDecisionLogParser>();
        for (String systemName : systemNames) {
            AOSystemDecisionLogParser parser = parserMap.get(systemName);

            // We don't have a known parser to work with, so instantiate a parser that will
            // squeeze the data juice out of it until one is created...
            if (parser == null) {
                parser = new AOUnknownDecisionLogParser(systemName);
                parser.ownerPrefix = ownerPrefix;
            }

            parsersToUse.add(parser);
        }

        return parsersToUse;
    }
}