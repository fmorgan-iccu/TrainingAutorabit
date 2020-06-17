/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomatedBookingStoreChildStatusInvoker {
    global AutomatedBookingStoreChildStatusInvoker() {

    }
    @InvocableMethod(label='Set Booking Status' description='Sets related booking statuses for the supplied records')
    global static List<ATBK.AutomatedBookingStoreChildStatusInvoker.OutputParams> invoke(List<ATBK.AutomatedBookingStoreChildStatusInvoker.InputParams> params) {
        return null;
    }
global class InputParams {
    @InvocableVariable(label='Parent Status Action' description='The booking action being requested(RESERVE or BOOK)' required=true)
    global String action;
    @InvocableVariable(label='Core Id' description='The core id of the object having its booking status set' required=false)
    global String coreId;
    @InvocableVariable(label='Parent Record Id' description='The parent record id of the object having its booking status set' required=true)
    global String parentRecordId;
    @InvocableVariable(label='Parent Transaction Log Id' required=true)
    global String parentTransactionLogId;
    @InvocableVariable(label='Record Id' description='Id of this sObject that is having an Id reserved or being booked' required=true)
    global String recordId;
    @InvocableVariable(label='Status Code' description='Overall status of the reserve or book request for this related object' required=true)
    global String statusCode;
    @InvocableVariable(label='Status Summary' description='Detailed overall status of the reserve or book request' required=false)
    global String statusSummary;
    global InputParams() {

    }
}
global class OutputParams {
    @InvocableVariable(label='Message' description='Additional Information if applicable' required=false)
    global String message;
    @InvocableVariable(label='Success' description='Identifies the success or failure of the request' required=false)
    global Boolean success;
    global OutputParams() {

    }
}
}
