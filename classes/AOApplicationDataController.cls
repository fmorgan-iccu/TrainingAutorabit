public without sharing class AOApplicationDataController {

    public static Opportunity persistApplicationInfo(AOApplicationInfo appInfo) {
        // Create/update all of the applicant contact records, as necessary.
        AOApplicationRestRequest.Person appPerson = appInfo.appRequest.applicant.person;
        List<AOApplicationRestRequest.Person> coappPersons = new List<AOApplicationRestRequest.Person>();
        if (appInfo.appRequest.co_applicants != null) {
            for (AOApplicationRestRequest.Applicant a : appInfo.appRequest.co_applicants) {
                coappPersons.add(a.person);
            }
        }
        List<Contact> coApplicants = new List<Contact>();

        // Create the account and contact.
        Contact applicant = AOApplicationDataController.createUpdateContacts(appInfo, appPerson, coappPersons, coApplicants);

        // If an applicant isn't present at this point, the rest of this process will fail.  So,
        // don't even try.  However, make sure to log the exception.
        if (applicant == null) {
            String lastError = !appInfo.errors.isEmpty() ? appInfo.errors.get(appInfo.errors.size()-1) : null;
            LogUtils.log(LoggingLevel.ERROR, 'AOApplicationDataController', null, 'Job: ' + appInfo.appRequest.form.job_reference_code + ' - ' + lastError);
            return null;
        }

        // Find the opportunity for this request.  If one doesn't exist, create one only if a product is present.
        AOApplicationRestRequest.FinancialProduct product = null;
        if (appInfo.appRequest.products != null && appInfo.appRequest.products.size() > 0) {
            product = appInfo.appRequest.products[0];
        }
        Opportunity opp = getApplicationOpportunity(appInfo.appRequest.application_id);
        if (opp == null) {
            opp = createNewOpportunity(appInfo, applicant, coApplicants, appPerson, product);
        } else {
            updateOpportunity(appInfo, applicant, coApplicants, appPerson, product, opp);
        }

        return opp;
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
        public Boolean successfullyTransferedFunds;
    }

    /**
     * Serializes components of the AOApplicationInfo object into a JSON string for use by
     * lightning components.
     */
    public static String getApplicationInfoJson(AOApplicationInfo appInfo) {
        AppInfoJson info = new AppInfoJson();
        info.systemInteractionResults = appInfo.systemInteractionResults;
        info.newAccounts = appInfo.getOpenedAccounts();

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

        if (appInfo.appRequest.funding_info != null) {
            info.paymentType = appInfo.appRequest.funding_info.payment_type;
        }

        info.successfullyTransferedFunds = appInfo.successfullyTransferedFunds;

        return JSON.serialize(info);
    }

    /**
     * Creates/updates the applicants provided.
     * @param appInfo The application information object
     * @param appPerson The primary applicant person
     * @param coappPersons The co-applicant person list
     * @param coApplicants A list to add all new coapplicant contacts to (return value)
     * @return The primary contact
     */
    private static Contact createUpdateContacts(
        AOApplicationInfo appInfo,
        AOApplicationRestRequest.Person appPerson,
        List<AOApplicationRestRequest.Person> coappPersons,
        List<Contact> coApplicants)
    {
        // Create a unified list of all applicants to optimize the DML.  Make sure the primary applicant is at the head
        // of the list.  This is important for the way the algorithm works.
        List<AOApplicationRestRequest.Person> persons = new List<AOApplicationRestRequest.Person>();
        persons.add(appPerson);
        persons.addAll(coappPersons);

        // Identify the persons to create and update
        List<AOApplicationRestRequest.Person> personsToCreate = new List<AOApplicationRestRequest.Person>();
        List<AOApplicationRestRequest.Person> personsToUpdate = new List<AOApplicationRestRequest.Person>();
        List<Contact> contactsToUpdate = new List<Contact>();
        for (AOApplicationRestRequest.Person p : persons) {
            Contact c = AOApplicationDataController.getApplicantContact(p);
            if (c == null) {
                personsToCreate.add(p);
            } else {
                // Create associative arrays of the persons/contacts to update
                personsToUpdate.add(p);
                contactsToUpdate.add(c);
            }
        }

        // Create the accounts and contacts for the new persons
        List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        if (personsToCreate.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            try {
                for (AOApplicationRestRequest.Person p : personsToCreate) {
                    Account a = AOApplicationDataController.createNewAccount(p);
                    accountsToInsert.add(a);
                }
                insert accountsToInsert;

                for (Integer i = 0; i < personsToCreate.size(); i++) {
                    AOApplicationRestRequest.Person p = personsToCreate[i];
                    Contact c = AOApplicationDataController.createNewContact(p, accountsToInsert[i]);
                    contactsToInsert.add(c);
                }
                insert contactsToInsert;
            } catch (Exception e) {
                // Make sure to clear out the Ids of the accounts to make sure it reflects the roll-back.
                for (Account a : accountsToInsert) {
                    a.id = null;
                }

                // Ensure that the account and contact are both always created together and if anything
                // prevents the contact from being created, roll back the account creation.
                Database.rollback(sp);

                LogUtils.log(LoggingLevel.ERROR, 'AOApplicationDataController', e.getMessage() + ' : ' + e.getStackTraceString());
            }
        }

        // Update the contacts for the existing persons.
        for (Integer i = 0; i < personsToUpdate.size(); i++) {
            AOApplicationRestRequest.Person p = personsToUpdate[i];
            Contact c = contactsToUpdate[i];
            AOApplicationDataController.updateContact(p, c);
        }
        if (contactsToUpdate.size() > 0) {
            try {
                update contactsToUpdate;
            } catch (Exception e) {
                LogUtils.log(LoggingLevel.ERROR, 'AOApplicationDataController', e.getMessage() + ' : ' + e.getStackTraceString());
            }
        }

        // The applicant is the first contact at the beginning of either the create or update list.  Set the applicant
        // contact as appropriate.
        Contact applicant = null;
        if (personsToCreate.size() > 0 && appPerson == personsToCreate[0]) {
            applicant = contactsToInsert.remove(0);
        } else {
            applicant = contactsToUpdate.remove(0);
        }

        // The remaining contacts that were inserted/updated are co-applicants.
        coApplicants.addAll(contactsToInsert);
        coApplicants.addAll(contactsToUpdate);

        return applicant;
    }

    /**
     * Identify the applicant using the person number, tax Id, email, or phone, as applicable.
     */
    private static Contact getApplicantContact(AOApplicationRestRequest.Person applicant) {
        // Map values to local variables to allow them to be used in the data bindings.
        String email = applicant.email;
        String firstName = applicant.first_name;
        String identificationNumber = applicant.identification != null ? applicant.identification.id_number : null;
        String lastName = applicant.last_name;
        String personNumber = applicant.person_number;
        String phoneNumber = applicant.home_phone != null ? PhoneUtils.format(applicant.home_phone.phone_number) : null;
        String taxId = applicant.tax_id;

        // Assemble a single where clause with the data bindings to the various combinations that should be allowed
        // when searching for a matching contact.  This will allow a single SOQL query to be executed to return possible
        // matching records.
        String whereClause = '';
        if (!String.isBlank(personNumber)) {
            whereClause +=
                (!String.isBlank(whereClause) ? ' OR ' : '') +
                'personNumber__c = :personNumber';
        }
        if (!String.isBlank(taxId)) {
            whereClause +=
                (!String.isBlank(whereClause) ? ' OR ' : '') +
                '(taxId__c = :taxId AND recordType.name = \'DNA\')';
        }
        if (!String.isBlank(taxId) && !String.isBlank(identificationNumber)) {
            whereClause +=
                (!String.isBlank(whereClause) ? ' OR ' : '') +
                '(taxId__c = :taxId AND identificationNumber__c = :identificationNumber)';
        }
        if (!String.isBlank(email)) {
            whereClause +=
                (!String.isBlank(whereClause) ? ' OR ' : '') +
                '(email = :email AND firstName = :firstName AND lastName = :lastName)';
        }
        if (!String.isBlank(phoneNumber)) {
            whereClause +=
                (!String.isBlank(whereClause) ? ' OR ' : '') +
                '(phone = :phoneNumber AND firstName = :firstName AND lastName = :lastName)';
        }

        // Query to find the matching contact using the assembled WHERE clause.
        String soqlQuery =
            'SELECT id, accountId, email, personNumber__c, recordType.name ' +
            'FROM Contact ' +
            'WHERE ' +
            whereClause +
            'ORDER BY createdDate DESC, recordType.name';
        List<Contact> contacts = (List<Contact>)Database.query(soqlQuery);

        // When multiple contacts are found, the system will always use the DNA record over all others.
        // When no DNA record is found, it will use the contact that was created first (oldest).
        Contact applicantContact = null;
        for (Contact contact : contacts) {
            if (contact.recordType.name == RecordTypeConstants.CONTACT_DNA) {
                applicantContact = contact;
                break;
            } else {
                applicantContact = contact;
            }
        }

        return applicantContact;
    }

    /**
     * Create a new non-DNA account for the applicant.
     */
    private static Account createNewAccount(AOApplicationRestRequest.Person applicant) {
        Id defaultAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeConstants.ACCOUNT_DEFAULT).getRecordTypeId();
        Account a = new Account();
        a.recordTypeId = defaultAccountRecordTypeId;
        if (!String.isBlank(applicant.person_number)) {
            a.name = 'P' + applicant.person_number;
        } else {
            a.name = (applicant.first_name != null ? applicant.first_name : '') + ' ' + (applicant.last_name != null ? applicant.last_name : '');
        }
        return a;
    }

    private static Contact createNewContact(AOApplicationRestRequest.Person applicant, Account a) {
        // Create a new non-DNA contact for the applicant.
        Id defaultContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DEFAULT).getRecordTypeId();
        Contact c = new Contact();
        c.recordTypeId = defaultContactRecordTypeId;
        c.accountId = a.id;
        c.personNumber__c = applicant.person_number;
        c.taxId__c = applicant.tax_id;
        c.firstName = (applicant.first_name != null ? applicant.first_name : '') + (applicant.middle_name != null ? ' ' + applicant.middle_name : '');
        c.lastName = applicant.last_name;
        c.email = applicant.email;
        c.phone = applicant.home_phone != null && applicant.home_phone.phone_number != null ? PhoneUtils.format(applicant.home_phone.phone_number) : null;
        c.mobilePhone = applicant.mobile_phone != null && applicant.mobile_phone.phone_number != null ? PhoneUtils.format(applicant.mobile_phone.phone_number) : null;
        c.businessPhone__c = applicant.work_phone != null && applicant.work_phone.phone_number != null ? PhoneUtils.format(applicant.work_phone.phone_number) : null;
        c.birthdate = AORestHelper.parseDateString(applicant.birth_date);
        if (applicant.identification != null) {
            c.identificationNumber__c = applicant.identification.id_number;
            c.identificationType__c = applicant.identification.type;
            c.identificationIssueState__c = applicant.identification.issuing_authority;
            c.identificationIssueDate__c = applicant.identification.issue_date != null ? AORestHelper.parseDateString(applicant.identification.issue_date) : null;
            c.identificationExpirationDate__c = applicant.identification.expire_date != null ? AORestHelper.parseDateString(applicant.identification.expire_date) : null;
        }
        c.leadSource = 'Online Account Opening';
        if (applicant.primary_address != null && applicant.primary_address.line_1 != null) {
            c.mailingStreet = applicant.primary_address.line_1 + (!String.isBlank(applicant.primary_address.line_2) ? '\n' + applicant.primary_address.line_2 : '');
            c.mailingCity = applicant.primary_address.city;
            c.mailingState = applicant.primary_address.state;
            c.mailingPostalCode = applicant.primary_address.postal_code;

            // Ensure the country code is an appropriate 3 character ISO code.
            String countryCode = applicant.primary_address.country;
            if (countryCode != null && countryCode.length() == 2) {
                countryCode = CountryUtils.getCountryByAlpha2(countryCode).code;
            }
            c.mailingCountry = countryCode;
        }
        if (applicant.credit_score != null && applicant.credit_score.score != null) {
            c.creditScore__c = applicant.credit_score.score;
            c.creditScoreDate__c = AORestHelper.parseDateString(applicant.credit_score.score_date);
        }
        return c;
    }

    private static void updateContact(AOApplicationRestRequest.Person applicant, Contact c) {
        if (!String.isBlank(applicant.tax_id)) {
            c.taxId__c = applicant.tax_id;
        }

        // Only allow the contact's person number to be changed if the contact value is blank.  This prevents an
        // undesirable change to the DNA record.
        if (String.isBlank(c.personNumber__c)) {
            c.personNumber__c = applicant.person_number;
        }
    }

    private static String getOpportunityName(AOApplicationRestRequest.Person applicant, AOApplicationRestRequest.FinancialProduct product) {
        String oppName = applicant.first_name + ' ' + applicant.last_name;
        if (isValidProduct(product)) {
            oppName += ' - ' + product.product_name;
        }
        return oppName;
    }

    private static Opportunity getApplicationOpportunity(String applicationId) {
        // Determine if there is an existing opportunity.  If there are multiple opportunities, it is
        // because a record was cloned.  As such, the SOQL query will use the oldest record as the one that was
        // automatically created by the Avoka form delivery process.
        List<Opportunity> opps = [
            SELECT id,
                closeDate,
                isClosed,
                isWon,
                ownerId,
                productMajorCode__c,
                recordTypeId,
                stageName
            FROM Opportunity
            WHERE applicationId__c = :applicationId
            ORDER BY createdDate ASC
        ];
        if (opps.size() > 0) {
            return opps[0];
        }

        return null;
    }

    private static Opportunity createNewOpportunity(
            AOApplicationInfo appInfo,
            Contact applicant,
            List<Contact> coApplicants,
            AOApplicationRestRequest.Person appPerson,
            AOApplicationRestRequest.FinancialProduct product)
    {
        Opportunity opp = new Opportunity();

        updateOpportunityFields(appInfo, opp, applicant, coApplicants, appPerson, product);
        insert opp;

        // Associate the contact(s) with the opportunity
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.opportunityId = opp.id;
        oppContactRole.contactId = applicant.id;
        oppContactRole.role = AOConstants.OPPORTUNITY_ROLE_PRIMARY_BORROWER;
        oppContactRole.isPrimary = true;
        oppContactRoles.add(oppContactRole);
        for (Contact c : coApplicants) {
            oppContactRole = new OpportunityContactRole();
            oppContactRole.opportunityId = opp.id;
            oppContactRole.contactId = c.id;
            oppContactRole.role = AOConstants.OPPORTUNITY_ROLE_JOINT;
            oppContactRole.isPrimary = false;
            oppContactRoles.add(oppContactRole);
        }
        insert oppContactRoles;

        return opp;
    }

    private static void updateOpportunity(
            AOApplicationInfo appInfo,
            Contact applicant,
            List<Contact> coApplicants,
            AOApplicationRestRequest.Person appPerson,
            AOApplicationRestRequest.FinancialProduct product,
            Opportunity opp)
    {
        try {
            updateOpportunityFields(appInfo, opp, applicant, coApplicants, appPerson, product);
            update opp;
        } catch (Exception e) {
            LogUtils.log(LoggingLevel.ERROR, 'AOApplicationDataController', e.getMessage() + ' : ' + e.getStackTraceString());
        }

        // Associate the co-applicants with the opportunity if they aren't already.
        Map<Id, OpportunityContactRole> coApplicantRoles = new Map<Id, OpportunityContactRole>();
        Set<Id> coApplicantIds = new Set<Id>();
        for (Contact c : coApplicants) {
            coApplicantIds.add(c.id);

            OpportunityContactRole r = new OpportunityContactRole();
            r.opportunityId = opp.id;
            r.contactId = c.id;
            r.role = AOConstants.OPPORTUNITY_ROLE_JOINT;
            r.isPrimary = false;
            coApplicantRoles.put(c.id, r);
        }
        if (coApplicantRoles.size() > 0) {
            // Remove any of the contact roles that already exist.
            List<OpportunityContactRole> contactRoles = [
                SELECT id,
                    contactId
                FROM OpportunityContactRole
                WHERE opportunityId = :opp.id AND contactId IN :coApplicantIds
            ];
            for (OpportunityContactRole r : contactRoles) {
                coApplicantRoles.remove(r.contactId);
            }

            // Insert contact roles.
            try {
                List<OpportunityContactRole> rolesToInsert = coApplicantRoles.values();
                insert rolesToInsert;
            } catch (Exception e) {
                LogUtils.log(LoggingLevel.ERROR, 'AOApplicationDataController', e.getMessage() + ' : ' + e.getStackTraceString());
            }
        }
    }

    private static Id getOpportunityRecordType(AOApplicationRestRequest.FinancialProduct product) {
        // Determine the record type of the opportunity.
        String recordTypeName = RecordTypeConstants.OPPORTUNITY_ONLINE_ACCOUNT_OPENING;
        // if (isValidProduct(product) && product.major_type == AOConstants.PRODUCT_MAJOR_TYPE_CRIF) {
        //     if (product.minor_type == AOConstants.PRODUCT_MINOR_TYPE_HELOC) {
        //         recordTypeName = RecordTypeConstants.OPPORTUNITY_HELOC;
        //     } else {
        //         recordTypeName = RecordTypeConstants.OPPORTUNITY_LOAN;
        //     }
        // }

        // // Retrieve the record type Id
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }

    private static void setOpportunityStage(AOApplicationInfo appInfo, Opportunity opp, Boolean setNew) {
        if (appInfo.appRequest.app_status == AOConstants.APP_STATUS_ABANDONED) {
            // When the application is abandoned, close the opportunity if it isn't already.
            if (!opp.isClosed) {
                opp.stageName = OpportunityConstants.STAGE_MEMBER_REJECTED;
                opp.lost_Reason__c = 'Abandoned';
                opp.closeDate = System.today();
            }
        } else {
            // If the application is complete and the opportunity is not already closed, do so.
            String appStatus = appInfo.appRequest.app_status;
            if (appStatus == AOConstants.APP_STATUS_COMPLETE && !opp.isClosed) {
                opp.stageName = OpportunityConstants.STAGE_COMPLETE;
                opp.closeDate = System.today();
            }

            // If the application is not complete and was previously closed, re-open the opportunity
            // since there likely was an error (e.g. fraud on joint application).
            if (appStatus != AOConstants.APP_STATUS_COMPLETE && opp.isClosed) {
                opp.stageName = IdUtils.isQueue(opp.ownerId) ? OpportunityConstants.STAGE_NEW : OpportunityConstants.STAGE_ASSIGNED;
                if (opp.closeDate <= System.today()) {
                    opp.closeDate = System.today().addDays(1);
                }
            }

            // If the application comes over in review set the opportunity Stage
            if (appStatus == AOConstants.APP_STATUS_IN_REVIEW && !opp.isClosed) {
                opp.aoReviewRequired__c = true;
                opp.stageName = OpportunityConstants.STAGE_UNDER_REVIEW;
            }

            // If the Application has an Error set it to the error stage.
            if (appStatus == AOConstants.APP_STATUS_ERROR && !opp.isClosed) {
                opp.AOSystem_Error__c = true;
                opp.stageName = OpportunityConstants.STAGE_UNDER_REVIEW;
            }
        }

        // Verify that the stage and close date are set.
        if (opp.stageName == null) {
            opp.stageName = OpportunityConstants.STAGE_NEW;
        }
        if (opp.closeDate == null) {
            opp.closeDate = System.today().addDays(1);
        }

        // Determine if there are any business defined processes that require review
        String appStatus = appInfo.appRequest.app_status;
        Boolean hasApplicationId = appInfo.loanApplicationIds != null && appInfo.loanApplicationIds.size() > 0;
        String eligibilityResponse = appInfo.appRequest.applicant.membership_eligibility;

        // To prevent issues for updating opportunities triggering close date validation, ensure the
        // close date isn't in the past.
        if (!opp.isClosed && (opp.closeDate == null || opp.closeDate < System.today())) {
            opp.closeDate = System.today();
        }
    }

    /**
     * Converts the list of errors into a single string for saving on the opportunity.
     */
    private static String getErrorString(AOApplicationInfo appinfo) {
        // Cycle through and create one, big, happy error.
        String errors = null;
        if (appInfo.errors.size() > 0) {
            errors = '';
            for (String err : appInfo.errors) {
                errors = errors + err + '\n';
            }

            // Logic for truncating our error messages
            if (errors.length() > ObjectUtils.MAX_TEXT_FIELD_LENGTH) {
                String truncatedMessage = '(TRUNCATED)';

                // We want to let the end user know that the message was
                // too long to fit in this field, so we need to substract
                // the length of the '(truncated)' message and subtract 1,
                // because it is a 0-based index.
                Integer endIndex = ObjectUtils.MAX_TEXT_FIELD_LENGTH - truncatedMessage.length() - 1;

                // Substring to the endIndex and concatonate the truncated message. Gosh, I wish we a StringBuilder class...
                errors = errors.substring(0, endIndex) + truncatedMessage;
            }
        }

        return errors;
    }

    private static Boolean isValidProduct(AOApplicationRestRequest.FinancialProduct product) {
        return product != null && !String.isBlank(product.product_name);
    }

    private static void updateOpportunityFields(
        AOApplicationInfo appInfo,
        Opportunity opp,
        Contact applicant,
        List<Contact> coApplicants,
        AOApplicationRestRequest.Person appPerson,
        AOApplicationRestRequest.FinancialProduct product)
    {
        // Set the common fields that apply to all opportunities.
        opp.name = getOpportunityName(appPerson, product);
        opp.recordTypeId = getOpportunityRecordType(product);
        opp.accountId = applicant.accountId;
        opp.applicationId__c = appInfo.appRequest.application_id;
        opp.aoError__c = getErrorString(appInfo);
        opp.aoFormName__c = appInfo.appRequest.form.name;
        opp.aoFormUrl__c = appInfo.appRequest.form.url;
        opp.aoFormPurpose__c = appInfo.appRequest.form.purpose == 'addrole' ? 'Add Role' : 'Open Account';
        opp.aoResponsibleParty__c = appInfo.isYouthApplication() && coApplicants.size() > 0 ? coApplicants[0].id : null;
        opp.avokaJob__c = appInfo.appRequest.form.job_reference_code;
        opp.avokaTrackingCode__c = appInfo.appRequest.form.tracking_code;
        opp.leadSource = 'Online Account Opening';

        // Identify an appropriate owner for the opportunity.  If this has a related application, use the owner of the
        // parent application.
        if (appInfo.appRequest.related_application_id != null) {
            Opportunity parentOpp = getApplicationOpportunity(appInfo.appRequest.related_application_id);
            if (parentOpp != null) {
                opp.ownerId = parentOpp.ownerId;
            }
        }
        if (opp.ownerId == null) {
            opp.ownerId = IdUtils.BATCH_USER_ID;
        }

        // Store the application info JSON for reports
        String json = getApplicationInfoJson(appInfo);
        opp.avokaApplicationInfoJSON__c = json;

        // All of the following fields will always be updated, but only if they are present in the
        // payload.  Some values are not present on the accountsandfunding step, but are present on
        // prior steps.
        if (String.isNotBlank(applicant.email)) {
            opp.email__c = applicant.email;
        }
        if (appInfo.appRequest.applicant != null && String.isNotBlank(appInfo.appRequest.applicant.membership_eligibility)) {
            opp.aoEligibilityResponse__c = appInfo.appRequest.applicant.membership_eligibility;
        }
        if (isValidProduct(product)) {
            opp.type = product.major_type == AOConstants.PRODUCT_MAJOR_TYPE_CRIF ? 'Loan' : 'Deposits';
            opp.product__c = product.product_name;
            opp.productMajorCode__c = product.major_type;
            opp.productMinorCode__c = product.minor_type;
        }
        if (appInfo.loanTotalAmount != null) {
            opp.amount = appInfo.loanTotalAmount;
            opp.product_amount__c = appInfo.loanTotalAmount;
        }
        if (appInfo.loanApplicationIds != null && appInfo.loanApplicationIds.size() > 0) {
            opp.app_id__c = appInfo.loanApplicationIds[0];
        }
        if (appPerson.credit_score != null && appPerson.credit_score.score != null) {
            opp.credit_score__c = appPerson.credit_score.score;
        }
        AOApplicationRestRequest.Promotion promotion =
            appInfo.appRequest.promotions != null && appInfo.appRequest.promotions.size() > 0 ? appInfo.appRequest.promotions[0] : null;
        if (promotion != null && promotion.code != null) {
            opp.promotionCode__c = promotion.code;
        }

        // Determine what the stage of the opportunity and associated settings should be.
        setOpportunityStage(appInfo, opp, false);
    }

}