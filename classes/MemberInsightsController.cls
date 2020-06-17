public class MemberInsightsController {
    @AuraEnabled
    public static Contact getContact(String contactId) {
        Contact contact = ContactController.getContact(contactId);
        return contact;
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchCaseInsights(String contactId) {
        List<Case> openCases = MemberCasesController.getOpenMemberCases(contactId);
        List<Case> closedCases = MemberCasesController.getClosedMemberCases(contactId);

        Map<String, List<Case>> cases = new Map<String, List<Case>>();
        cases.put('open', openCases);
        cases.put('closed', closedCases);

        return cases;
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchAccountInsights(String contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', 'Missing contactID.');
            return response;
        }

        boolean hasOverdrawnAccount = false;
        DateTime oldestPastDueDate = null;
        boolean hasPastDueAccount = false;
        double minBalance = (double)0.0;

        List<IAccount> accounts = MemberAccountsController.getMemberAccounts(contactId);
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

        response.put('oldestPastDueDate', oldestPastDueDate);
        response.put('hasOverdrawnAccount', hasOverdrawnAccount);
        response.put('hasPastDueAccount', hasPastDueAccount);

        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchWarningFlags(String contactId) {
        return MemberWarningFlagsController.fetchMemberWarningFlags(contactId);
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> fetchMemberInsights(String contactId) {
        return CustomInsightController.getMemberInsights(contactId);
    }
}