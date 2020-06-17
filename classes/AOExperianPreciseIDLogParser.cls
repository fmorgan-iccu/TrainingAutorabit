public class AOExperianPreciseIDLogParser extends AOSystemDecisionLogParser {
    public override String getSystemName() {
        return 'KBAQuestions';
    }

    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry,  AOApplicationInfo appInfo) {
        String message = null;
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;

        try {
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(decisionLogEntry.everything);
            
            String[] errorPath = 'clientResponsePayload'.split('/');
            Map<String, Object> responsePayload = APIUtils.walkTreeToValue(data, errorPath);
            List<Object> decisionElements = (List<Object>)responsePayload.get('decisionElements');
            
            List<String> warningsErrors = new List<String>();

            if (decisionElements != null && decisionElements.size() > 0) {
                for (Object decisionObj : decisionElements) {
                    Map<String, Object> decision = (Map<String, Object>)decisionObj;
                    List<Object> warnings = (List<Object>)decision.get('warningsErrors');
                    
                    if (warnings == null) {
                        continue;
                    }
                    
                    for (Object obj : warnings) {
                        Map<String, Object> warning = (Map<String, Object>)obj;
                        String responseMessage = (String)warning.get('responseMessage');
                        if (responseMessage != null) {
                            warningsErrors.add(responseMessage);
                        }
                    }
                }
            }
            
            if (warningsErrors.size() > 0) {
                String combinedErrors = '';
                for (String error : warningsErrors) {
                    combinedErrors = error + ' | ';
                }
                
                message = combinedErrors;
                state = AOInteractionResult.State.SUCCESS;
            } else {
                String[] decisionPath = 'responseHeader/overallResponse'.split('/');

                Map<String, Object> decisionMap = APIUtils.walkTreeToValue(data, decisionPath);

                if (decisionMap != null) {
                    message = (String)decisionMap.get('decisionText');
                    boolean resultCodeDescriptionWasOutput = false;
                    Map<String, Object> decisionData = (Map<String, Object>)decisionElements[0];
                    
                    List<String> kbaScorePath = 'otherData/json/fraudSolutions/response/products/preciseIDServer/kbascore'.split('/');
                    Map<String, Object> kbaScore = APIUtils.walkTreeToValue(decisionData, kbaScorePath);
                    
                    if(kbaScore != null){
                        Map<String,Object> kbaGeneral = (Map<String,Object>)kbaScore.get('general');
                    
                        if(kbaGeneral != null){
                            message  += '; Result Description: ' + (String)kbaGeneral.get('kbaresultCodeDescription');
                            resultCodeDescriptionWasOutput = true;
                        }
                    }
                    
                    if(!resultCodeDescriptionWasOutput){
                        message += '; Result Description: No Result Code Provided';
                    }
                    state = AOInteractionResult.State.SUCCESS;
                } else {
                    message = decisionLogEntry.everything;
                    return new AOInteractionResult(this.getFriendlyName(), AOInteractionResult.State.UNKNOWN, message, decisionLogEntry.decision);
                }
            }
        } catch(Exception e) {
            message = 'Unable to read Experian precise ID data: ' + e;
            state = AOInteractionResult.State.ERROR;
        }
        
        return new AOInteractionResult(this.getFriendlyName(), state, message, decisionLogEntry.decision);
    }
    
    private AOInteractionResult notPresentResult(String message, AODecisionLogEntry decisionLogEntry) {
        return new AOInteractionResult(this.getFriendlyName(), AOInteractionResult.State.NOT_PRESENT, message, decisionLogEntry.decision);
    }
    
    public override String getFriendlyName() {
        return 'Experian Precise ID';
    }
}