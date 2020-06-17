trigger AccountAfterTrigger on Account (after update) {

    if (Trigger.isUpdate) {
        if (!TriggerUtils.checkExecuted('AccountMergeIntoProcessing')) {
            // IMPORTANT NOTE:  Even though this is coded to support batch processing, in practice
            // the bulk processing can fail for any number of data reasons.  It is BEST to load the
            // mergeIntoId__c values with a batch size of one.

            // If the mergeIntoId is set on one or more accounts, attempt to merge the account.
            Set<Id> idsToMerge = new Set<Id>();
            for (Account a : Trigger.new) {
                if (!String.isBlank(a.mergeIntoId__c)) {
                    idsToMerge.add(a.id);
                }
            }
            if (idsToMerge.size() > 0) {
                // Retreive the accounts so that the records are not read only.  This query includes all
                // of the fields defined by the object definition to ensure that the merge saves the
                // appropriate data.
                List<Account> accountsWithMergeInto =
                    Database.query('SELECT '
                        + String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',')
                        + ' FROM Account WHERE id IN :idsToMerge');

                // Associate all of the accounts with the same mergeIntoId__c value into a list of accounts that
                // will be merged together.
                Map<Id, List<Account>> accountsToMerge = new Map<Id, List<Account>>();
                for (Account a : accountsWithMergeInto) {
                    List<Account> accounts = accountsToMerge.get(a.mergeIntoId__c);
                    if (accounts == null) {
                        accounts = new List<Account>();
                        accountsToMerge.put(a.mergeIntoId__c, accounts);
                    }
                    accounts.add(a);
                }

                // Retrieve the target "mergeIntoId__c" accounts and add them to the appropriate merge list.
                Set<Id> mergeIntoIds = accountsToMerge.keySet();
                List<Account> mergeIntoAcounts = Database.query('SELECT '
                    + String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',')
                    + ' FROM Account WHERE id IN :mergeIntoIds');
                for (Account a : mergeIntoAcounts) {
                    List<Account> accounts = accountsToMerge.get(a.id);
                    accounts.add(a);
                }

                // Finally merge the accounts.
                try {
                    MergeUtils.massMerge(accountsToMerge.values());
                } catch (MergeUtils.MergeLimitException e) {
                    LogUtils.log(LoggingLevel.ERROR, 'AccountMergeIntoProcessing', e.getMessage());
                }
            }
        }
    }

}