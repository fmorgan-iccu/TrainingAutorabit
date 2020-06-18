/* NOTE:  Invoke this page by navigating to:
 * https://iccu--uidev.lightning.force.com/apex/SubsequentActionXfdf?accountNumber=1234
 */
public with sharing class SubsequentActionXfdfController {
    public SubsequentActionXfdfController() {
    }

    public SubsequentActionXfdfController(ApexPages.StandardController controller) {
    }

    public String getXfdf() {
        Map<String, String> pageParameters = System.currentPageReference().getParameters();
        String accountNumber = pageParameters.get('accountNumber');
        DNAPersonAccountDataProvider accountProvider = new DNAPersonAccountDataProvider();

        IAccount account = null;
        try {
            account = accountProvider.getAccount(accountNumber);
        } catch (UnauthenticatedException e) {
            return 'Please log in to DNA.';
        } catch (Exception e) {
            return e.getMessage();
        }

        String currentDate = DateUtils.format(System.today(), 'MM/dd/yyyy');
        List<IJointAccountOwner> owners = account.getJointOwners();
        IJointAccountOwner borrower1 = owners.size() > 0 ? owners[0] : null;
        IJointAccountOwner borrower2 = owners.size() > 1 ? owners[1] : null;
        String borrower1Name = borrower1 != null ? borrower1.getFullName() : '';
        String borrower2Name = borrower2 != null ? borrower2.getFullName() : '';
        String additionalBorrower = 'yes';

        String pdfPath = '\\\\fs02\\Shares\\IS\\Common\\Innovations\\Helix Form Templates\\Subsequent_Action.pdf';
        Map<String, String> fieldValues = new Map<String, String> {
            'AP1_FULL_NAME' => borrower1Name,
            'AP2_FULL_NAME' => borrower2Name,
            'LOAN_ACCT_NMBR' => accountNumber,
            'Currrent_Date' => currentDate,
            'Check2' => additionalBorrower,
            'Current_Date1' => currentDate
        };
        String xfdf = PdfUtils.generateXfdf(pdfPath, fieldValues);

        return xfdf;
    }

}