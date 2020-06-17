trigger policyException_runLoanPolicyExceptionFinderFlow_afterDelete on LLC_BI__Policy_Exception__c ( after delete )
{
   for ( LLC_BI__Policy_Exception__c deletedPE : Trigger.old )
   {
      String loanId = deletedPE.LLC_BI__Loan__c;
      Map<String, Object> params = new Map<String, Object>();
      params.put('input_loanId', loanId);
      Flow.Interview.Indicate_Product_Package_Loans_Have_Policy_Exceptions peFlow = new Flow.Interview.Indicate_Product_Package_Loans_Have_Policy_Exceptions(params);
      peFlow.start();
   }
}