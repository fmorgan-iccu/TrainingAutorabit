/* NOTE:  Invoke this page by navigating to:
 * https://iccu--uidev.lightning.force.com/apex/SubsequentActionXfdf?accountNumber=1234
 */
public with sharing class AutoPayoffXfdfController {

    public AutoPayoffXfdfController() {
    }

    public AutoPayoffXfdfController(ApexPages.StandardController controller) {
    }

    public String getXfdf() {
        Map<String, String> pageParameters = System.currentPageReference().getParameters();
        String payload = pageParameters.get('payload');
        Map<String, Object> formData = (Map<String, Object>)JSON.deserializeUntyped(payload);

        Date today = System.today();

        String pdfPath = '\\\\fs02\\Shares\\IS\\Restricted\\Innovations\\Helix Form Templates\\Loan-Auto_Payoff_Quote.pdf';
        Map<String, String> fieldValues = new Map<String, String> {
            'Date' => DateUtils.format(today, 'MM/dd/yyyy'),
            'Company Name' => (String)formData.get('companyName'),
            'Company Street' => (String)formData.get('companyStreet'),
            'Company City, State Zip' => (String)formData.get('companyCityStatePostalCode'),
            'Account Number' => (String)formData.get('accountNumber'),
            'Member Name' => (String)formData.get('memberName'),
            'Member Street' => (String)formData.get('memberStreet'),
            'Member City, State Zip' => (String)formData.get('memberCityStatePostalCode'),
            'Payment Amount' => (String)formData.get('payoffAmount'),
            'Per Diem' => (String)formData.get('perDiem'),
            'Valid Date' => (String)formData.get('payoffDate'),
            'Team Member Name' => (String)formData.get('teamMemberName'),
            'Team Member Title' => (String)formData.get('teamMemberTitle')
        };
        String xfdf = PdfUtils.generateXfdf(pdfPath, fieldValues);

        return xfdf;
    }

}