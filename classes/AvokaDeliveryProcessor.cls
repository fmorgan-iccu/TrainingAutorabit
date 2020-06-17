global class AvokaDeliveryProcessor implements avoka.ITransactDeliveryProcessor {

	// Idenitifies the various forms that will be parse and persisted.  All other forms will simply
	// have the delivery record packet removed. The delivery order of the forms is expected to be as
	// follows; it is important to note that the transact-sdk form is only used for manuall dev
	// testing regardless of the actual form:
	//		triage
	//		depositproducts or loanproducts
	//		disclosures
	//		accountsandfunding
	private static final List<String> FORMS_TO_PARSE = new List<String> {
        'accountsandfunding',
        'depositproducts',
        'disclosures',
        'loanproducts',
        'triage',
        'transact-sdk',
        'youth'
	};
	private static final List<String> FORMS_TO_PERSIST = new List<String> {
        'AT4SF-canvas',
        'accountsandfunding',
        'depositproducts',
        'disclosures',
        'loanproducts',
        'triage',
        'transact-sdk',
        'youth'
	};

	// This is used by the testing framework to validate the creation of the records.
	public AOApplicationInfo appInfo { get; set; }
 
 	/**
 	 * Primary entry point called by the Avoka plugin.  This is used for all of the Avoka entry
	 * points.
 	 */
    public void processDelivery(avoka__Transact_Delivery__c delivery, String processorConfig) {
        // Save the key delivery information within the app info object for later use.
        AOApplicationInfo appInfo = new AOApplicationInfo();
		appInfo.trackingCode = delivery.name;
        appInfo.job = delivery.avoka__Job_Reference_Code__c;
    	appInfo.form = delivery.avoka__Form_Code__c;
		appInfo.formName = delivery.avoka__Form_Name__c;
        appInfo.status = delivery.avoka__Processing_Status__c;
		appInfo.transactionStatus = delivery.avoka__Transaction_Status__c;
		appInfo.isAbandoned = delivery.avoka__Delivery_Trigger_Type__c == 'Abandoned Transaction';
        appInfo.isYouthApplication = false; // Initialize to false

		// The Avoka system can either deliver an uncompressed or compressed submission data value.
		// For compressed (Zip) content, this logic will loop through the files contained in the zip
		// archive and set the submission data to the contents of the payload.xml document.
		if (delivery.avoka__Submission_Data__c.left(5) == '<?xml') {
    		appInfo.submissionData = delivery.avoka__Submission_Data__c;
		} else {
			Blob zipBlob = EncodingUtil.base64Decode(delivery.avoka__Submission_Data__c);
			Zippex myZip = new Zippex(zipBlob);
			for (String fileName : myZip.getFileNames()) {
				if (fileName == 'payload.xml') {
					Blob fileData = myZip.getFile(fileName);
					appInfo.submissionData = fileData.toString();
					break;
				}
			}
		}

		// If the form should be parsed, parse the XML information into the application information
		// object.
        Map<String,Object> payload = new Map<String,Object>();
        payload.put(AOConstants.XML_FORM_KEY, appInfo.submissionData);
        
		if (FORMS_TO_PARSE.contains(appInfo.form)) {
			try {
				AOFormParser formParser = new AOFormParser();
				formParser.parsePayload(payload, appInfo);
			} catch (Exception e) {
				appInfo.addExceptionError('AvokaDeliveryProcessor', e);
                System.debug('************** Unable to parse form: ' + e.getMessage());
			}
		}

		// Once all of the parsers are complete, determine if there were any errors with the
		// system interactions or parsing.
		appInfo.detectErrorState();

		// Based on the parsed information, determine if the application has been completely
		// processed.
		// TODO:  It is very important that this logic be moved to Avoka since it is the system of
		// record about when an application is complete.
		// #avokafix
		Boolean isLoan = (appInfo.productMajorCode == AOConstants.PRODUCT_MAJOR_TYPE_CRIF);
		Boolean isComplete = (delivery.avoka__Delivery_Trigger_Type__c == 'Completed Transaction');
		Boolean isFundingForm = (delivery.avoka__Form_Code__c == 'accountsandfunding');
		Boolean isYouthForm = delivery.avoka__Form_Code__c == 'youth';
		Boolean isErroredOrAbandonded = (appInfo.isError || appInfo.isAbandoned);

		Boolean isCompleteAdultFlow = (!isLoan && isComplete && (isFundingForm || appInfo.isJointApplication) && !isErroredOrAbandonded);
		Boolean isCompleteYouthFlow = (isYouthForm && isComplete && !isErroredOrAbandonded);

		// adult form flow deliveries
		if (isCompleteAdultFlow || isCompleteYouthFlow) {
			appInfo.isComplete = true;
		}

		if (FORMS_TO_PERSIST.contains(appInfo.form)) {
			// Persist the Account Opening information in Salesforce.
			AOApplicationDataController.persistApplicationInfo(appInfo, delivery);
		}

		// Save the information for test validation.
        this.appInfo = appInfo;
	}
    
}