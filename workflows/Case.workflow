<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Complaint_Case_Left_Closing_Message_Alerts</fullName>
        <description>Complaint Case Closing Message Alerts</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_Case_Left_Closing_Message_Temp</template>
    </alerts>
    <alerts>
        <fullName>Complaint_Case_Left_Message_Alerts</fullName>
        <description>Complaint Case Left Message Alerts</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_Case_Left_Message_Temp</template>
    </alerts>
    <alerts>
        <fullName>Complaint_case_notifications_for_the_PR_SM_team</fullName>
        <ccEmails>SocialMediaResponseTeam@iccu.com</ccEmails>
        <description>Complaint case notifications for the PR/SM team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Branch_Performance_Resolution_Specialist</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_case_notifications_for_the_PR_SM_team</template>
    </alerts>
    <alerts>
        <fullName>Complaint_case_notifications_for_the_PR_SM_team_CLOSED</fullName>
        <ccEmails>SocialMediaResponseTeam@iccu.com</ccEmails>
        <description>Complaint case notifications for the PR/SM team-CLOSED</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Branch_Performance_Resolution_Specialist</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_case_notifications_for_the_PR_SM_team_CLOSED</template>
    </alerts>
    <alerts>
        <fullName>Complaint_case_opened_Alerts</fullName>
        <description>Complaint case opened Alerts</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_Case_Open_Email_Temp</template>
    </alerts>
    <alerts>
        <fullName>Left_Message_Case</fullName>
        <description>Left Message (Case)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MRA_Communication/Left_Message_Follow_Up_Case</template>
    </alerts>
    <alerts>
        <fullName>VSC_Send_Applied_Promo</fullName>
        <description>VSC Send Applied Promo</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>VSC_Templates/Applied_Promo_Message</template>
    </alerts>
    <alerts>
        <fullName>X11_days_after_Department_of_Finance_case_has_been_open</fullName>
        <description>11 days after Department of Finance case has been open</description>
        <protected>false</protected>
        <recipients>
            <recipient>Branch_Performance_Resolution_Specialist</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>CAO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Chief_Experience_Officer</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Executive_Assistant</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ampalmer@iccu.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cjohns@iccu.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sbeebe@iccu.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_11_Days_Escalation_for_Department_of_Finance</template>
    </alerts>
    <alerts>
        <fullName>X14_day_Complaint_Case_Other_than_Department_of_Finance</fullName>
        <description>14 day Complaint Case (Other than Department of Finance)</description>
        <protected>false</protected>
        <recipients>
            <recipient>AVP_of_Member_Service_Centers</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Branch_Performance_Analyst</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Chief_Experience_Officer</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_Case_open_for_14_days</template>
    </alerts>
    <alerts>
        <fullName>X24_Hour_Complaint_Not_Department_of_Finance</fullName>
        <description>24 Hour Complaint (Not Department of Finance)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Branch_Performance_Analyst</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/Complaint_first_24_hours</template>
    </alerts>
    <alerts>
        <fullName>X24_Hour_Department_of_Finance</fullName>
        <description>24 Hour Department of Finance</description>
        <protected>false</protected>
        <recipients>
            <recipient>AVP_of_Member_Service_Centers</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Branch_Performance_Analyst</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Chief_Experience_Officer</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Executive_Assistant</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaint/First_24_hours_Complaint_Escalation_for_Department_of_Finance</template>
    </alerts>
    <rules>
        <fullName>11 days Department of Finance Case</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Stage__c</field>
            <operation>notEqual</operation>
            <value>Close the Case</value>
        </criteriaItems>
        <description>Notification when a Department of Finance Case has been open for 11 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X11_days_after_Department_of_Finance_case_has_been_open</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>11 days Department of Finance CaseV2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Stage__c</field>
            <operation>notEqual</operation>
            <value>Close the Case</value>
        </criteriaItems>
        <description>Notification when a Department of Finance Case has been open for 11 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X11_days_after_Department_of_Finance_case_has_been_open</name>
                <type>Alert</type>
            </actions>
            <timeLength>11</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>11 days Department of Finance CaseV3</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Stage__c</field>
            <operation>notEqual</operation>
            <value>Close the Case</value>
        </criteriaItems>
        <description>Notification when a Department of Finance Case has been open for 11 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X11_days_after_Department_of_Finance_case_has_been_open</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Date_Time_of_Complaint__c</offsetFromField>
            <timeLength>11</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>14 day Complaint notificationV2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Escalated,New,Open,In Review,In Progress</value>
        </criteriaItems>
        <description>notification if Complaint Case other than Department of Finance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X14_day_Complaint_Case_Other_than_Department_of_Finance</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>24 hour Complaint %28Not Department of Finance%29V2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Stage__c</field>
            <operation>notEqual</operation>
            <value>Close the Case</value>
        </criteriaItems>
        <description>24 hours after a Complaint other than Department of Finance</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X24_Hour_Complaint_Not_Department_of_Finance</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>24 hour Department of Finance</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Department of Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Stage__c</field>
            <operation>notEqual</operation>
            <value>Close the Case</value>
        </criteriaItems>
        <description>24 hours after a Department of finance complaint is created.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X24_Hour_Department_of_Finance</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Closed Social Media Complaint Case</fullName>
        <actions>
            <name>Complaint_case_notifications_for_the_PR_SM_team_CLOSED</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
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
        <description>Notification for Social Media Response team telling them that a Social Media Complaint Case has been closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Left Closing Message Rule</fullName>
        <actions>
            <name>Complaint_Case_Left_Closing_Message_Alerts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Left_Message_Three__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Phone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <description>Send first email, becouse attempt to contact the contact, but unable to successfully get in touch.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Left First Message Rule</fullName>
        <actions>
            <name>Complaint_Case_Left_Message_Alerts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Left_Message_One__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Phone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <description>Send first email, becouse attempt to contact the contact, but unable to successfully get in touch.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Left Second Message Rule</fullName>
        <actions>
            <name>Complaint_Case_Left_Message_Alerts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Left_Message_Two__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Phone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <description>Send second email, because attempt to contact the contact, but unable to successfully get in touch.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Open Rule</fullName>
        <actions>
            <name>Complaint_case_opened_Alerts</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send email when Complaint Case opened</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Left First Message %28Case%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Left_Message_One__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed,Closed Lost,Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Message_Case</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Left_First_Message</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left Second Message %28Case%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Left_Message_Two__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Escalated,New,Open,In Review,In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Message_Case</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Left_message_three_days_ago</name>
                <type>Task</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Left third Message %28Case%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Left_Message_Three__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New,Open,In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Left_Message_Case</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Left_message_7_days_ago</name>
                <type>Task</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>New Social Media Complaint Case</fullName>
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
        <description>Notification to Social Media Response Team when a new Social Media Complaint is Opened.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Promotion Applied Email</fullName>
        <actions>
            <name>VSC_Send_Applied_Promo</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Send_Email_Yes_No__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Promotion__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send a promotion applied email when Applied Promo is checked and Send Email Yes/No = Yes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Left_First_Message</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left a message one day ago.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left First Message</subject>
    </tasks>
    <tasks>
        <fullName>Left_message_7_days_ago</fullName>
        <assignedToType>owner</assignedToType>
        <description>Left message for member 7 days ago.</description>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left message 7 days ago</subject>
    </tasks>
    <tasks>
        <fullName>Left_message_three_days_ago</fullName>
        <assignedToType>owner</assignedToType>
        <description>Called customer three days ago.</description>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Left message three days ago</subject>
    </tasks>
</Workflow>
