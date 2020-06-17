<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LLC_BI__Alert_Loan_Withdrawn_Declined</fullName>
        <ccEmails>trialforce@bankr.com</ccEmails>
        <description>Alert Loan Withdrawn / Declined</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__Loan_Withdrawn_DeclinedAlert</template>
    </alerts>
    <alerts>
        <fullName>LLC_BI__Alert_Loan_in_Closing_Stage_too_Long</fullName>
        <ccEmails>demo@bankr.com</ccEmails>
        <description>Alert Loan in Closing Stage too Long</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__Loan_in_Closing_XDay_Alert</template>
    </alerts>
    <alerts>
        <fullName>LLC_BI__Loan_Closing_E_mail_Alert</fullName>
        <ccEmails>demo@bankr.com</ccEmails>
        <description>Loan Closing E-mail Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__Loan_Closing_Termplate</template>
    </alerts>
    <alerts>
        <fullName>LLC_BI__Loan_Lost_Alert</fullName>
        <ccEmails>trialforce@bankr.com</ccEmails>
        <description>Loan Lost Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__Loan_Closing_Termplate</template>
    </alerts>
    <alerts>
        <fullName>LLC_BI__Notify_Loan_Reviewed_by_Quality_Compliance</fullName>
        <ccEmails>trialforce@bankr.com</ccEmails>
        <description>Notify Loan Reviewed by Quality (Compliance)</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__Loan_Reviewed_by_Compliance</template>
    </alerts>
    <alerts>
        <fullName>LLC_BI__Notify_Roles_of_Lead_Conversion_into_Loan</fullName>
        <ccEmails>demo@bankr.com</ccEmails>
        <description>Notify Roles of Lead Conversion into Loan</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LLC_BI__Bankr_Templates/LLC_BI__LeadConverted</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_PL_Loan_Id</fullName>
        <field>PL_Loan_ID__c</field>
        <name>Clear PL Loan Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Final_Review_Team_Key_Trigger</fullName>
        <field>LLC_BI__MailerTeamKey__c</field>
        <formula>&quot;StageFinalReview&quot;</formula>
        <name>Final Review Team Key Trigger</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__IsApproved</fullName>
        <field>LLC_BI__Is_Approved__c</field>
        <literalValue>1</literalValue>
        <name>IsApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__IsOriginalDeclinedLoan</fullName>
        <field>LLC_BI__Is_Original_Inactive_Loan__c</field>
        <literalValue>1</literalValue>
        <name>IsOriginalDeclinedLoan</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Loan_Balloon_Indicator_Unset</fullName>
        <description>Unset the Loan Balloon Indicator</description>
        <field>LLC_BI__Balloon__c</field>
        <literalValue>0</literalValue>
        <name>Loan Balloon Indicator Unset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Loan_Balloon_Indicator_Update</fullName>
        <description>Update the Loan Balloon Indicator</description>
        <field>LLC_BI__Balloon__c</field>
        <literalValue>1</literalValue>
        <name>Loan Balloon Indicator Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Loan_Lost_MTK</fullName>
        <description>Trigger mailerteamkey for Loan Lost Alert</description>
        <field>LLC_BI__MailerTeamKey__c</field>
        <formula>&quot;LoanLost&quot;</formula>
        <name>Loan Lost - MTK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Set_Payoff_Date_on_Paid_Out</fullName>
        <field>LLC_BI__Payoff_Date__c</field>
        <formula>Today()</formula>
        <name>Set Payoff Date on Paid Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__UCC_Update_State</fullName>
        <field>LLC_BI__UCC_State__c</field>
        <formula>LLC_BI__CloseDate__c + 1826</formula>
        <name>UCC Update State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__UpdateLoanStage</fullName>
        <field>LLC_BI__Stage__c</field>
        <literalValue>Processing</literalValue>
        <name>Update Loan Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Update_HMDA_Record_Type</fullName>
        <description>Updates the HMDA Record Type field based on the date.</description>
        <field>LLC_BI__HMDA_Record_Type__c</field>
        <literalValue>HMDA-Effective-2018</literalValue>
        <name>Update HMDA Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Update_UCC_County</fullName>
        <field>LLC_BI__UCC_County__c</field>
        <formula>LLC_BI__CloseDate__c + 1826</formula>
        <name>Update UCC County</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Update_isClosed</fullName>
        <field>LLC_BI__isClosed__c</field>
        <literalValue>1</literalValue>
        <name>Update isClosed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LLC_BI__Update_isClosed_to_True</fullName>
        <description>The loan has closed, so update the isClosed stage to true</description>
        <field>LLC_BI__isClosed__c</field>
        <literalValue>1</literalValue>
        <name>Update isClosed to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Loan_is_Approved</fullName>
        <field>LLC_BI__MailerTeamKey__c</field>
        <formula>&quot;LoanApproved&quot;</formula>
        <name>Loan is Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Loan_is_Rejected</fullName>
        <field>LLC_BI__MailerTeamKey__c</field>
        <formula>&quot;LoanRejected&quot;</formula>
        <name>Loan is Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Application_Date</fullName>
        <field>Application_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Application Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_App_for_Loan_UI</fullName>
        <field>LLC_BI__Default_App__c</field>
        <formula>&quot;loan-iccu.loan-iccu-loan-dashboard&quot;</formula>
        <name>Set Default App for Loan UI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Loan_Stage_to_Approval</fullName>
        <field>LLC_BI__Stage__c</field>
        <literalValue>Approval/Loan Committee</literalValue>
        <name>Set Loan Stage to Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_to_Processing</fullName>
        <field>LLC_BI__Stage__c</field>
        <literalValue>Processing</literalValue>
        <name>Set Stage to Processing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_to_Qualification</fullName>
        <field>LLC_BI__Stage__c</field>
        <literalValue>Qualification</literalValue>
        <name>Set Stage to Qualification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Open</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Open</literalValue>
        <name>Set Status to Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Recalled</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Set Status to Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Rejected</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Step1</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Step1</literalValue>
        <name>Set Status to Step1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Step2</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Step2</literalValue>
        <name>Set Status to Step2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Under_Review</fullName>
        <field>LLC_BI__Status__c</field>
        <literalValue>Under Review</literalValue>
        <name>Set Status to Under Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_loan_CIF</fullName>
        <field>Relationship_CIF__c</field>
        <formula>LLC_BI__Account__r.LLC_BI__lookupKey__c</formula>
        <name>Set loan CIF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_is_Boarding_Notification</fullName>
        <field>LLC_BI__MailerTeamKey__c</field>
        <formula>&quot;StageBoarding&quot;</formula>
        <name>Stage is Boarding Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LLC_BI__Alert on Lead Converted into Loan</fullName>
        <actions>
            <name>LLC_BI__Notify_Roles_of_Lead_Conversion_into_Loan</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__isConvert__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__HMDA Record Type Check</fullName>
        <actions>
            <name>LLC_BI__Update_HMDA_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the HMDA Record Type field based on the current date</description>
        <formula>TODAY()  &gt;=  DATE(2018,01,01)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Closing Alert</fullName>
        <actions>
            <name>LLC_BI__Loan_Closing_E_mail_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LLC_BI__Update_isClosed_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Closed Funded</value>
        </criteriaItems>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__isClosed__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>When a loan is set to &quot;Closed Funded&quot; (Update for equivalent) send out the loan closing e-mail alert.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan In Closing Stages</fullName>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Closing</value>
        </criteriaItems>
        <description>Notify respective loan administration / closers and loan team that the loan was moved to closing.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Set Balloon Indicator</fullName>
        <actions>
            <name>LLC_BI__Loan_Balloon_Indicator_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Loan Balloon indicator when the Amortization Period (Months) and the Term (Months) are different.</description>
        <formula>AND( ISPICKVAL(LLC_BI__Balloon_Product_Structure__c, &apos;&apos;),   OR ( ISCHANGED( LLC_BI__Amortized_Term_Months__c ) , ISCHANGED( LLC_BI__Term_Months__c )),   (LLC_BI__Amortized_Term_Months__c &lt;&gt;  LLC_BI__Term_Months__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Un-set Balloon Indicator</fullName>
        <actions>
            <name>LLC_BI__Loan_Balloon_Indicator_Unset</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Un-set the Loan Balloon indicator when the Amortization Period (Months) and the Term (Months) are the same.</description>
        <formula>AND( ISPICKVAL(LLC_BI__Balloon_Product_Structure__c, &apos;&apos;), OR ( ISCHANGED( LLC_BI__Amortized_Term_Months__c ) , ISCHANGED( LLC_BI__Term_Months__c )),  OR(IF(OR( ISBLANK(LLC_BI__Amortized_Term_Months__c), ISBLANK(LLC_BI__Term_Months__c)) , True, False),  (LLC_BI__Amortized_Term_Months__c  =  LLC_BI__Term_Months__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Was Lost</fullName>
        <actions>
            <name>LLC_BI__Loan_Lost_MTK</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Status__c</field>
            <operation>equals</operation>
            <value>Withdrawn</value>
        </criteriaItems>
        <description>When a loan stage is complete and the status is lost</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Withdrawn %2F Declined</fullName>
        <actions>
            <name>LLC_BI__Alert_Loan_Withdrawn_Declined</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Status__c</field>
            <operation>equals</operation>
            <value>Withdrawn,Declined</value>
        </criteriaItems>
        <description>Notify appropriate individuals / department (loan ops)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Loan Withdrawn Declined Product Package</fullName>
        <actions>
            <name>LLC_BI__IsOriginalDeclinedLoan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Status__c</field>
            <operation>equals</operation>
            <value>Withdrawn,Paid Out,Declined</value>
        </criteriaItems>
        <description>Sets the original declined loan field when a loan is loaded with declined or withdrawn status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Notify Loan Stage Change</fullName>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Loan Committee,Credit Underwriting,Processing,Doc Review,Doc Prep,Closing</value>
        </criteriaItems>
        <description>Based on the criteria, notify the loan team that the loan stage has been changed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__On Closed Set isClosed</fullName>
        <actions>
            <name>LLC_BI__Update_isClosed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Closed Funded</value>
        </criteriaItems>
        <description>For simpler reporting purposes, if the loan has been closed at any point, set isClosed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Reviewed By Quality</fullName>
        <actions>
            <name>LLC_BI__Notify_Loan_Reviewed_by_Quality_Compliance</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Reviewed_by_Compliance__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Loan has been reviewed by compliance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Set Payoff Date</fullName>
        <actions>
            <name>LLC_BI__Set_Payoff_Date_on_Paid_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Status__c</field>
            <operation>equals</operation>
            <value>Paid Out</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Stage Change to Compliance</fullName>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Compliance</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notEqual</operation>
            <value>Compliance</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LLC_BI__Update UCC Dates</fullName>
        <actions>
            <name>LLC_BI__UCC_Update_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LLC_BI__Update_UCC_County</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Stage__c</field>
            <operation>equals</operation>
            <value>Closed Funded,Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Loan is Approved</fullName>
        <actions>
            <name>Loan_is_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers team key alert notification</description>
        <formula>AND(
ISCHANGED(LLC_BI__Stage__c),
TEXT(PRIORVALUE(LLC_BI__Stage__c)) = &apos;Approval/Loan Committee&apos;,
ISPICKVAL(LLC_BI__Stage__c, &apos;Processing&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Loan is rejected</fullName>
        <actions>
            <name>Loan_is_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers team key alert notification</description>
        <formula>AND(
ISCHANGED(LLC_BI__Stage__c),
TEXT(PRIORVALUE(LLC_BI__Stage__c)) = &apos;Approval/Loan Committee&apos;,
ISPICKVAL(LLC_BI__Stage__c, &apos;Final Review&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Renewal or Mod Created</fullName>
        <actions>
            <name>Clear_PL_Loan_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__Is_Modification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>LLC_BI__Loan__c.LLC_BI__isRenewal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>PrecisionLender workflow rule</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Application Date</fullName>
        <actions>
            <name>Set_Application_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets application date when stage is advanced to credit underwriting</description>
        <formula>AND(
ISCHANGED(LLC_BI__Stage__c),
TEXT(PRIORVALUE(LLC_BI__Stage__c)) = &apos;Qualification&apos;,
ISPICKVAL(LLC_BI__Stage__c, &apos;Credit Underwriting&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set CIF Number</fullName>
        <actions>
            <name>Set_loan_CIF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Pulls CIF from relationship record in legal entities and populates CIF number on loan</description>
        <formula>NOT(ISBLANK(LLC_BI__Account__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Default App for Loan UI</fullName>
        <actions>
            <name>Set_Default_App_for_Loan_UI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISNEW(),
OR(
ISPICKVAL(LLC_BI__Product_Line__c, &quot;Commercial&quot;),
ISPICKVAL(LLC_BI__Product_Line__c, &quot;SBA&quot;),
ISPICKVAL(LLC_BI__Product_Line__c, &quot;Private Client&quot;)
)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Default Stage%2FStatus</fullName>
        <actions>
            <name>Set_Stage_to_Qualification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_to_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LLC_BI__Loan__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Sets the stage to qualification for new loans</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Boarding Notification</fullName>
        <actions>
            <name>Stage_is_Boarding_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers team key alert notification</description>
        <formula>AND(
ISCHANGED(LLC_BI__Stage__c),
TEXT(PRIORVALUE(LLC_BI__Stage__c)) = &apos;Doc Prep&apos;,
ISPICKVAL(LLC_BI__Stage__c, &apos;Boarding&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Final Review Notification</fullName>
        <actions>
            <name>Final_Review_Team_Key_Trigger</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers team key alert notification</description>
        <formula>AND(
ISCHANGED(LLC_BI__Stage__c),
TEXT(PRIORVALUE(LLC_BI__Stage__c)) = &apos;Credit Underwriting&apos;,
ISPICKVAL(LLC_BI__Stage__c, &apos;Final Review&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
