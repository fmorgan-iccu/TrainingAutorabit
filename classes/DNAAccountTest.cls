@isTest
private class DNAAccountTest {
    @isTest
    private static void happyPathTest() {
        String entityNumber = '2340945';
        String entityType = 'PERS';
        String fullname = 'fullname';
        String personNumber = 'personNumber';
        String roleCode = 'code';
        String roleDesc = 'desc';
        
        DNAJointAccountOwner owner = new DNAJointAccountOwner(true, entityNumber, entityType, fullName, roleCode, roleDesc);
        System.assert(owner.getFullName().equals(fullName));
        System.assert(owner.getRoleCode().equals(roleCode));
        System.assert(owner.getRoleDescription().equals(roleDesc));
        System.assert(owner.getCanTransact());
        System.assert(owner.isOrg() == false);
        System.assert(owner.isPerson() == true);
        
        String orgEntityType = 'ORG';
        DNAJointAccountOwner orgOwner = new DNAJointAccountOwner(true, entityNumber, orgEntityType, fullName, roleCode, roleDesc);
        System.assert(orgOwner.isOrg() == true);
        System.assert(orgOwner.isPerson() == false);
        
        List<DNAJointAccountOwner> jointOwners = new List<DNAJointAccountOwner>();
        jointOwners.add(owner);

        String accountNumber = '123456';
        double availableBalance = (double)10.10;
        String branchName = 'Chubbuck';
        double currentBalance = (double)9.01;
        double interestRate = (double)0.00457;
        String majorType = 'DEP';
        String minorType = 'SAV';
        String nickName = 'nickName';
        String name = 'name';
        double nextPaymentAmount = (double)1078.45;
        DateTime nextPaymentDate = System.now();
        String status = 'status';
        
        DNAAccount account = new DNAAccount();
        account.setAccountNumber(accountNumber);
        account.setAvailableBalance(availableBalance);
        account.setBranchName(branchName);
        account.setCurrentBalance(currentBalance);
        account.setInterestRate(interestRate);
        account.setJointOwners(jointOwners);
        account.setMajorType(majorType);
        account.setMinorType(minorType);
        account.setName(name);
        account.setNickName(nickName);
        account.setNextPaymentAmount(nextPaymentAmount);
        account.setNextPaymentDate(nextPaymentDate);
        account.setStatus(status);

        System.assert(account.getAccountNumber().equals(accountNumber));
        System.assert(account.getAvailableBalance() == availableBalance);
        System.assert(account.getBranchName().equals(branchName));
        System.assert(account.getCurrentBalance() == currentBalance);
        System.assert(account.getInterestRate() == interestRate);
        System.assert(account.getJointOwners() != null);
        System.assert(account.getJointOwners().size() == 1);
        System.assert(account.getMajorType().equals(majorType));
        System.assert(account.getMinorType().equals(minorType));
        System.assert(account.getName().equals(name));
        System.assert(account.getNextPaymentAmount() == nextPaymentAmount);
        System.assert(account.getNextPaymentDate() == nextPaymentDate);
        System.assert(account.getNickName().equals(nickName));
        System.assert(account.getStatus().equals(status));

        DNAAccount contructorAccount = new DNAAccount(accountNumber, availableBalance, branchName, currentBalance, interestRate, jointOwners, majorType, minorType, name, nickName, status);
        System.assert(contructorAccount.getAccountNumber().equals(accountNumber));
        System.assert(contructorAccount.getBranchName().equals(branchName));
        System.assert(contructorAccount.getAvailableBalance() == availableBalance);
        System.assert(contructorAccount.getCurrentBalance() == currentBalance);
        System.assert(contructorAccount.getInterestRate() == interestRate);
        System.assert(contructorAccount.getJointOwners() != null);
        System.assert(contructorAccount.getJointOwners().size() == 1);
        System.assert(contructorAccount.getMajorType().equals(majorType));
        System.assert(contructorAccount.getMinorType().equals(minorType));
        System.assert(contructorAccount.getNickName().equals(nickName));
        System.assert(contructorAccount.getName().equals(name));
        System.assert(contructorAccount.getNextPaymentDate() == null);
    }
}