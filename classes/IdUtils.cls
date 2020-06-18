/**
 * Because Salesforce doesn't provide an way of getting the record type and custom field Ids,
 * this utility provides a way of getting the appropriate Id in a single location.
 */
public with sharing class IdUtils {

    public static final Id PRODUCTION_ORG_ID = '00D0n000000D6Pt';
    public static final Id PRODQA_ORG_ID = '00Dg0000006I4AZ';
    public static final Id QA_ORG_ID = '00Dg0000006I4Cd';

    // Common user Ids that are needed inside of triggers and will avoid SOQL queries to prevent
    // hitting governance limits.
    public static final Id BATCH_USER_ID = '0051Y000009QYFxQAO';
    public static final Id AVOKA_USER_ID = '0051Y000009J0BUQA0';

    // Common profile Ids that are needed to avoid SOQL queries to prevent hitting governance
    // limits.
    public static final Id SYSTEM_ADMIN_PROFILE_ID = '00ei000000172w8AAA';

    private static Map<String,Id> leadFieldNameToIdMap = new Map<String,Id>{
        'ReferralType__c' => '00N1Y00000Ia0LS'
    };

    public static Id getLeadRecordFieldIdByName(String fieldName) {
        return leadFieldNameToIdMap.get(fieldName);
    }

    public static Boolean isServiceUser(Id userId) {
        return userId == BATCH_USER_ID || userId == AVOKA_USER_ID;
    }

    public static Boolean isQueue(Id recordId) {
        return String.valueOf(recordId).startsWith('00G');
    }

}