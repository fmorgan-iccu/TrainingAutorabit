/**
 * Factory class that assembles the exact subparsers needed for a given application form.
 */
public class AODecisionLogSubparserFactory {

    /**
     * Get's a list of known parsers for the decision log.
     * @param applicantData Map of the data for a specific applicant
     * @param ownerPrefix The optional prefix used to distinguish entries in Decision Log Results
     */
    public static List<AOSystemDecisionLogParser> getSubparsers(Map<String, Object> applicantData, String ownerPrefix) {
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
            new AOMonetaryTransDecisionLogParser()
        };

        Map<String, AOSystemDecisionLogParser> parserMap = new Map<String, AOSystemDecisionLogParser>();

        // Build the map of parsers
        for (AOSystemDecisionLogParser parser : knownParsers) {
            parser.ownerPrefix = ownerPrefix;
            parserMap.put(parser.getSystemName(), parser);
        }

        List<AOSystemDecisionLogParser> parsersToUse = new List<AOSystemDecisionLogParser>();

        // Iterate over all the keys in the data and pluck out the appropriate parser to use
        Set<String> systemNames = applicantData.keySet();
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