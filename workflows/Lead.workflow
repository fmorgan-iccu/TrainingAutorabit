<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_nCino_Lead_to_True</fullName>
        <field>nCino_Lead__c</field>
        <literalValue>1</literalValue>
        <name>Set nCino Lead to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>nCino Lead%3F</fullName>
        <actions>
            <name>Set_nCino_Lead_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Loan</value>
        </criteriaItems>
        <description>Set&apos;s the nCIno lead checkbox if Loan lead record type is chosen.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
