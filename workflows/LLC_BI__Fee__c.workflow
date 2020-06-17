<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LLC_BI__Set_Fee_Record_Type_To_Adjustments</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LLC_BI__Adjustments</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Fee Record Type To Adjustments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Set_Fee_Record_Type_To_Costs</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LLC_BI__Costs</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Fee Record Type To Costs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Set_Fee_Record_Type_To_Fees</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LLC_BI__Fees</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Fee Record Type To Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LLC_BI__Fee Set Record Type To Adjustments</fullName>
        <actions>
            <name>LLC_BI__Set_Fee_Record_Type_To_Adjustments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LLC_BI__Fee__c.LLC_BI__Record_Type__c</field>
            <operation>equals</operation>
            <value>Adjustments</value>
        </criteriaItems>
        <description>Sets standard Record Type to Costs if Record Type is Costs</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Fee Set Record Type To Costs</fullName>
        <actions>
            <name>LLC_BI__Set_Fee_Record_Type_To_Costs</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LLC_BI__Fee__c.LLC_BI__Record_Type__c</field>
            <operation>equals</operation>
            <value>Costs</value>
        </criteriaItems>
        <description>Sets standard Record Type to Costs if field Record Type is Costs</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Fee Set Record Type To Fees</fullName>
        <actions>
            <name>LLC_BI__Set_Fee_Record_Type_To_Fees</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LLC_BI__Fee__c.LLC_BI__Record_Type__c</field>
            <operation>equals</operation>
            <value>Fees</value>
        </criteriaItems>
        <description>Sets standard Record Type to Fees if Record Type is Fees</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
