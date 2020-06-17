public class MemberApplicationsController {
    @TestVisible
    private static INetworkFactory networkFactory;

	@AuraEnabled
    public static Map<String, Object> getOpenApplications(String contactId) {
        Map<String, Object> response = new Map<String, Object>();
        
        if (MemberApplicationsController.networkFactory == null) {
            MemberApplicationsController.networkFactory = new ConcreteNetworkProvider();
        }
        
        if (contactId == null) {
            response.put('error', 'Contact ID is null!');
            return response;
        }

        Contact contact = [
	            SELECT
	            	TaxID__c
	            FROM Contact 
	            WHERE ID = :contactId
	        	LIMIT 1
	        ];
        
        if (contact == null) {
            response.put('error', 'No member of contact ID ' + contactId);
            return response;
        }

        SFPerson person = new SFPerson(contact);

        if (person.getTaxId() == null) {
            response.put('error', 'Contact is missing its SSN.');
            return response;
        }

        IProductApplicationDataProvider appProvider = networkFactory.getProductApplicationDataProvider();
        
        try {
            DateTime endDate = System.now();
            DateTime startDate = endDate.addDays(-60);

            ProductApplicationResponse appResponse = appProvider.getOpenProductApplications(person, startDate, endDate);
            List<IProductApplication> applications = appResponse.getApplications();
            List<Map<String, Object>> responseApplications = new List<Map<String, Object>>();
       
            for (IProductApplication application : applications) {
                Map<String, Object> rawApplication = new Map<String, Object>();
				List<Map<String, Object>> rawMilestones = new List<Map<String, Object>>();
                
                for (ProductApplicationMilestone milestone : application.getMilestones()) {
                    Map<String, Object> rawMilestone = new Map<String, Object>();

                    rawMilestone.put('agent', MemberApplicationsController.mapAgent(milestone.getAgent()));
                    rawMilestone.put('displayName', milestone.getDisplayName());
                    rawMilestone.put('isComplete', milestone.getIsComplete());
                    rawMilestone.put('isCurrentMilestone', milestone.getIsCurrentMilestone());
                    rawMilestone.put('statusDate', milestone.getStatusDate());

                    rawMilestones.add(rawMilestone);
                }

                List<Map<String, Object>> rawNotes = new List<Map<String, Object>>();	
                for (ProductApplicationNote note : application.getNotes()) {
                    Map<String, Object> rawNote = new Map<String, Object>();
                    rawNote.put('agent', MemberApplicationsController.mapAgent(note.getAgent()));
                    rawNote.put('createdDate', note.getCreatedDate());
                    rawNote.put('text', note.getText());
                    rawNote.put('title', note.getTitle());
                    rawNote.put('updatedDate', note.getUpdatedDate());
                    
                    rawNotes.add(rawNote);
                }

                rawApplication.put('agent', MemberApplicationsController.mapAgent(application.getLoanOfficer()));
                rawApplication.put('applicationNumber', application.getApplicationNumber());
                rawApplication.put('creditScore', application.getCreditScore());
                rawApplication.put('isComplete', application.getIsComplete());
                rawApplication.put('isFunded', application.getIsFunded());
                rawApplication.put('milestones', rawMilestones);
                rawApplication.put('notes', rawNotes);
                rawApplication.put('productName', application.getProductName());
                rawApplication.put('status', application.getStatus());
                rawApplication.put('systemName', application.getSystemName());

                responseApplications.add(rawApplication);
            }
            /*
            String roleId = UserInfo.getUserRoleId();

            UserRole[] roles = 
                [SELECT 
                    Name
                FROM UserRole 
                WHERE id = :roleId];
			
            boolean isFSC = true; // Everyone can see these...
			
            String fscProfileName = 'FSC User';
            
            for (UserRole role : roles) {
                if (role.Name.contains(fscProfileName)) {
                    isFSC = true;
                    break;
                }
            }
            */
            String error = null;
            
            if (appResponse.getErrors().size() > 0) {
                error = ''; // Can't find a StringBuilder equivalent in APEX...
                
                for (String appError : appResponse.getErrors()) {
                    error += appError + ' ';
                }
            }

            response.put('applications', responseApplications);
            response.put('showApplicationDetails', true); // hard coded true for now...
            response.put('error', error);
        } catch (Exception e) {
            response.put('error', 'An unknown error occurred: ' + e + '\n\n' + e.getStackTraceString());
        }

        return response;
    }
    
    private static Map<String, Object> mapAgent(ProductApplicationAgent agent) {
        if (agent == null) {
            return null;
        }

        Map<String, Object> rawAgent = new Map<String, Object>();
        rawAgent.put('email', agent.getEmailAddress());
        rawAgent.put('extension', agent.getExtension());
        rawAgent.put('name', agent.getName());
        rawAgent.put('phone', agent.getPhone());

        return rawAgent;
    }
}