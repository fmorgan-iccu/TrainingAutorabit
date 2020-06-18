public class MemberInsightsController {

    @AuraEnabled
    public static Map<String, Object> fetchInsights(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();

        if (recordId == null) {
            response.put('error', 'The `recordId` cannot be null.');
            return response;
        }

        String recordType = '' + recordId.getSobjectType();
        if (recordType == 'Account') {
            response = getAccountInsights(recordId);
        } else if (recordType == 'Contact') {
            response = getContactInsights(recordId);
        } else {
            response.put('error', 'The record type, `' + recordType + '`, does not have insights.');
        }

        return response;
    }

    private static Map<String, Object> getAccountInsights(Id accountId) {
        Map<String, Object> response = new Map<String, Object>();
        List<Map<String, Object>> financialAccountInsights = new List<Map<String, Object>>();
        List<Map<String, Object>> generalInsights = new List<Map<String, Object>>();

        // Determine if the account is an organization in the core system and attempt to retrieve warning and account
        // flags from it.
        Account a = SFOrganization.getInstance(accountId).getAccount();
        if (String.isNotBlank(a.OrganizationNumber__c)) {
            try {
                // Get the warning flags for the contact/person insights.
                Datetime now = System.now();
                Set<String> warningDupeCheck = new Set<String>();
                List<IWarningFlag> warningFlags = MemberWarningFlagsController.getOrganizationWarningFlags(accountId);
                for (IWarningFlag warningFlag : warningFlags) {
                    // Verify that the warning flag is not duplicated and is active.
                    Datetime inactiveDate = warningFlag.getInactiveDate();
                    Boolean isActive = warningFlag.getEffectiveDate() <= now && (inactiveDate == null || now < inactiveDate);
                    Boolean isDuplicate = warningDupeCheck.contains(warningFlag.getNoteText());

                    // Track the active/unique financial account warning flags.
                    if (isActive && !isDuplicate) {
                        Map<String, Object> warningInsight = getInsightMap(warningFlag);
                        if (warningInsight != null) {
                            financialAccountInsights.add(warningInsight);
                            warningDupeCheck.add(warningFlag.getNoteText());
                        }
                    }
                }

                // Get the overdrawn and past due account insights.
                List<IAccount> accounts = MemberAccountsController.getOrganizationAccounts(accountId);
                List<Map<String, Object>> financialInsights = getFinancialAccountInsights(accounts);
                generalInsights.addAll(financialInsights);
            } catch (UnauthenticatedException e) {
                response.put('error', e.getMessage());
            }
        }

        // Get the private client officer insight.
        List<Map<String, Object>> ownerInsights = getAccountOwnerInsights(accountId);
        generalInsights.addAll(ownerInsights);

        // Get the open case insight.
        List<Map<String, Object>> caseInsights = getAccountOpenCases(accountId);
        generalInsights.addAll(caseInsights);

        // Finally place the account/general insights in the response.
        response.put('financialAccountInsights', financialAccountInsights);
        response.put('generalInsights', generalInsights);

        return response;
    }

    private static List<Map<String, Object>> getAccountOpenCases(Id accountId) {
        List<Map<String, Object>> caseInsights = new List<Map<String, Object>>();

        // Create an insight for the open cases.
        List<Case> openCases = MemberCasesController.getOpenAccountCases(accountId);
        if (openCases.size() > 0) {
            Map<String, Object> openCaseInsightMap = getInsightMap('blue', null, null, 'fa-suitcase', String.valueOf(openCases.size()), null, 'open_cases', 'Open Cases');
            caseInsights.add(openCaseInsightMap);
        }

        return caseInsights;
    }

    private static List<Map<String, Object>> getAccountOwnerInsights(Id accountId) {
        List<Map<String, Object>> ownerInsights = new List<Map<String, Object>>();

        List<AccountTeamMember> teamMembers = [
            SELECT Id,
                TeamMemberRole,
                User.Name,
                UserId
            FROM AccountTeamMember
            WHERE AccountId = :accountId
        ];
        for (AccountTeamMember teamMember : teamMembers) {
            Map<String, Object> teamMemberInsight =
                getInsightMap('green', null, null, 'fa-user-tie', teamMember.User.Name, null, teamMember.Id, teamMember.TeamMemberRole);
            ownerInsights.add(teamMemberInsight);
        }

        return ownerInsights;
    }

    private static List<Map<String, Object>> getContactOpenCases(Id contactId) {
        List<Map<String, Object>> caseInsights = new List<Map<String, Object>>();

        // Create an insight for the open cases.
        List<Case> openCases = MemberCasesController.getOpenMemberCases(contactId);
        if (openCases.size() > 0) {
            Map<String, Object> openCaseInsightMap = getInsightMap('blue', null, null, 'fa-suitcase', String.valueOf(openCases.size()), null, 'open_cases', 'Open Cases');
            caseInsights.add(openCaseInsightMap);
        }

        return caseInsights;
    }

    private static List<Map<String, Object>> getContactCustomInsights(Id contactId) {
        List<Map<String, Object>> customInsights = new List<Map<String, Object>>();
        List<Map<String, Object>> insights = CustomInsightController.getMemberInsights(contactId);

        for (Map<String, Object> insight : insights) {
            String extendedDetail = (String)insight.get('extraDetails');
            Id insightId = (Id)insight.get('id');
            String title = (String)insight.get('name');
            String icon = 'fa-' + (String)insight.get('icon');
            String color = (String)insight.get('color');

            Map<String, Object> customInsightMap = getInsightMap(color, null, extendedDetail, icon, null, insightId, insightId, title);
            customInsights.add(customInsightMap);
        }

        return customInsights;
    }

    private static List<Map<String, Object>> getContactOwnerInsights(Id contactId) {
        List<Map<String, Object>> ownerInsights = new List<Map<String, Object>>();

        List<Contact> contacts = [
            SELECT Id,
                Owner.Name,
                PrivateClient__c
            FROM Contact
            WHERE Id = :contactId
        ];
        if (contacts.size() > 0) {
            Contact c = contacts[0];
            if (c.PrivateClient__c) {
                Map<String, Object> privateClientOwnerInsight =
                    getInsightMap('green', null, null, 'fa-user-tie', c.Owner.Name, null, 'private_client_owner', 'Private Client Officer');
                ownerInsights.add(privateClientOwnerInsight);
            }
        }

        return ownerInsights;
    }

    public static Map<String, Object> getContactInsights(Id contactId) {
        Map<String, Object> response = new Map<String, Object>();
        List<Map<String, Object>> financialAccountInsights = new List<Map<String, Object>>();
        List<Map<String, Object>> generalInsights = new List<Map<String, Object>>();

        // Determine if the contact is a member in the core system and attempt to retrieve warning and account flags
        // from it.
        Contact c = SFPerson.getInstance(contactId).getContact();
        if (String.isNotBlank(c.PersonNumber__c)) {
            try {
                // Get the warning flags for the contact/person insights.
                Datetime now = System.now();
                Set<String> warningDupeCheck = new Set<String>();
                List<IWarningFlag> warningFlags = MemberWarningFlagsController.getMemberWarningFlags(contactId);
                for (IWarningFlag warningFlag : warningFlags) {
                    // Verify that the warning flag is not duplicated and is active.
                    Datetime inactiveDate = warningFlag.getInactiveDate();
                    Boolean isActive = warningFlag.getEffectiveDate() <= now && (inactiveDate == null || now < inactiveDate);
                    Boolean isDuplicate = warningDupeCheck.contains(warningFlag.getNoteText());

                    // Track the active/unique financial account warning flags.
                    if (isActive && !isDuplicate) {
                        Map<String, Object> warningInsight = getInsightMap(warningFlag);
                        if (warningInsight != null) {
                            financialAccountInsights.add(warningInsight);
                            warningDupeCheck.add(warningFlag.getNoteText());
                        }
                    }
                }

                // Get the overdrawn and past due account insights.
                List<IAccount> accounts = MemberAccountsController.getMemberAccounts(contactId);
                List<Map<String, Object>> financialInsights = getFinancialAccountInsights(accounts);
                generalInsights.addAll(financialInsights);
            } catch (UnauthenticatedException e) {
                response.put('error', e.getMessage());
            }
        }

        // Get the private client officer insight.
        List<Map<String, Object>> ownerInsights = getContactOwnerInsights(contactId);
        generalInsights.addAll(ownerInsights);

        // Get the open case insight.
        List<Map<String, Object>> caseInsights = getAccountOpenCases(contactId);
        generalInsights.addAll(caseInsights);

        // Get the custom insights.
        List<Map<String, Object>> customInsights = getContactCustomInsights(contactId);
        generalInsights.addAll(customInsights);

        // Finally place the account/general insights in the response.
        response.put('financialAccountInsights', financialAccountInsights);
        response.put('generalInsights', generalInsights);

        return response;
    }

    private static List<Map<String, Object>> getFinancialAccountInsights(List<IAccount> accounts) {
        List<Map<String, Object>> financialAccountInsights = new List<Map<String, Object>>();

        boolean hasOverdrawnAccount = false;
        DateTime oldestPastDueDate = null;
        boolean hasPastDueAccount = false;
        double minBalance = (double)0.0;

        for (IAccount account : accounts) {
            // Checking for overdrawn account
            double currentBalance = account.getAvailableBalance();
            if (currentBalance < minBalance) {
                hasOverdrawnAccount = true;
            }

            // Checking for past due loan
            DateTime nextPaymentDate = account.getNextPaymentDate();
            if (nextPaymentDate == null) { // No need to proceed; no payment date
                continue;
            }

            DateTime now = System.now();
            if (now < nextPaymentDate) { // No need to proceed; not past due
                continue;
            }

            // OK, this account is past due.
            hasPastDueAccount = true;
            if (oldestPastDueDate != null) { // Uh-oh, they're past due on more than one account...
                // Want the oldest of the past due loans...
                if (nextPaymentDate < oldestPastDueDate) {
                    oldestPastDueDate = nextPaymentDate;
                } else {
                    // skip assigning it, we already have the oldest past due date...
                }
            } else  {
                oldestPastDueDate = nextPaymentDate;
            }
        }

        if (hasOverdrawnAccount) {
            Map<String, Object> overdrawnInsightMap = getInsightMap('deepRed', null, null, 'fa-exclamation', null, null, 'overdrawn_member', 'Overdrawn Member');
            financialAccountInsights.add(overdrawnInsightMap);
        }

        if (hasPastDueAccount) {
            Date today = Date.today();
            Integer daysPastDue = oldestPastDueDate.date().daysBetween(today);
            String pastDueMessage = daysPastDue + ' days ago';
            Map<String, Object> pastDueInsightMap = getInsightMap('deepRed', null, null, 'fa-exclamation', pastDueMessage, null, 'pastdue_account', 'Loans Past Due');
            financialAccountInsights.add(pastDueInsightMap);
        }

        return financialAccountInsights;
    }

    private static Map<String, Object> getInsightMap(IWarningFlag flag) {
        Datetime now = System.now();
        if (now >= flag.getEffectiveDate() && now < flag.getInactiveDate()) {
            String key = flag.getFlagCode();
            String title = flag.getFlagCodeDescription();
            return getInsightMap('red', null, null, 'fa-exclamation', null, null, key, title);
        }

        return null;
    }

    /**
     * Creates a standard map of insight values.  Example:
     *
     * {
     *      color: 'green',
     *      details: null,
     *      extendedDetail: null,
     *      icon: 'bell',
     *      info: null,
     *      insightId: null,
     *      isFontAwesome: false,
     *      key: '12903',
     *      title: 'Open Cases'
     *  }
     */
    private static Map<String, Object> getInsightMap(
        String color,
        String details,
        String extendedDetail,
        String icon,
        String info,
        Id insightId,
        String key,
        String title)
    {
        Map<String, Object> insightMap = new Map<String, Object> {
            'color' => color,
            'details' => details,
            'extendedDetail' => extendedDetail,
            'icon' => icon,
            'info' => info,
            'insightId' => insightId,
            'key' => key,
            'title' => title
        };
        return insightMap;
    }

}