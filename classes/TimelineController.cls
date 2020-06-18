public with sharing class TimelineController {

    // Limit the amount of data returned to the front end.
    private static final Integer MAX_TIMELINE_DAYS = 180;

    private static Boolean canViewCases = null;
    private static Boolean canViewOpportunities = null;

    private static Map<String, Object> getAccountTimelineData(Id accountId, Integer pageNum, Integer pageSize) {
        Map<String, Object> response = new Map<String, Object>();

        // Query the objects that should be included in the timeline.
        List<Case> openCases = getOpenCasesByAccount(accountId);
        List<Case> closedCases = getClosedCasesByAccount(accountId);
        List<Opportunity> openOpportunities = getOpenOpportunitiesByAccount(accountId);
        List<Opportunity> closedOpportunities = getClosedOpportunitiesByAccount(accountId);

        response = getTimelineData(openCases, closedCases, openOpportunities, closedOpportunities, pageNum, pageSize);

        return response;
    }

    private static Map<String, Object> getContactTimelineData(Id contactId, Integer pageNum, Integer pageSize) {
        Map<String, Object> response = new Map<String, Object>();

        // Query the objects that should be included in the timeline.
        List<Case> openCases = getOpenCasesByContact(contactId);
        List<Case> closedCases = getClosedCasesByContact(contactId);
        List<Opportunity> openOpportunities = getOpenOpportunitiesByContact(contactId);
        List<Opportunity> closedOpportunities = getClosedOpportunitiesByContact(contactId);

        response = getTimelineData(openCases, closedCases, openOpportunities, closedOpportunities, pageNum, pageSize);

        return response;
    }

    private static List<Case> getClosedCasesByAccount(Id accountId) {
        DateTime cutoffDate = System.now().addDays(-MAX_TIMELINE_DAYS);
        List<Case> cases = [
            SELECT Id,
                CaseNumber,
                CreatedDate,
                ClosedDate,
                OwnerId,
                Status,
                Subject,
                MCCClass__c,
                MCCSubclass__c,
                MemberSentiment__c,
                Origin,
                Owner.Name,
                ProductName__c,
                RecordTypeId
            FROM Case
            WHERE AccountId = :accountId AND
                IsClosed = true AND
                ClosedDate >= :cutoffDate
            ORDER BY CreatedDate ASC
        ];

        return cases;
    }

    private static List<Case> getClosedCasesByContact(Id contactId) {
        DateTime cutoffDate = System.now().addDays(-MAX_TIMELINE_DAYS);
        List<Case> cases = [
            SELECT Id,
                CaseNumber,
                CreatedDate,
                ClosedDate,
                OwnerId,
                Status,
                Subject,
                MCCClass__c,
                MCCSubclass__c,
                MemberSentiment__c,
                Origin,
                Owner.Name,
                ProductName__c,
                RecordTypeId
            FROM Case
            WHERE ContactId = :contactId AND
                IsClosed = true AND
                ClosedDate >= :cutoffDate
            ORDER BY CreatedDate ASC
        ];

        return cases;
    }

    private static List<Opportunity> getClosedOpportunitiesByAccount(Id accountId) {
        Date cutoffDate = System.today().addDays(-MAX_TIMELINE_DAYS);
        List<Opportunity> opportunities = [
            SELECT Id,
                Amount,
               	App_ID__c,
                CreatedDate,
                CloseDate,
                Name,
                Owner.Name,
                Owner.Id,
                RecordTypeId,
                StageName
            FROM Opportunity
            WHERE AccountId = :accountId AND
                IsClosed = true AND
                CloseDate >= :cutoffDate
            ORDER BY CreatedDate ASC
        ];

        return opportunities;
    }

    private static List<Opportunity> getClosedOpportunitiesByContact(Id contactId) {
        Date cutoffDate = System.today().addDays(-MAX_TIMELINE_DAYS);
        List<Opportunity> opportunities = [
            SELECT Id,
                Amount,
                App_ID__c,
                CreatedDate,
                CloseDate,
                Name,
                Owner.Name,
                Owner.Id,
                RecordTypeId,
                StageName
            FROM Opportunity
            WHERE IsClosed = true AND
                CloseDate >= :cutoffDate AND
                Id IN (
                    SELECT OpportunityId
                    FROM OpportunityContactRole
                    WHERE ContactId = :contactId
                )
            ORDER BY CreatedDate ASC
        ];

        return opportunities;
    }

    private static List<Case> getOpenCasesByAccount(Id accountId) {
        List<Case> cases = [
            SELECT Id,
                CaseNumber,
                CreatedDate,
                ClosedDate,
                OwnerId,
                Status,
                Subject,
                MCCClass__c,
                MCCSubclass__c,
                MemberSentiment__c,
                Origin,
                Owner.Name,
                ProductName__c,
                RecordTypeId
            FROM Case
            WHERE AccountId = :accountId AND
                IsClosed = false
            ORDER BY CreatedDate ASC
        ];

        return cases;
    }

    private static List<Case> getOpenCasesByContact(Id contactId) {
        List<Case> cases = [
            SELECT Id,
                CaseNumber,
                CreatedDate,
                ClosedDate,
                OwnerId,
                Status,
                Subject,
                MCCClass__c,
                MCCSubclass__c,
                MemberSentiment__c,
                Origin,
                Owner.Name,
                ProductName__c,
                RecordTypeId
            FROM Case
            WHERE ContactId = :contactId AND
                IsClosed = false
            ORDER BY CreatedDate ASC
        ];

        return cases;
    }

    private static List<Opportunity> getOpenOpportunitiesByAccount(Id accountId) {
        List<Opportunity> opportunities = [
            SELECT Id,
                Amount,
                App_ID__c,
                CreatedDate,
                CloseDate,
                Name,
                Owner.Name,
                Owner.Id,
                RecordTypeId,
                StageName
            FROM Opportunity
            WHERE AccountId = :accountId AND
                IsClosed = false
            ORDER BY CreatedDate ASC
        ];

        return opportunities;
    }

    private static List<Opportunity> getOpenOpportunitiesByContact(Id contactId) {
        List<Opportunity> opportunities = [
            SELECT Id,
                Amount,
                App_ID__c,
                CreatedDate,
                CloseDate,
                Name,
                Owner.Name,
                Owner.Id,
                RecordTypeId,
                StageName
            FROM Opportunity
            WHERE IsClosed = false AND
                Id IN (
                    SELECT OpportunityId
                    FROM OpportunityContactRole
                    WHERE ContactId = :contactId
                )
            ORDER BY CreatedDate ASC
        ];

        return opportunities;
    }

    @AuraEnabled
    public static Map<String, Object> getTimeline(Id recordId, Integer pageNum, Integer pageSize) {
        Map<String, Object> response = new Map<String, Object>();

        if (recordId == null) {
            response.put('error', 'The `recordId` cannot be null.');
            return response;
        }

        // Get the object specific timeline.
        String recordType = '' + recordId.getSobjectType();
        if (recordType == 'Account') {
            response = getAccountTimelineData(recordId, pageNum, pageSize);
        } else if (recordType == 'Contact') {
            response = getContactTimelineData(recordId, pageNum, pageSize);
        } else {
            response.put('error', 'The record type, `' + recordType + '`, does not have a timeline.');
        }

        // Determine what record types the user can create.
        Boolean canCreateCase = Schema.SObjectType.Case.isCreateable();
        Boolean canCreateOpportunity = Schema.SObjectType.Opportunity.isCreateable();
        response.put('canCreateCase', canCreateCase);
        response.put('canCreateOpportunity', canCreateOpportunity);

        return response;
    }

    private static Map<String, Object> getTimelineData(
        List<Case> openCases,
        List<Case> closedCases,
        List<Opportunity> openOpportunities,
        List<Opportunity> closedOpportunities,
        Integer pageNum,
        Integer pageSize)
    {
        Map<String, Object> response = new Map<String, Object>();

        // Sort the open timeline entries from newest to oldest.  This is done seperately from the closed entries to
        // ensure the open entries are always first.
        List<sObject> openEntries = new List<sObject>();
        openEntries.addAll(openCases);
        openEntries.addAll(openOpportunities);
        List<sObject> sortedOpenEntries = SortUtils.sortListByDate(openEntries, Metadata.SortOrder.DESC_X);

        // Add the sorted open entries in the response object.
        List<Map<String, Object>> openEntriesList = new List<Map<String, Object>>();
        for (sObject e : sortedOpenEntries) {
            if (e instanceof Case) {
                Map<String, Object> c = mapCaseToMap((Case)e);
                openEntriesList.add(c);
            } else if (e instanceof Opportunity) {
                Map<String, Object> o = mapOpportunityToMap((Opportunity)e);
                openEntriesList.add(o);
            }
        }
        response.put('openEntries', openEntriesList);

        // Sort the closed timeline entries from newest to oldest.
        List<sObject> closedEntries = new List<sObject>();
        closedEntries.addAll(closedCases);
        closedEntries.addAll(closedOpportunities);
        List<sObject> sortedClosedEntries = SortUtils.sortListByDate(closedEntries, Metadata.SortOrder.DESC_X);

        // Determine how many pages there are and add the page information to the response.  If no paging information
        // was included in the request, return a single page.
        Integer totalRecords = closedCases.size() + closedOpportunities.size();
        Integer pageCount = pageSize != null ? totalRecords / pageSize : 1;
        Integer pageNumber = pageNum != null ? pageNum : 1;
        response.put('pageCount', pageCount);
        response.put('pageNumber', pageNumber);

        // Determine which entries are on the requested "page".
        List<Map<String, Object>> closedEntriesList = new List<Map<String, Object>>();
        Integer startIndex = pageSize != null ? (pageNumber - 1) * pageSize : 0;
        Integer endIndex = pageSize != null ? (pageNumber * pageSize) - 1 : totalRecords - 1;
        for (Integer i = startIndex; i <= endIndex; i++) {
            sObject e = sortedClosedEntries[i];
            if (e instanceof Case) {
                Map<String, Object> c = mapCaseToMap((Case)e);
                closedEntriesList.add(c);
            } else if (e instanceof Opportunity) {
                Map<String, Object> o = mapOpportunityToMap((Opportunity)e);
                closedEntriesList.add(o);
            }
        }
        response.put('closedEntries', closedEntriesList);

        return response;
    }

    private static Map<String, Object> mapCaseToMap(Case c) {
        Map<String, Object> caseMap = new Map<String, Object>();

        // Determine if the user normally has visibility to this object.  If they don't, indicate that they can't use
        // a link to view the record.
        if (TimelineController.canViewCases == null) {
            TimelineController.canViewCases = Case.sObjectType.getDescribe().isAccessible();
        }

        // Determine the case subject/description and record type name.
        String description = 'Unclassified';
        String recordTypeName = null;
        String subject = c.Subject;

        // Account opening
        Id accountOpeningRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_ONLINE_ACCOUNT_OPENING).getRecordTypeId();
        if (c.RecordTypeId == accountOpeningRecordTypeId) {
            if (String.isBlank(c.Subject)) {
                subject = 'Account Opening Case';
            }
            if (String.isNotBlank(c.ProductName__c)) {
                description = c.ProductName__c;
            }
            recordTypeName = RecordTypeConstants.CASE_ONLINE_ACCOUNT_OPENING;
        }

        // Complaint case
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_COMPLAINT).getRecordTypeId();
        if (c.RecordTypeId == complaintRecordTypeId) {
            if (String.isBlank(c.Subject)) {
                subject = 'Complaint Case';
            }
            if (String.isNotBlank(c.MCCClass__c)) {
                description = c.MCCClass__c;
                if (String.isNotBlank(c.MCCSubClass__c)) {
                    description = description + ' - ' + c.MCCSubclass__c;
                }
            }
            recordTypeName = RecordTypeConstants.CASE_COMPLAINT;
        }

        // Member support case
        Id memberSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();
        if (c.RecordTypeId == memberSupportRecordTypeId) {
            if (String.isBlank(c.Subject)) {
                subject = 'MCC Case';
            }
            if (String.isNotBlank(c.MCCClass__c)) {
                description = c.MCCClass__c;
                if (String.isNotBlank(c.MCCSubClass__c)) {
                    description = description + ' - ' + c.MCCSubclass__c;
                }
            }
            recordTypeName = RecordTypeConstants.CASE_MEMBER_SUPPORT;
        }

        // Business support case
        Id businessSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_BUSINESS_SUPPORT).getRecordTypeId();
        if (c.RecordTypeId == businessSupportRecordTypeId) {
            if (String.isBlank(c.Subject)) {
                subject = 'Business Case';
            }
            if (String.isNotBlank(c.MCCClass__c)) {
                description = c.MCCClass__c;
                if (String.isNotBlank(c.MCCSubClass__c)) {
                    description = description + ' - ' + c.MCCSubclass__c;
                }
            }
            recordTypeName = RecordTypeConstants.CASE_BUSINESS_SUPPORT;
        }

        // If the case record type is not recognized, ensure a subject is set.
        if (String.isBlank(description)) {
            subject = c.Subject;
        }

        // Format the date of the activity for display and determine the label.
        Datetime d = c.ClosedDate != null ? c.ClosedDate : c.CreatedDate;
        String formattedDate = DateUtils.format(d.date());
        String dateLabel = c.ClosedDate != null ? 'Closed On' : 'Open Since';

        caseMap.put('id', c.Id);
        caseMap.put('canViewRecord', TimelineController.canViewCases);
        caseMap.put('caseNumber', c.CaseNumber);
        caseMap.put('class', c.MCCClass__c);
        caseMap.put('closeDate', c.ClosedDate);
        caseMap.put('createdDate', c.CreatedDate);
        caseMap.put('date', formattedDate);
        caseMap.put('dateLabel', dateLabel);
        caseMap.put('description', description);
        caseMap.put('memberSentiment', c.MemberSentiment__c);
        caseMap.put('caseOrigin', c.Origin);
        caseMap.put('ownerId', c.OwnerId);
        caseMap.put('ownerName', c.Owner.Name);
        caseMap.put('recordTypeId', c.RecordTypeId);
        caseMap.put('recordTypeName', recordTypeName);
        caseMap.put('status', c.Status);
        caseMap.put('subClass', c.MCCSubclass__c);
        caseMap.put('subject', subject);
        caseMap.put('type', 'case');

        return caseMap;
    }

    private static Map<String, Object> mapOpportunityToMap(Opportunity o) {
        Map<String, Object> oppMap = new Map<String, Object>();

        // Determine if the user normally has visibility to this object.  If they don't, indicate that they can't use
        // a link to view the record.
        if (TimelineController.canViewOpportunities == null) {
            TimelineController.canViewOpportunities = Opportunity.sObjectType.getDescribe().isAccessible();
        }

        // Assign Record Type Names
        String recordTypeName = null;
        //TODO: deposit product does not work
        Id depositRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT).getRecordTypeId();
        if (o.RecordTypeId == depositRecordTypeId) {
            recordTypeName = RecordTypeConstants.OPPORTUNITY_DEPOSIT_PRODUCT;
        }
        Id loanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_LOAN).getRecordTypeId();
        if (o.RecordTypeId == loanRecordTypeId) {
            recordTypeName = RecordTypeConstants.OPPORTUNITY_LOAN;
        }
        Id helocRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_HELOC).getRecordTypeId();
        if (o.RecordTypeId == helocRecordTypeId) {
            recordTypeName = RecordTypeConstants.OPPORTUNITY_HELOC;
        }
        Id prospectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_PROSPECT).getRecordTypeId();
        if (o.RecordTypeId == prospectRecordTypeId) {
            recordTypeName = RecordTypeConstants.OPPORTUNITY_PROSPECT;
        }
        Id oaoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeConstants.OPPORTUNITY_ONLINE_ACCOUNT_OPENING).getRecordTypeId();
        if (o.RecordTypeId == oaoRecordTypeId) {
            recordTypeName = RecordTypeConstants.OPPORTUNITY_ONLINE_ACCOUNT_OPENING;
        }

        // Format the date of the activity for display and identify the label.
        Datetime d = o.CloseDate != null ? o.CloseDate : o.CreatedDate;
        String formattedDate = DateUtils.format(d.date());
        String dateLabel = o.CloseDate != null ? 'Closed On' : 'Open Since';

        oppMap.put('id', o.Id);
        oppMap.put('amount', o.Amount);
        oppMap.put('applicationId', o.App_ID__c);
        oppMap.put('canViewRecord', TimelineController.canViewOpportunities);
        oppMap.put('closeDate', o.CloseDate);
        oppMap.put('createdDate', o.CreatedDate);
        oppMap.put('date', formattedDate);
        oppMap.put('dateLabel', dateLabel);
        oppMap.put('name', o.Name);
        oppMap.put('ownerId', o.Owner.Id);
        oppMap.put('ownerName', o.Owner.Name);
        oppMap.put('recordTypeId', o.RecordTypeId);
        oppMap.put('recordTypeName', recordTypeName);
        oppMap.put('stageName', o.StageName);
        oppMap.put('type', 'opportunity');

        return oppMap;
    }

}