public class AOJobParser implements IAOPayloadParser {
    private static String TASK_STEPTASKS		= 'StepTasks';
    private static String TASK_FORMURL			= 'FormURL';
    private static String TASK_FORMNAME			= 'FormName';
    private static String TASK_ISCURRENTFORM	= 'CurrentForm';

	public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        AOConstants.FormXmlVersion xmlVersion = (AOConstants.FormXmlVersion)payload.get(AOConstants.XML_VERSION);
        switch on xmlVersion {
            when V1 {
                parsePayloadV1(payload, appInfo);
            }
            when V2 {
                parsePayloadV2(payload, appInfo);
            }
            when else {
                parsePayloadDefault(payload, appInfo);
            }
        }
    }

    public void parsePayloadV1(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadV2(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadDefault(Map<String, Object> payload, AOApplicationInfo appInfo) {
		try {
            // Access the xmlNode passed is the StepTasks and has an array of Task entries.  Retrieve the children.
            Dom.XmlNode jobNode = (Dom.XmlNode)payload.get(AOConstants.XML_NODE_KEY);
            
            if (jobNode == null) {
                System.debug('>>>> UNABLE TO FIND xmlNode! Aborting!');
                return;
            }
            
            Dom.XmlNode stepTasks = jobNode.getChildElement(TASK_STEPTASKS, jobNode.getNamespace());
            
            if (stepTasks == null) {
                System.debug('>>>> UNABLE TO FIND StepTasks node! Aborting!');
                return;
            }
            
            Dom.XmlNode[] taskNodes = stepTasks.getChildElements();
            
            if (taskNodes == null || taskNodes.size() == 0) {
                System.debug('>>> There were no task nodes.');
                return;
            }

            // Default to the last task, in case there isn't a current one.
            Dom.XmlNode currentTaskNode = taskNodes[taskNodes.size() - 1];

            for (Dom.XmlNode taskNode : taskNodes) {
                String isCurrentForm = this.getValueFromTask(taskNode, TASK_ISCURRENTFORM);

                if (isCurrentForm == null) {
                    continue;
                }
                
                if (isCurrentForm == 'true') {
                    currentTaskNode = taskNode;
                }
            }

            String formUrl = this.getValueFromTask(currentTaskNode, TASK_FORMURL);
            String formName = this.getValueFromTask(currentTaskNode, TASK_FORMNAME);

            // Save the identified form URL; it will be null if one isn't found.
            appInfo.formUrl = formUrl;
            appInfo.formName = formName;
        } catch (Exception e) {
            System.debug('>>>>>>> Threw an exception: ' + e + 'Info: ' + e.getStackTraceString());
        }
	}
    
    private String getValueFromTask(Dom.XmlNode taskNode, String nodeName) {
        if (taskNode == null) {
            return null;
        }
        
        Dom.XmlNode childNode = taskNode.getChildElement(nodeName, taskNode.getNamespace());
        
        if (childNode == null) {
            return null;
        }

        String value = childNode.getText();
        return value;
    }

}