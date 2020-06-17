public without sharing class AOApplicationDataController {

	public static void persistApplicationInfo(AOApplicationInfo appInfo, avoka__Transact_Delivery__c delivery) {
		Id onlineAccountOpeningRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Online Account Opening').getRecordTypeId();

		// Identify if an existing case exists for this job.  The primary and joint applicants will have separate
		// job reference numbers.
		Case existingCase = getJobCase(appInfo.job, onlineAccountOpeningRecordId);

		// If a contact was not found, create a new account and contact to associate the case and/or opportunity with.
		// Otherwise, update the existing contact as long as it is not a DNA record.
		Contact applicant = getApplicantContact(appInfo, existingCase);
		if (applicant == null) {
			applicant = createNewContact(appInfo);
		} else if (applicant.recordType.name != RecordTypeConstants.CONTACT_DNA) {
			updateContact(applicant, appInfo);
		}

        // Only applicable for youth accounts
        Contact guardianApplicant = null;
        if (appInfo.isYouthApplication) {
            guardianApplicant = getYouthGuardianContact(appInfo, existingCase);

            if (guardianApplicant == null) {
                createNewGuardianContact(appInfo);
            } else if (guardianApplicant.recordType.name != RecordTypeConstants.CONTACT_DNA) {
                updateGuardianContact(guardianApplicant, appInfo);
            }
        }


		// If an applicant isn't present at this point, the rest of this process will fail.  So,
		// don't even try.  However, make sure to log the exception.
		if (applicant == null) {
			String lastError = !appInfo.errors.isEmpty() ? appInfo.errors.get(appInfo.errors.size()-1) : null;
			LogUtils.log(LoggingLevel.ERROR, 'AvokaDeliveryProcessor', delivery.id, 'Job: ' + delivery.avoka__Job_Reference_Code__c + ' - ' + lastError);
			return;
		}

		// Determine if a loan product is present on the application; deposit products don't use opportunities at this time.
		Opportunity opp = getApplicationOpportunity(appInfo);
		if (!appInfo.isJointApplication && opp == null) {
			opp = createNewOpportunity(appInfo, applicant);
		} else if (opp != null) {
			updateOpportunity(appInfo, applicant, opp);
		}

		// Create a new case or update the existing open case with the latest information from Avoka.
        Case c = new Case();

		// Identify an appropriate owner for the case.
        if (appInfo.isJointApplication) {
            if (existingCase != null) {
                c.ownerId = existingCase.ownerId;
                c.parentId = existingCase.id;
            } else {
                Exception e = new IllegalArgumentException('This is a joint application, but no parent case was found.');
                appInfo.addExceptionError('persistApplicationInfo', e);
            }
        } else if (existingCase == null) {
			Group oaoQueue = [
				SELECT id
				FROM Group
				WHERE type = 'Queue'
					AND developerName = 'FSCOnlineAccountOpening'
			];
			c.ownerId = oaoQueue.id;
		}

		// Determine if there are one or more loan application Ids present.
		Boolean hasApplicationId = appInfo.loanApplicationIds != null && appInfo.loanApplicationIds.size() > 0;

		// Deteremine what the case status should be.  Abandoned statuses will NEVER re-open a case.
		c.status = 'Open';
		if (appInfo.isAbandoned) {
			c.status = 'Closed';
		} else if (appInfo.isError || hasApplicationId) {
			c.status = 'In Review';
		} else if (appInfo.isComplete && appInfo.eligibilityResponse == 'Purchasing a home in Idaho') {
			c.status = 'In Review';
		} else if (appInfo.isComplete) {
			c.status = 'Closed';
		}

        c.recordTypeId = onlineAccountOpeningRecordId;
		c.contactId = applicant.id;
		c.opportunity__c = opp != null ? opp.id : null;
		c.subject = (appInfo.isJointApplication ? 'Joint Application ' : 'Application ') + appInfo.job;
		c.avokaTrackingCode__c = appInfo.trackingCode;
		c.avokaJob__c = appInfo.job;
		c.avokaForm__c = appInfo.form;
		c.avokaFormName__c = appInfo.formName;
		c.avokaStatus__c = appInfo.status;
		c.avokaTransactionStatus__c = appInfo.transactionStatus;
		c.avokaError__c = getErrorString(appInfo);
		c.avokaFormUrl__c = appInfo.formUrl;
		c.avokaApplicationInfoJson__c = getApplicationInfoJson(appInfo);
		c.productMajorCode__c = appInfo.productMajorCode;
		c.productMinorCode__c = appInfo.productMinorCode;
		c.suppliedEmail = applicant.email;
		c.eligibilityResponse__c = appInfo.eligibilityResponse != null ? appInfo.eligibilityResponse : c.eligibilityResponse__c;

        if (appInfo.isYouthApplication && guardianApplicant != null) {
            c.ResponsibleParty__c = guardianApplicant.Id;
        }

		if (appInfo.promoCode != null) {
            c.promotion__c = appInfo.promoCode;
        }

        if (appInfo.productName != null) {
            c.productName__c = appInfo.productName;
        }

		if (appInfo.isJointApplication) {
			insert c;
		} else if (existingCase != null && existingCase.id != null) {
			c.id = existingCase.id;
			update c;
		} else {
			insert c;
		}
		appInfo.caseId = c.id;
	}

	/**
	 * A helper object for serializing the application info as a JSON string.
	 */
	class AppInfoJson {
		public Map<String,AOInteractionResult> systemInteractionResults;
		public List<IAccount> newAccounts;
        public List<Map<String, Object>> reports = new List<Map<String, Object>>();
        public List<AOApplicationInfo.AOLoanApplication> loanApplications;
        public List<String> loanApplicationIds;
        public String paymentType;
        public boolean successfullyTransferedFunds;
        public boolean isFatalError;
	}

	/**
	 * Serializes components of the AOApplicationInfo object into a JSON string for use by
	 * lightning components.
	 */
	public static String getApplicationInfoJson(AOApplicationInfo appInfo) {
		AppInfoJson info = new AppInfoJson();
		info.systemInteractionResults = appInfo.systemInteractionResults;
		info.newAccounts = appInfo.newAccounts;

        if (appInfo.creditReport != null) {
            info.reports.add(appInfo.creditReport);
        }

        if (appInfo.kbaReport != null) {
            info.reports.add(appInfo.kbaReport);
        }

        if (appInfo.backgroundCheckReport != null) {
            info.reports.add(appInfo.backgroundCheckReport);
        }

        if (appInfo.loanApplications != null) {
            info.loanApplications = appInfo.loanApplications;
        }

        if (appInfo.loanApplicationIds != null) {
            info.loanApplicationIds = appInfo.loanApplicationIds;
        }

        if (appInfo.propayPaymentType != null) {
            info.paymentType = appInfo.propayPaymentType;
        }

        if (appInfo.successfullyTransferedFunds != null) {
            info.successfullyTransferedFunds = appInfo.successfullyTransferedFunds;
        }

        info.isFatalError = appInfo.isFatalError;

		return JSON.serialize(info);
	}

	private static Case getJobCase(String job, Id onlineAccountOpeningRecordId) {
		if (!String.isEmpty(job)) {
			List<Case> cases = [
				SELECT id,
					contactId,
					ownerId
				FROM Case
				WHERE recordTypeId = :onlineAccountOpeningRecordId
					AND avokaJob__c = :job];
			if (cases.size() > 0) {
				return cases[0];
			}
		}

		return null;
	}

	/**
	 * Identify the applicant using the person number, tax Id, email, phone or existing case, as applicable.
	 * NOTE: IF YOU CHANGE ***ANY*** LOGIC IN HERE, PLEASE UPDATE getYouthGuardianContact.
	 */
    private static Contact getApplicantContact(AOApplicationInfo appInfo, Case existingCase) {
        List<Contact> contacts = new List<Contact>();
        if (appInfo.isJointApplication || existingCase == null || existingCase.contactId == null) {

            // Get by person #
            if (!String.isEmpty(appInfo.personNumber)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE personNumber__c = :appInfo.personNumber
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by tax ID
            if (contacts.size() == 0
				&& !String.isEmpty(appInfo.taxId)
				&& !String.isEmpty(appInfo.idNumber))
			{
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE taxId__c = :appInfo.taxId
						AND identificationNumber__c = :appInfo.idNumber
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by email
            if (contacts.size() == 0 && !String.isEmpty(appInfo.email)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE email = :appInfo.email
                        AND firstName = :appInfo.firstName
                        AND lastName = :appInfo.lastName
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by Phone #
            if (contacts.size() == 0 && !String.isEmpty(appInfo.phone)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE phone = :appInfo.phone
                        AND firstName = :appInfo.firstName
                        AND lastName = :appInfo.lastName
                    ORDER BY createdDate DESC, recordType.name
                ];
            }
        } else {
            contacts = [
                SELECT id,
                    accountId,
                    email,
                    recordType.name
                FROM Contact
                WHERE Id = :existingCase.contactId
            ];
        }

        // When multiple contacts are found, the system will always use the DNA record over all others.
        // When no DNA record is found, it will use the contact that was created first (oldest).
        Contact applicant = null;
        for (Contact contact : contacts) {
            if (contact.recordType.name == RecordTypeConstants.CONTACT_DNA) {
                applicant = contact;
                break; // Immediately exit with this contact Id
            } else {
                applicant = contact;
            }
        }

        return applicant;
    }

    private static Contact getYouthGuardianContact(AOApplicationInfo appInfo, Case existingCase) {
        List<Contact> contacts = new List<Contact>();
        if (appInfo.isYouthApplication || existingCase == null || existingCase.contactId == null) {

            // Get by person #
            if (!String.isEmpty(appInfo.guardianPersonNumber)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE personNumber__c = :appInfo.guardianPersonNumber
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by tax ID
            if (contacts.size() == 0
				&& !String.isEmpty(appInfo.guardianTaxId)
				&& !String.isEmpty(appInfo.guardianIdNumber))
			{
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE taxId__c = :appInfo.guardianTaxId
						AND identificationNumber__c = :appInfo.guardianIdNumber
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by email
            if (contacts.size() == 0 && !String.isEmpty(appInfo.guardianEmail)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE email = :appInfo.guardianEmail
                        AND firstName = :appInfo.guardianFirstName
                        AND lastName = :appInfo.guardianLastName
                    ORDER BY createdDate DESC, recordType.name
                ];
            }

            // Get by Phone #
            if (contacts.size() == 0 && !String.isEmpty(appInfo.guardianPhone)) {
                contacts = [
                    SELECT id,
                        accountId,
                        email,
                        recordType.name
                    FROM Contact
                    WHERE phone = :appInfo.guardianPhone
                        AND firstName = :appInfo.guardianFirstName
                        AND lastName = :appInfo.guardianLastName
                    ORDER BY createdDate DESC, recordType.name
                ];
            }
        } else {
            contacts = [
                SELECT id,
                    accountId,
                    email,
                    recordType.name
                FROM Contact
                WHERE Id = :existingCase.contactId
            ];
        }

        // When multiple contacts are found, the system will always use the DNA record over all others.
        // When no DNA record is found, it will use the contact that was created first (oldest).
        Contact applicant = null;
        for (Contact contact : contacts) {
            if (contact.recordType.name == RecordTypeConstants.CONTACT_DNA) {
                applicant = contact;
                break; // Immediately exit with this contact Id
            } else {
                applicant = contact;
            }
        }

        return applicant;
    }

	private static Contact createNewContact(AOApplicationInfo appInfo) {
		Savepoint sp = Database.setSavepoint();
		try {
			// Create a new non-DNA account for the applicant.
			Id defaultAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();
			Account account = new Account();
			account.recordTypeId = defaultAccountRecordTypeId;
			if (!String.isEmpty(appInfo.personNumber)) {
				account.name = 'P' + appInfo.personNumber;
			} else {
				account.name = appInfo.firstName + ' ' + appInfo.lastName;
			}
			insert account;

			// Create a new non-DNA contact for the applicant.
			Id defaultContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();
			Contact applicant = new Contact();
			applicant.recordTypeId = defaultContactRecordTypeId;
			applicant.accountId = account.id;
			applicant.personNumber__c = appInfo.personNumber;
			applicant.taxId__c = appInfo.taxId;
			applicant.firstName = appInfo.firstName;
			applicant.lastName = appInfo.lastName;
			applicant.email = appInfo.email;
			applicant.phone = appInfo.phone;
			applicant.mobilePhone = appInfo.mobilePhone;
			applicant.businessPhone__c = appInfo.workPhone;
			applicant.birthdate = appInfo.birthDate;
			applicant.identificationNumber__c = appInfo.idNumber;
			applicant.identificationType__c = appInfo.idType;
			applicant.identificationIssueState__c = appInfo.idIssueState;
			applicant.identificationIssueDate__c = appInfo.idIssueDate;
			applicant.identificationExpirationDate__c = appInfo.idExpiryDate;
			applicant.leadSource = 'Avoka';
			applicant.mailingStreet = appInfo.mailingStreet + (!String.isEmpty(appInfo.mailingStreet2) ? '\n' + appInfo.mailingStreet2 : '');
			applicant.mailingCity = appInfo.mailingCity;
			applicant.mailingState = appInfo.mailingState;
			applicant.mailingPostalCode = appInfo.mailingPostalCode;
			applicant.mailingCountry = appInfo.mailingCountryCode;
			applicant.creditScore__c = appInfo.creditScore;

			insert applicant;
			return applicant;
		} catch (Exception e) {
			// When the contact creation fails, the system will still attempt to create a case.
			appInfo.addExceptionError('AOApplicationDataController', e);

			// Ensure that the account and contact are both always created together and if anything
			// prevents the contact from being created, roll back the account creation.
			Database.rollback(sp);
		}

		return null;
	}

    private static Contact createNewGuardianContact(AOApplicationInfo appInfo) {
		Savepoint sp = Database.setSavepoint();
		try {
			// Create a new non-DNA account for the applicant.
			Id defaultAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();
			Account account = new Account();
			account.recordTypeId = defaultAccountRecordTypeId;
			if (!String.isEmpty(appInfo.guardianPersonNumber)) {
				account.name = 'P' + appInfo.guardianPersonNumber;
			} else {
				account.name = appInfo.guardianFirstName + ' ' + appInfo.guardianLastName;
			}
			insert account;

			// Create a new non-DNA contact for the applicant.
			Id defaultContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();
			Contact applicant = new Contact();
			applicant.recordTypeId = defaultContactRecordTypeId;
			applicant.accountId = account.id;
			applicant.personNumber__c = appInfo.guardianPersonNumber;
			applicant.taxId__c = appInfo.guardianTaxId;
			applicant.firstName = appInfo.guardianFirstName;
			applicant.lastName = appInfo.guardianLastName;
			applicant.email = appInfo.guardianEmail;
			applicant.phone = appInfo.guardianPhone;
			applicant.mobilePhone = appInfo.guardianMobilePhone;
			applicant.businessPhone__c = appInfo.guardianWorkPhone;
			applicant.birthdate = appInfo.guardianBirthDate;
			applicant.identificationNumber__c = appInfo.guardianIdNumber;
			applicant.identificationType__c = appInfo.guardianIdType;
			applicant.identificationIssueState__c = appInfo.guardianIdIssueState;
			applicant.identificationIssueDate__c = appInfo.guardianIdIssueDate;
			applicant.identificationExpirationDate__c = appInfo.guardianIdExpiryDate;
			applicant.leadSource = 'Avoka';
			applicant.mailingStreet = appInfo.guardianMailingStreet + (!String.isEmpty(appInfo.guardianMailingStreet2) ? '\n' + appInfo.guardianMailingStreet2 : '');
			applicant.mailingCity = appInfo.guardianMailingCity;
			applicant.mailingState = appInfo.guardianMailingState;
			applicant.mailingPostalCode = appInfo.guardianMailingPostalCode;
			applicant.mailingCountry = appInfo.guardianMailingCountryCode;
			applicant.creditScore__c = appInfo.guardianCreditScore;

			insert applicant;
			return applicant;
		} catch (Exception e) {
			// When the contact creation fails, the system will still attempt to create a case.
			appInfo.addExceptionError('AOApplicationDataController', e);

			// Ensure that the account and contact are both always created together and if anything
			// prevents the contact from being created, roll back the account creation.
			Database.rollback(sp);
		}

		return null;
	}

	/**
	 * This method can be called to update an existing contact in the system.  Only key pieces of information will
	 * be updated on the record.  These items are necessary for uniquely identifying the record for the purposes
	 * of deduplication.
	 */
	private static void updateContact(Contact applicant, AOApplicationInfo appInfo) {
		Boolean updateRequired = false;
		if (!String.isEmpty(appInfo.taxId)) {
			applicant.taxId__c = appInfo.taxId;
			updateRequired = true;
		}
		if (!String.isEmpty(appInfo.personNumber)) {
			applicant.personNumber__c = appInfo.personNumber;
			updateRequired = true;
		}
		if (updateRequired) {
			try {
				update applicant;
			} catch (Exception e) {
				appInfo.addExceptionError('AOApplicationDataController', e);
			}
		}
	}

    /**
	 * This method can be called to update an existing contact in the system.  Only key pieces of information will
	 * be updated on the record.  These items are necessary for uniquely identifying the record for the purposes
	 * of deduplication.
	 */
	private static void updateGuardianContact(Contact applicant, AOApplicationInfo appInfo) {
		Boolean updateRequired = false;
		if (!String.isEmpty(appInfo.guardianTaxId)) {
			applicant.taxId__c = appInfo.guardianTaxId;
			updateRequired = true;
		}
		if (!String.isEmpty(appInfo.personNumber)) {
			applicant.personNumber__c = appInfo.guardianPersonNumber;
			updateRequired = true;
		}
		if (updateRequired) {
			try {
				update applicant;
			} catch (Exception e) {
				appInfo.addExceptionError('AOApplicationDataController', e);
			}
		}
	}

	private static String getOpportunityName(AOApplicationInfo appInfo) {
		String oppName = appInfo.firstName + ' ' + appInfo.lastName;
		if (appInfo.productName != null) {
			oppName += ' - ' + appInfo.productName;
		} else if (!String.isEmpty(appInfo.productMajorCode)) {
			if (!String.isEmpty(appInfo.productMinorCode)) {
				oppName += ' - ' + appInfo.productMajorCode +  '/' + appInfo.productMinorCode;
			} else {
				oppName += ' - ' + appInfo.productMajorCode;
			}
		}
		return oppName;
	}

	private static Opportunity getApplicationOpportunity(AOApplicationInfo appInfo) {
		String job = appInfo.job;

		// Determine if there is an existing opportunity.  If there are multiple opportunities, it is
		// because a record was cloned.  As such, the SOQL query will use the oldest record as the one that was
		// automatically created by the Avoka form delivery process.
		List<Opportunity> opps = [
			SELECT id,
				closeDate,
				isClosed,
				isWon,
				recordTypeId,
				stageName
			FROM Opportunity
			WHERE avokaJob__c = :job ORDER BY createdDate ASC
		];
		if (opps.size() > 0) {
			return opps[0];
		}

		return null;
	}

	private static Opportunity createNewOpportunity(AOApplicationInfo appInfo, Contact applicant) {
		Savepoint sp = Database.setSavepoint();
		try {
            String json = getApplicationInfoJson(appInfo);

			Opportunity opp = new Opportunity();
            opp.recordTypeId = getOpportunityRecordType(appInfo);
			opp.accountId = applicant.accountId;
			opp.ownerId = IdUtils.BATCH_USER_ID;
			opp.name = getOpportunityName(appInfo);
			opp.type = appInfo.productMajorCode == AOConstants.PRODUCT_MAJOR_TYPE_CRIF ? 'Loan' : 'Deposit';
			opp.avokaJob__c = appInfo.job;
			setOpportunityStage(appInfo, opp, true);
			opp.leadSource = 'Avoka';
			opp.product__c = appInfo.productName; // TODO:  These will NOT correspond to the vaules in the pick list, but will be stored as-is.  Is this okay?  It will impact reports, list views, etc.
			opp.productMajorCode__c = appInfo.productMajorCode;
			opp.productMinorCode__c = appInfo.productMinorCode;
			opp.amount = appInfo.loanTotalAmount;
            opp.product_amount__c = appInfo.loanTotalAmount;
			opp.credit_score__c = appInfo.creditScore;
            opp.avokaApplicationInfoJSON__c = json;
			if (appInfo.loanApplicationIds != null && appInfo.loanApplicationIds.size() > 0) {
				opp.app_id__c = appInfo.loanApplicationIds[0];
			}
			insert opp;

			// Associate the contact with the opportunity
			OpportunityContactRole oppContactRole = new OpportunityContactRole();
			oppContactRole.opportunityId = opp.id;
			oppContactRole.contactId = applicant.id;
			oppContactRole.role = appInfo.isJointApplication ? 'Joint' : 'Primary Borrower';
			oppContactRole.isPrimary = true;
			insert oppContactRole;

			return opp;
		} catch (Exception e) {
			// When the opportunity creation fails, the system will still attempt to create a case.
			appInfo.addExceptionError('AOApplicationDataController', e);

			// Ensure that the account and contact are both always created together and if anything
			// prevents the contact from being created, roll back the account creation.
			Database.rollback(sp);
		}

		return null;
	}

	private static void updateOpportunity(AOApplicationInfo appInfo, Contact applicant, Opportunity opp) {
        String json = getApplicationInfoJson(appInfo);
        opp.avokaApplicationInfoJSON__c = json;

		// Determine the record type of the opportunity.
		opp.recordTypeId = getOpportunityRecordType(appInfo);

		// Determine what the stage of the opportunity and associated settings should be.
		setOpportunityStage(appInfo, opp, false);

		// All of the following fields will always be updated, but only if they are present in the
		// payload.  Some values are not present on the accountsandfunding step, but are present on
		// prior steps.
		if (appInfo.loanTotalAmount != null) {
			opp.amount = appInfo.loanTotalAmount;
            opp.product_amount__c = appInfo.loanTotalAmount;
		}
		if (appInfo.loanApplicationIds != null && appInfo.loanApplicationIds.size() > 0) {
			opp.app_id__c = appInfo.loanApplicationIds[0];
		}
		if (appinfo.creditScore != null) {
			opp.credit_score__c = appInfo.creditScore;
		}

        try {
            update opp;
        } catch (Exception e) {
            // When the opportuntiy update fails, the system will still attempt to create a case.
            appInfo.addExceptionError('AOApplicationDataController', e);
        }

		// Associate the joint applicant with the opportunity if they aren't already present.
		if (appInfo.isJointApplication) {
			try {
				List<OpportunityContactRole> contactRoles = [
					SELECT id
					FROM OpportunityContactRole
					WHERE opportunityId = :opp.id AND contactId = :applicant.id
				];
				if (contactRoles.size() == 0) {
					OpportunityContactRole oppContactRole = new OpportunityContactRole();
					oppContactRole.opportunityId = opp.id;
					oppContactRole.contactId = applicant.id;
					oppContactRole.role = appInfo.isJointApplication ? 'Joint' : 'Primary Borrower';
					oppContactRole.isPrimary = !appInfo.isJointApplication;
					insert oppContactRole;
				}
			} catch (Exception e) {
				// When the contact role creation fails, the system will still attempt to create a case.
				appInfo.addExceptionError('AOApplicationDataController', e);
			}
		}

		// NOTE:  We could consider updating the status of the opportunity in the future if the
		// Avoka data contains information that would help us advance the process (e.g. funding might
		// change the opportunity stage).
	}

	private static Id getOpportunityRecordType(AOApplicationInfo appInfo) {
		// Determine the record type of the opportunity.
		String recordTypeName = RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT;
		if (appInfo.productMajorCode == AOConstants.PRODUCT_MAJOR_TYPE_CRIF) {
			if (appInfo.productMinorCode == AOConstants.PRODUCT_MINOR_TYPE_HELOC) {
				recordTypeName = RecordTypeConstants.OPPORTUNITY_HELOC;
			} else {
				recordTypeName = RecordTypeConstants.OPPORTUNITY_LOAN;
			}
		}

		// Retrieve the record type Id
		Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		return recordTypeId;
	}

	private static void setOpportunityStage(AOApplicationInfo appInfo, Opportunity opp, Boolean setNew) {
		if (appInfo.isAbandoned) {
			// When the application is abandoned, close the opportunity if it isn't already.
			if (!opp.isClosed) {
				opp.stageName = 'Member Rejected';
				opp.lost_Reason__c = 'Abandoned';
				opp.closeDate = System.today();
			}
		} else if (appInfo.productMajorCode != AOConstants.PRODUCT_MAJOR_TYPE_CRIF) {
			// If the application is complete and the opportunity is not already closed, do so.
			if (appInfo.isComplete && !appInfo.isError && !opp.isClosed) {
				opp.stageName = 'Complete';
				opp.closeDate = System.today();
			}

			// If the application is not complete and was previously closed, re-open the opportunity
			// since there likely was an error (e.g. fraud on joint application).
			if (!appinfo.isComplete && !appInfo.isError && opp.isClosed) {
				opp.stageName = IdUtils.isQueue(opp.ownerId) ? 'New' : 'Assigned';
				if (opp.closeDate <= System.today()) {
					opp.closeDate = System.today().addDays(1);
				}
			}
		}

		// If this is a new opportunity, verify that the stage and close date are set.
		if (setNew) {
			if (opp.stageName == null) {
				opp.stageName = 'New';
			}
			if (opp.closeDate == null) {
				opp.closeDate = System.today().addDays(1);
			}
		}

		// To prevent issues for updating opportunities triggering close date validation, ensure the
		// close date isn't in the past if the case is still open.
		if (!opp.isClosed && (opp.closeDate == null || opp.closeDate < System.today())) {
			opp.closeDate = System.today();
		}
	}

	/**
	 * Converts the list of errors into a single string for saving on the case or for debug output.
	 * NOTE:  This is public so that it can be used in other classes for debug purposes.
	 */
	public static String getErrorString(AOApplicationInfo appinfo) {
        // Cycle through and create one, big, happy error.
		String errors = null;
        if (appInfo.errors.size() > 0) {
            errors = '';
            for (String err : appInfo.errors) {
                errors = errors + err + '\n';
            }

            // Logic for truncating our error messages
            Integer maxErrorLength = 131072; // Maximum field size in SF

            if (errors.length() > maxErrorLength) {
                String truncatedMessage = '(TRUNCATED)';

                // We want to let the end user know that the message was
                // too long to fit in this field, so we need to substract
                // the length of the '(truncated)' message and subtract 1,
                // because it is a 0-based index.
                Integer endIndex = maxErrorLength - truncatedMessage.length() - 1;

                // Substring to the endIndex and concatonate the truncated message. Gosh, I wish we a StringBuilder class...
                errors = errors.substring(0, endIndex) + truncatedMessage;
            }
        }

		return errors;
	}

}