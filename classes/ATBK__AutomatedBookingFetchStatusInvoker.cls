/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomatedBookingFetchStatusInvoker {
    global AutomatedBookingFetchStatusInvoker() {

    }
    @InvocableMethod(label='Fetch Booking Status' description='Fetches booking statuses for the supplied records')
    global static List<ATBK.AutomatedBookingFetchStatusInvoker.OutputParams> invoke(List<ATBK.AutomatedBookingFetchStatusInvoker.InputParams> params) {
        return null;
    }
global class InputParams {
    @InvocableVariable(label='Status Action' description='The booking action requested' required=false)
    global String action;
    @InvocableVariable(label='Context Id' description='The Id of the object to fetch the status of' required=true)
    global Id contextId;
    global InputParams() {

    }
}
global class OutputParams {
    @InvocableVariable(label='Action' description='The booking action requested' required=false)
    global String action;
    @InvocableVariable(label='Core Id' description='The core Id of the item that the booking status applies to' required=false)
    global String coreId;
    @InvocableVariable(label='Is Timed Out' description='If statusCode is IN_PROGRESS, indicates if the request has exceeded the timeout duration.' required=false)
    global Boolean isTimedOut;
    @InvocableVariable(label='Parent Status Id' description='Id of the status object this status is the child of' required=false)
    global Id parentStatusId;
    @InvocableVariable(label='Record Id' description='The internal Id of the item that the booking status applies to' required=false)
    global String recordId;
    @InvocableVariable(label='Remaining Time' description='If statusCode is IN_PROGRESS, indicates how long until the request will be timed out.' required=false)
    global Long remainingTime;
    @InvocableVariable(label='Status Code' description='Overall status of the reserve or book request' required=false)
    global String statusCode;
    @InvocableVariable(label='The unique identifier of this status record' required=false)
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
