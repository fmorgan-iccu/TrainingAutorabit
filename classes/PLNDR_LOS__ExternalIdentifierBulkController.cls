/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ExternalIdentifierBulkController {
    global ExternalIdentifierBulkController() {

    }
    @InvocableMethod(label='Bulk Hash External Identifiers' description='Bulk hash external identifiers.')
    global static void HashExternalIdentifiers(List<PLNDR_LOS.ExternalIdentifierBulkController.ExternalIdentifierBulkHashRequest> requests) {

    }
global class ExternalIdentifierBulkHashRequest {
    @InvocableVariable(label='Optional Batch Size' required=false)
    global Integer BatchSize;
    @InvocableVariable(label='Input Field API Name' required=true)
    global String InputFieldName;
    @InvocableVariable(label='Output Field API Name' required=true)
    global String OutputFieldName;
    @InvocableVariable(label='Record Type' required=true)
    global String RecordType;
    @InvocableVariable(label='Hash Standard' required=true)
    global String Standard;
    @InvocableVariable(label='Optional Where Filter' required=false)
    global String WhereFilter;
    global ExternalIdentifierBulkHashRequest() {

    }
}
}
