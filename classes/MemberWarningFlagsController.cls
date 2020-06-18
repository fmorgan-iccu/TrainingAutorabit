public class MemberWarningFlagsController {

    @TestVisible
    private static INetworkFactory networkFactory;

    private static Set<String> ACCEPTABLE_CODES = new Set<String> {
        'BADD', // Bad Address
        'BRST', // Branch Stop
        'CHOF', // Charged Off Account
        'DECM', // Deceased Member
        'FRDA', // Fraud
        'LEVY', // Garnishment / Tax Levy
        'NEGM', // Negative Member
        'NEW',  // New Account
        'NOTE', // See Account Note *only until the branches have access to the CRM, branches will place notes in this field and I would only know to look for it with this flag
        'PHON', // Update Phone Number
        'PMTO', // Payments Only
        'PNOT', // See Person Note *only until the branches have access to the CRM, branches will place notes in this field and I would only know to look for it with this flag
        'TTL',  // Total Lockout
        'SAST'  // Stop Assist Member Assistance
    };

    @AuraEnabled
    public static Map<String, Object> fetchMemberWarningFlags(Id contactId) {
        Map<String, Object> response = new Map<String, Object>();

        if (contactId == null) {
            response.put('error', '`contactId` was null.');
            return response;
        }

        try {
            List<IWarningFlag> flags = getMemberWarningFlags(contactId);
            List<Map<String, Object>> responseFlags = mapFlags(flags);
            response.put('warningFlags', responseFlags);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
        } catch (Exception e) {
            response.put('error', 'There was an unexpected error. ' + e);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> fetchOrganizationWarningFlags(Id accountId) {
        Map<String, Object> response = new Map<String, Object>();

        if (accountId == null) {
            response.put('error', '`accountId` was null.');
            return response;
        }

        try {
            List<IWarningFlag> flags = getOrganizationWarningFlags(accountId);
            List<Map<String, Object>> responseFlags = mapFlags(flags);
            response.put('warningFlags', responseFlags);
        } catch (UnauthenticatedException e) {
            response.put('error', 'Please log into DNA.');
        } catch (Exception e) {
            response.put('error', 'There was an unexpected error. ' + e);
        }

        return response;
    }

    public static List<IWarningFlag> getMemberWarningFlags(Id contactId){
        if (contactId == null) {
            throw new IllegalArgumentException('The `contactId` can not be null.');
        }

        if (MemberWarningFlagsController.networkFactory == null) {
            MemberWarningFlagsController.networkFactory = new ConcreteNetworkProvider();
        }

        SFPerson person = SFPerson.getInstance(contactId);

        IPersonDataProvider personProvider = MemberWarningFlagsController.networkFactory.getPersonDataProvider();
        IPersonAccountDataProvider accountProvider = MemberWarningFlagsController.networkFactory.getPersonAccountDataProvider();

        List<IWarningFlag> personflags = personProvider.getPersonWarningFlags(person.getPersonNumber());
        List<IWarningFlag> accountFlags = accountProvider.getAllWarningFlags(person);

        List<IWarningFlag> flags = new List<IWarningFlag>();
        flags.addAll(personFlags);
        flags.addAll(accountFlags);

        return flags;
    }

    public static List<IWarningFlag> getOrganizationWarningFlags(Id accountId){
        if (accountId == null) {
            throw new IllegalArgumentException('The `accountId` can not be null.');
        }

        if (MemberWarningFlagsController.networkFactory == null) {
            MemberWarningFlagsController.networkFactory = new ConcreteNetworkProvider();
        }

        IOrganization org = SFOrganization.getInstance(accountId);

        IOrganizationDataProvider warningProvider = MemberWarningFlagsController.networkFactory.getOrgWarningDataProvider();
        IPersonAccountDataProvider accountProvider = MemberWarningFlagsController.networkFactory.getPersonAccountDataProvider();

        List<IWarningFlag> orgflags = warningProvider.getWarningFlags(org.getOrgNumber());
        List<IWarningFlag> accountFlags = accountProvider.getAllWarningFlags(org);

        List<IWarningFlag> flags = new List<IWarningFlag>();
        flags.addAll(orgflags);
        flags.addAll(accountFlags);

        return flags;
    }

    private static List<Map<String, Object>> mapFlags(List<IWarningFlag> flags) {
        List<Map<String, Object>> responseFlags = new List<Map<String, Object>>();
        for (IWarningFlag flag : flags) {
            if (!ACCEPTABLE_CODES.contains(flag.getFlagCode())) { // Only want to include flags that are in the set above.
                continue;
            }

            Map<String, Object> responseFlag = new Map<String, Object>();
            responseFlag.put('effectiveDate', flag.getEffectiveDate());
            responseFlag.put('flagCode', flag.getFlagCode());
            responseFlag.put('flagCodeDescription', flag.getFlagCodeDescription());
            responseFlag.put('inactiveDate', flag.getInactiveDate());
            responseFlag.put('noteClassCode', flag.getNoteClassCode());
            responseFlag.put('noteClassCodeDescription', flag.getNoteClassCodeDescription());
            responseFlag.put('noteSubClassCode', flag.getNoteSubClassCode());
            responseFlag.put('noteSubClassCodeDescription', flag.getNoteSubClassCodeDescription());
            responseFlag.put('noteText', flag.getNoteText());

            responseFlags.add(responseFlag);
        }
        return responseFlags;
    }

}