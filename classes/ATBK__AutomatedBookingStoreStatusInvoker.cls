/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomatedBookingStoreStatusInvoker {
    global AutomatedBookingStoreStatusInvoker() {

    }
    @InvocableMethod(label='Set Booking Status' description='Sets booking statuses for the supplied records')
    global static List<ATBK.AutomatedBookingStoreStatusInvoker.OutputParams> invoke(List<ATBK.AutomatedBookingStoreStatusInvoker.InputParams> params) {
        return null;
    }
global class InputParams {
    @InvocableVariable(label='Status Action' description='The booking action being requested' required=true)
    global String action;
    @InvocableVariable(label='Core Id' description='The core id of the loan having its booking status set' required=false)
    global String coreId;
    @InvocableVariable(label='Record Id' description='Id of the sObject that is having an Id reserved or being booked' required=true)
    global String recordId;
    @InvocableVariable(label='Status Code' description='Overall status of the reserve or book request' required=false)
    global String statusCode;
    @InvocableVariable(label='Status Summary' description='Detailed overall status of the reserve or book request' required=false)
    global String statusSummary;
    @InvocableVariable(label='Transaction Log Id' required=false)
    global String transactionLogId;
    global InputParams() {

    }
}
global class OutputParams {
    @InvocableVariable(label='Status Action' description='The booking action being requested' required=false)
    global String action;
    @InvocableVariable(label='Core Id' description='The core Id of the item that the booking status applies to' required=false)
    global String coreId;
    @InvocableVariable(label='Record Id' description='The internal Id of the item that the booking status applies to' required=false)
    global String recordId;
    @InvocableVariable(label='Status Code' description='Overall Status of the reserve or book request' required=false)
    global String statusCode;
    @InvocableVariable(label='Status Id' description='Id of the persisted status' required=false)
    global String statusId;
    @InvocableVariable(label='Status Summary' description='Detailed overall status of the reserve or book request' required=false)
    global String statusSummary;
    @InvocableVariable(label='Timestamp' description='When the status was last updated' required=false)
    global Datetime timestamp;
    @InvocableVariable(label='Transaction Log Id' required=false)
    global String transactionLogId;
    global OutputParams() {

    }
}
}
