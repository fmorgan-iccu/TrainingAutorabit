/* NOTE:  Invoke this page by navigating to:
 * https://iccu--uidev.lightning.force.com/apex/SubsequentActionXfdf?accountNumber=1234
 */
public with sharing class GapCancellationXfdfController {

    public GapCancellationXfdfController() {
    }

    public GapCancellationXfdfController(ApexPages.StandardController controller) {
    }

    public String getXfdf() {
        Map<String, String> pageParameters = System.currentPageReference().getParameters();
        String payload = pageParameters.get('payload');
        Map<String, Object> formData = (Map<String, Object>)JSON.deserializeUntyped(payload);
        String taxId = (String)formData.get('memberSSN');
        String formattedTaxId = taxId.remove('-');

        Date today = System.today();
        // Change to GAp Cancellation location
        String pdfPath = '\\\\fs02\\Shares\\IS\\Restricted\\Innovations\\Helix Form Templates\\gap_request_for_cancellation.pdf';
        Map<String, String> fieldValues = new Map<String, String> {
            'Member Number' => (String)formData.get('memberNumber'),
            'SSN' => formattedTaxId,
            'Member Name' => (String)formData.get('memberName'),
            'Street Address' => (String)formData.get('memberStreet'),
            'City State Zip' => (String)formData.get('memberCityStatePostalCode'),
            'Loan No' => (String)formData.get('loanNumber'),
            'Year' => String.valueOf((Integer)formData.get('vehicleYear')),
            'Make' => (String)formData.get('vehicleMake'),
            'Model' => (String)formData.get('vehicleModel'),
            'Vehicle Identification Number' => (String)formData.get('vin'),
            'Effective Date Issue Date' => (String)formData.get('effectiveDate'),
            'Check Box1' => (String)formData.get('requestedCheckbox'),
            'Check Box2' => (String)formData.get('requestedCheckbox'),
            'Other' => (String)formData.get('explanation'),
            'Cancellation Date' => (String)formData.get('cancellationDate')
        };
        String xfdf = PdfUtils.generateXfdf(pdfPath, fieldValues);

        return xfdf;
    }

}