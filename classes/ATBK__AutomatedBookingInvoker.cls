/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomatedBookingInvoker {
    global AutomatedBookingInvoker() {

    }
    @InvocableMethod(label='Send Automated Request to Endpoint.' description='Send Automated Request to Endpoint.')
    global static List<ATBK.AutomatedBookingInvoker.OutputParams> invoke(List<ATBK.AutomatedBookingInvoker.InputParams> params) {
        return null;
    }
global class InputParams {
    @InvocableVariable(label='Action' description='The booking action being requested' required=true)
    global String action;
    @InvocableVariable(label='ContextId' description='The Id of the item that is having an Id reserved or being booked' required=true)
    global Id contextId;
    global InputParams() {

    }
}
global class OutputParams {
    @InvocableVariable(label='Category' description='The Category of the item that is having an Id reserved or being booked' required=true)
    global String category;
    @InvocableVariable(label='Core Id' description='The Id of the External Id created when sending this request' required=true)
    global String coreId;
    @InvocableVariable(label='Has status timed out?' description='Flag that indicates if the pending status is timed out or not' required=true)
    global Boolean isTimedOut;
    @InvocableVariable(label='Record Id' description='The Id of the item that is having an Id reserved or being booked' required=true)
    global String recordId;
    @InvocableVariable(label='Remaining Time' description='Time remaining for the status to expire' required=true)
    global Long remainingTime;
    @InvocableVariable(label='Status Code' description='Overall Status of the reserve or book request' required=true)
    global String statusCode;
    @InvocableVariable(label='Status Summary' description='Detailed overall status of the reserve or book request' required=true)
    global String statusSummary;
    @InvocableVariable(label='Date and Time' description='Date and time of the last modified status' required=true)
    global Datetime timestamp;
    @InvocableVariable(label='Transaction Log Id' description='The Id of the Transaction created when sending this request' required=true)
    global String transactionLogId;
    global OutputParams() {

    }
}
}
