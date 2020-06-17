<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LLC_BI__Populate_Original_Loan_Amount</fullName>
        <description>-DEPRECATED- Populates the Original Loan Amount field using the value from the loan record. This functionality is now included in managed triggers.</description>
        <field>LLC_BI__Original_Loan_Amount__c</field>
        <formula>LLC_BI__Loan__r.LLC_BI__Amount__c</formula>
        <name>Populate Original Loan Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LLC_BI__Populate Loan Amount on Collateral Pledged</fullName>
        <actions>
            <name>LLC_BI__Populate_Original_Loan_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>-DEPRECATED- On new Collateral Pledged records, this workflow populates the Loan Amount field using the value from the loan record. This functionality is now included in managed triggers.</description>
        <formula>false</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
