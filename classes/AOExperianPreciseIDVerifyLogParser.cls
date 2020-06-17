public class AOExperianPreciseIDVerifyLogParser extends AOSystemDecisionLogParser {
    public class AOAnswer {
        public String questionDescription { get; private set; }
        public String answerResult { get; private set; }
        public Integer questionWeight { get; private set; }
        
        public AOAnswer(String questionDescription, String answerResult, Integer questionWeight) {
            this.questionDescription = questionDescription;
            this.answerResult = answerResult;
            this.questionWeight = questionWeight;
        }
    }
    
    public override String getSystemName() {
        return 'ExperianValidateKBAAnswers';
    }
    
    public override String getFriendlyName() {
        return 'Experian Precise ID Answers';
    }
    
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        String everything = decisionLogEntry.everything;

        try {
            Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(everything);
            Map<String, Object> clientResponsePayload = (Map<String, Object>)json.get('clientResponsePayload');
            
            if (clientResponsePayload == null) {
                message = 'Unable to find client response payload.';
                return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
            }
            
            List<Object> decisionElements = (List<Object>)clientResponsePayload.get('decisionElements');
            if (clientResponsePayload == null || decisionElements.size() == 0) {
                message = 'Unable to find clientResponsePayload';
                return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
            }

			String answersPath = 'otherData/json/fraudSolutions/response/products/preciseIDServer/kbascore/gradedAnswer';
            String[] paths = answersPath.split('/');
            
            Map<String, Object> rootDecisionMap = (Map<String, Object>)decisionElements[0];
            Map<String, Object> gradedAnswer = this.walkTreeToValue(rootDecisionMap, paths);
            
            if (gradedAnswer == null) {
                message = 'Unable to find graded answers.';
                return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
            }
            
            List<Object> answerSet = (List<Object>)gradedAnswer.get('answerSet');
            
            List<AOAnswer> answers = new List<AOAnswer>();
            
            message = '';
            
            for (Object obj : answerSet) {
                Map<String, Object> answerMap = (Map<String, Object>)obj;
                
                String description = (String)answerMap.get('questionTypeDescription');
                String answerResult = (String)answerMap.get('answerResult');
                Integer weight = (Integer)answerMap.get('questionWeight');
                
                AOAnswer answer = new AOAnswer(description, answerResult, weight);
                answers.add(answer);
                
                message += 'Description: ' + description + '; Answer Result: ' + answerResult + '; Weight: ' + weight + ' | ';
            }
            
            Map<String, Object> payload = new Map<String, Object> {
            	AOReportParser.RAW_DATA_KEY => json
            };
                
            AOExperianPreciseIDReportParser parser = new AOExperianPreciseIDReportParser();
            parser.parsePayload(payload, appInfo);

            appInfo.preciseIDAnswers = answers;

            state = AOInteractionResult.State.SUCCESS;
        } catch (Exception e) {
            state = AOInteractionResult.State.ERROR;
            message = 'Unable to parse message: ' + e.getMessage();
        }
        
        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
    
    private Map<String, Object> walkTreeToValue(Map<String, Object> tree, String[] paths) {
        if (paths.size() == 0) { // Found what we needed, return the tree that was passed in
            return tree;
        }

        String pathKey = paths[0];

        Object obj = tree.get(pathKey);
        
        if (obj instanceof Map<String, Object>) {
            Map<String, Object> subTree = (Map<String, Object>)tree.get(pathKey);
            String[] subPaths = this.subArray(paths, 1); // get a new array that is a subarray of the first element.
            return this.walkTreeToValue(subTree, subPaths);
        } else {
            System.debug('walkTreeToValue was NOT a map! Path key: ' + pathKey + ' Object: ' + obj);
            return null;
        }   
    }
    
    private List<String> subArray(List<String> dataList, Integer startIndex) {
        List<String> subArray = new List<String>();
        for (Integer i = startIndex; i < dataList.size(); i++) {
            subArray.add(dataList[i]);
        }
        
        return subArray;
    }
}