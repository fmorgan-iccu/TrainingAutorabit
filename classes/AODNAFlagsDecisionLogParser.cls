public class AODNAFlagsDecisionLogParser extends AOSystemDecisionLogParser {
	
    public override String getSystemName() {
        return 'WarningFlagsCheck';
    }
    
    public override String getFriendlyName() {
        return 'Warning Flags Check';
    }
    
    public override AOInteractionResult processLogEntry(AODecisionLogEntry decisionLogEntry, AOApplicationInfo appInfo) {
        String everything = decisionLogEntry.everything;

        String systemName = this.getSystemName();
        String message = '';
        AOInteractionResult.State state = AOInteractionResult.State.UNKNOWN;
        String systemDecision = null;

        try {
            if (decisionLogEntry.everything == '') {
                // DO NOTHING, WE ARE DONE.
            } else {
                Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(decisionLogEntry.everything);

                List<Map<String, Object>> rawPersonFlags = APIUtils.convertObjectList((List<Object>)data.get('PersonFlags'));
                List<Map<String, Object>> rawAccountFlags = APIUtils.convertObjectList((List<Object>)data.get('AccountFlags'));
                String parsedPersonFlags = this.parsePersonFlags(rawPersonFlags);
                String parsedAccountFlags = this.parseAccountFlags(rawAccountFlags);
                
                message = 'Person Flags: ' + parsedPersonFlags + '\n\nAccount Flags: ' + parsedAccountFlags;
			}

            state = AOInteractionResult.State.SUCCESS;
            systemDecision = decisionLogEntry.decision;
        } catch (Exception e) {
            System.debug('Error parsing ' + this.getFriendlyName() + ': ' + e.getMessage());
            
            state = AOInteractionResult.State.ERROR;
        }
        
        AOInteractionResult result = new AOInteractionResult(systemName, state, message, systemDecision);
        
        return result;
    }
    
    private String parsePersonFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return '';
        }
        
        String result = '';
        
        for (Map<String, Object> rawFlag : rawFlags) {
            String flag = (String)rawFlag.get('FlagCode');
            
            if (flag == null) {
                continue;
            }
            
            result += ' ' + flag;
        }
        
		return result;
    }
    
    private String parseAccountFlags(List<Map<String, Object>> rawFlags) {
        if (rawFlags == null) {
            return '';
        }
  
        String result = '';
        
		for (Map<String, Object> rawFlag : rawFlags) {
            String accountNumber = (String)rawFlag.get('AccountNumber');
            
            if (accountNumber == null) {
                continue;
            }
            
            List<Object> rawCodes = (List<Object>)rawFlag.get('FlagCode');
            
            String codes = '';
            
            for (Object rawCode : rawCodes) {
                codes += rawCode + ' ';
            }
            
            String accountResult = '[' + accountNumber + ' Codes: [' + codes + ']] ';
            
            result += '| ' + accountResult;
        }
        
		return result;
    }
    
}