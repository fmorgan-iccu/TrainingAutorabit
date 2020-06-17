/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomatedBookingFetchChildStatusInvoker {
    global AutomatedBookingFetchChildStatusInvoker() {

    }
    @InvocableMethod(label='Fetch Child Status' description='Fetches booking statuses for all children of the supplied records')
    global static List<ATBK.AutomatedBookingFetchChildStatusInvoker.OutputParams> invoke(List<ATBK.AutomatedBookingFetchChildStatusInvoker.InputParams> params) {
        return null;
    }
global class InputParams {
    @InvocableVariable(label='Parent Status Id' description='The Id of the parent status to fetch the children of' required=true)
    global Id parentStatusId;
    global InputParams() {

    }
}
global class OutputParams {
    @InvocableVariable(label='Action' description='The booking action requested' required=false)
    global String action;
    @InvocableVariable(label='Core Id' description='The core Id of the item that the booking status applies to' required=false)
    global String coreId;
    @InvocableVariable(label='Parent Status Id' description='Id of the status object this status is the child of' required=false)
    global Id parentStatusId;
    @InvocableVariable(label='Record Id' description='The internal Id of the item that the booking status applies to' required=false)
    global String recordId;
    @InvocableVariable(label='Status Code' description='Overall status of the action request' required=false)
    global String statusCode;
    @InvocableVariable(label='Status Id' description='The unique identifier of this status record' required=false)
    global String statusId;
    @InvocableVariable(label='Status Summary' description='Detailed overall status of the action request' required=false)
    global String statusSummary;
    @InvocableVariable(label='Timestamp' description='When the status was last updated' required=false)
    global Datetime timestamp;
    @InvocableVariable(label='Transaction Log Id' required=false)
    global String transactionLogId;
    global OutputParams() {

    }
}
}
