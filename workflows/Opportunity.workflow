<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>A_loan_application_has_been_open_for_more_than_twenty_five_days</fullName>
        <description>A loan application has been open for more than twenty five days</description>
        <protected>false</protected>
        <recipients>
            <recipient>FSC_Supervisors</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@iccu.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Approaching_ECOA_violation_date</template>
    </alerts>
    <alerts>
        <fullName>Approaching_ECOA_Violation</fullName>
        <description>Approaching ECOA Violation</description>
        <protected>false</protected>
        <recipients>
            <recipient>FSC_Supervisors</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iccu.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Approaching_ECOA_violation_date</template>
    </alerts>
    <alerts>
        <fullName>Email_to_members_if_the_member_does_not_answer_their_phone</fullName>
        <description>Email to members if the member does not answer their phone</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Joint_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Left_Messages_Notification</template>
    </alerts>
    <alerts>
        <fullName>Left_First_Message_to_Customer</fullName>
        <description>Left First Message to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/Follow_up_Message</template>
    </alerts>
    <alerts>
        <fullName>Left_Fourth_Message_to_Customer4</fullName>
        <description>Left Fourth Message to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/Follow_up_Message</template>
    </alerts>
    <alerts>
        <fullName>Left_Second_Message_to_Customer</fullName>
        <description>Left Second Message to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/Follow_up_Message</template>
    </alerts>
    <alerts>
        <fullName>Left_Third_Message_to_Customer3</fullName>
        <description>Left Third Message to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/Follow_up_Message</template>
    </alerts>
    <alerts>
        <fullName>The_12_hour_rule</fullName>
        <description>The 12 hour rule</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Virtual_Service_Center_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>noreply@iccu.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_In_Assigned_Stage_For_more_than_12_hr</template>
    </alerts>
    <alerts>
        <fullName>This_Opportunity_is_approaching_it_s_ECOA_violation_date</fullName>
        <description>This Opportunity is approaching it&apos;s ECOA violation date</description>
        <protected>false</protected>
        <recipients>
            <recipient>FSC_Supervisors</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approaching_ECOA_violation_date</template>
    </alerts>
    <alerts>
        <fullName>VSC_The_12_hour_rule</fullName>
        <description>VSC The 12 hour rule for Opportunites</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Virtual_Service_Center_Supervisor</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>noreply@iccu.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_In_Assigned_Stage_For_more_than_12_hr</template>
    </alerts>
    <alerts>
        <fullName>We_left_a_message</fullName>
        <description>We left a message</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Joint_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Left_Voice_Mail</template>
    </alerts>
    <alerts>
        <fullName>X3_day_follow_up</fullName>
        <description>3 day follow up</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/X3_Day_follow_up</template>
    </alerts>
    <alerts>
        <fullName>X3_day_follow_up_email</fullName>
        <description>3 day follow up email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/X3_Day_follow_up</template>
    </alerts>
    <alerts>
        <fullName>first_payment_info</fullName>
        <description>first payment info</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/First_Payment_Information</template>
    </alerts>
    <rules>
        <fullName>3 Day follow-up</fullName>
        <active>true</active>
        <description>Email follow up on Opportunity.</description>
        <formula>Last_Contacted__c &lt;=(TODAY())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X3_day_Opportunity_Follow_up</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Contacted__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ECOA</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Owner_Role__c</field>
            <operation>contains</operation>
            <value>FSC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Deposit Product,Default</value>
        </criteriaItems>
        <description>This rule sends an escalation email when an opportunity is not closed for more than 25 days</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Approaching_ECOA_Violation</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Warning_Approaching_ECOA_Violation</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CreatedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left First Message</fullName>
        <actions>
            <name>Left_First_Message_to_Customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.LeftMessageOne__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Complete,Declined,Member Rejected,No Further Action</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_First_Message_for_Member</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left Fourth message</fullName>
        <actions>
            <name>Left_Fourth_Message_to_Customer4</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.LeftMessageFourth__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Fourth_Message_for_Member</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left Second Message</fullName>
        <actions>
            <name>Left_Second_Message_to_Customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.LeftMessageTwo__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Second_Message_for_Member</name>
                <type>Task</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left Third message</fullName>
        <actions>
            <name>Left_Third_Message_to_Customer3</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.LeftMessageThree__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Third_Message_for_Member</name>
                <type>Task</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Left_First_Message_for_Member</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left First Message for Member.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left First Message for Member</subject>
    </tasks>
    <tasks>
        <fullName>Left_Fourth_Message_for_Member</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left Fourth Message for Member.</description>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left Fourth Message for Member</subject>
    </tasks>
    <tasks>
        <fullName>Left_Messages</fullName>
        <assignedToType>owner</assignedToType>
        <description>This Task is a follow up on an opportunity after the agent left message for the member</description>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left Messages</subject>
    </tasks>
    <tasks>
        <fullName>Left_Second_Message_for_Member</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left Second Message for Member.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left Second Message for Member</subject>
    </tasks>
    <tasks>
        <fullName>Left_Third_Message_for_Member</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left Third Message for Member.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left Third Message for Member</subject>
    </tasks>
    <tasks>
        <fullName>Warning_Approaching_ECOA_Violation</fullName>
        <assignedToType>owner</assignedToType>
        <description>This is a reminder task for opportunities that has been open for more than 24 days</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Warning Approaching ECOA Violation</subject>
    </tasks>
    <tasks>
        <fullName>X3_day_Opportunity_Follow_up</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Last_Contacted__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>3 day Opportunity Follow-up</subject>
    </tasks>
</Workflow>
