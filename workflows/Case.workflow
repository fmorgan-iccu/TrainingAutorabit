<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Complaint_case_notifications_for_the_PR_SM_team</fullName>
        <description>Complaint case notifications for the PR/SM team</description>
        <protected>false</protected>
        <recipients>
            <recipient>fmorgan@iccu.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_case_notifications_for_the_PR_SM_team</template>
    </alerts>
    <alerts>
        <fullName>Complaint_case_notifications_for_the_PR_SM_team_CLOSED</fullName>
        <description>Complaint case notifications for the PR/SM team-CLOSED</description>
        <protected>false</protected>
        <recipients>
            <recipient>fmorgan@iccu.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_case_notifications_for_the_PR_SM_team_CLOSED</template>
    </alerts>
    <rules>
        <fullName>Closed Social Media Case</fullName>
        <actions>
            <name>Complaint_case_notifications_for_the_PR_SM_team_CLOSED</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Social Media - Facebook,Social Media - Twitter,Social Media - Instagram,Social Media - Google/Yelp</value>
        </criteriaItems>
        <description>Notification when A Social Media Case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Social Media Case Opened</fullName>
        <actions>
            <name>Complaint_case_notifications_for_the_PR_SM_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Social Media - Facebook,Social Media - Twitter,Social Media - Instagram,Social Media - Google/Yelp</value>
        </criteriaItems>
        <description>Notification when a new Social Media Case is opened</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
