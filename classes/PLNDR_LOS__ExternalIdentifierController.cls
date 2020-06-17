/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ExternalIdentifierController {
    global ExternalIdentifierController() {

    }
    @InvocableMethod(label='Hash External Identifiers' description='Hash external identifiers.')
    global static void HashExternalIdentifiers(List<PLNDR_LOS.ExternalIdentifierController.ExternalIdentifierHashRequest> requests) {

    }
global class ExternalIdentifierHashRequest {
    @InvocableVariable(label='Input Field API Name' required=true)
    global String InputFieldName;
    @InvocableVariable(label='Output Field API Name' required=true)
    global String OutputFieldName;
    @InvocableVariable(label='Record ID' required=true)
    global Id RecordId;
    @InvocableVariable(label='Hash Standard' required=true)
    global String Standard;
    global ExternalIdentifierHashRequest() {

    }
}
}
