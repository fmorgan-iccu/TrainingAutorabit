/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/BulkHashExternalIdentifiers/*')
global class BulkHashExternalIdentifierController {
    global BulkHashExternalIdentifierController() {

    }
    @HttpGet
    global static PLNDR_LOS.BulkHashExternalIdentifierController.BulkHashExternalIdentifierResponse doGet() {
        return null;
    }
    @HttpPost
    global static PLNDR_LOS.BulkHashExternalIdentifierController.BulkHashJobIdResponse post(String Standard, String InputField, String OutputField, String RecordType) {
        return null;
    }
global class BulkHashExternalIdentifierResponse {
    global BulkHashExternalIdentifierResponse(String stat, Datetime completed, Integer processed, Integer total, Id job, Integer errors, String extstat) {

    }
}
global class BulkHashJobIdResponse {
    global BulkHashJobIdResponse(Id job) {

    }
}
}
