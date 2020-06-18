public without sharing class CTIGadgetController {

    // Identifies one or more contacts that were identified to match the inbound call.
    public List<Contact> contacts {
        get {
            if (contacts == null) {
                contacts = new List<Contact>();
            }
            return contacts;
        }
        set;
       }

    // Identifies the digits that identify the caller in the Cisco phone system.
    public String ani { get; set; }

    // Captures the lookup value that was keyed by the member in the IVR tree to identify their account.
    public String lookup { get; set; }

    // The Id and name of the member Contact record, if found.
    public Id contactId { get; set; }
    public String contactName { get; set; }

    // The Id and name of the employee User record, if found.
    public Id userId { get; set; }
    public String userName { get; set; }

    // Captures the method that was used to identify the member.
    public String lookupMethod { get; set; }

    // If a new case is created, this will store its Id
    public Id newCaseId { get; set; }

    // Used to track the Id of the task created by the B+S gadget for the call.
    public Id callId { get; set; }

    // If an error message should be shown to the user, this will be set
    public String errorMessage { get; set; }


    /**
     * The Bucher + Suter phone gadget uses an embedded VisualFore page that uses this controller.  It will receive the
     * ANI (phone number/extension) and a lookup value that is entered by the member calling in.  This lookup value is
     * likely the member number or last 4 of the SSN that can be used to reduce duplicate records.
     */
    public void findInboundCallContact() {
        // Initialize the values to prevent anything from carrying over from the previous call.
        this.contactId = null;
        this.contactName = '';
        this.userId = null;
        this.userName = '';
        this.lookupMethod = null;
        this.newCaseId = null;
        this.errorMessage = '';

        // Retrieve just the digits of the phone number to match the DNA import format.
        String phone = PhoneUtils.formatDigitsOnly(this.ani);


        // Format the phone number in the Salesforce standard format to ensure that records that may be updated
        // via the standard flow are found.
        String formattedPhone = PhoneUtils.format(phone);

        try {
            // Identify the DNA record type and only pop those members that match. This was required because the
            // MCC agents don't have access to the Default record type.  Matching a Default record would cause the
            // new case to be assigned to the agent and associated to an account that they didn't have access to.
            Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();

            // If the phone number is not an extension (4/5 digits), then look up the appropriate Contact record.
            // Otherwise, an employee record will be identified.
            if (phone.length() > 5) {
                // Attempt to identify a unique member using the incoming ANI (aka phone) that matches the cell phone of the contact
                contacts = [
                    SELECT id,
                        name
                    FROM Contact
                    WHERE (mobilePhone = :phone
                            OR mobilePhone = :formattedPhone)
                        AND recordTypeId = :contactRecordTypeId
                    ORDER BY createddate ASC
                    LIMIT 2
                ];
                if (contacts.size() == 1) lookupMethod = 'Mobile Phone';

                // Attempt to identify a unique member using the cell phone and the lookup value.
                if (contacts.size() != 1) {
                    contacts = [
                        SELECT id,
                            name
                        FROM Contact
                        WHERE (mobilePhone = :phone
                                OR mobilePhone = :formattedPhone)
                            AND memberNumber__c = :this.lookup
                            AND recordTypeId = :contactRecordTypeId
                        ORDER BY createddate ASC
                        LIMIT 2
                    ];
                    if (contacts.size() == 1) lookupMethod = 'Mobile Phone and Member Number';
                }

                // Attempt to identify a unique member using any phone number on the contact only.
                if (contacts.size() != 1) {
                    contacts = [
                        SELECT id,
                            name
                        FROM Contact
                        WHERE (mobilePhone = :phone
                                OR mobilePhone = :formattedPhone
                                OR phone = :phone
                                OR phone = :formattedPhone
                                OR otherPhone = :phone
                                OR otherPhone = :formattedPhone
                                OR businessPhone__c = :phone
                                OR businessPhone__c = :formattedPhone)
                            AND recordTypeId = :contactRecordTypeId
                        ORDER BY createddate ASC
                        LIMIT 2
                    ];
                    if (contacts.size() == 1) lookupMethod = 'All Phones';
                }

                // Attempt to identify a unique member using any phone number on the contact and the lookup value.
                if (contacts.size() != 1) {
                    contacts = [
                        SELECT id,
                            name
                        FROM Contact
                        WHERE (mobilePhone = :phone
                                OR mobilePhone = :formattedPhone
                                OR phone = :phone
                                OR phone = :formattedPhone
                                OR otherPhone = :phone
                                OR otherPhone = :formattedPhone
                                OR businessPhone__c = :phone
                                OR businessPhone__c = :formattedPhone)
                            AND memberNumber__c = :this.lookup
                            AND recordTypeId = :contactRecordTypeId
                        ORDER BY createddate ASC
                        LIMIT 2
                    ];
                    if (contacts.size() == 1) lookupMethod = 'All Phones and Member Number';
                }

                // Attempt to identify a unique member using the lookup value only.
                if (contacts.size() != 1) {
                    contacts = [
                        SELECT id,
                            name
                        FROM Contact
                        WHERE memberNumber__c = :this.lookup
                            AND recordTypeId = :contactRecordTypeId
                        ORDER BY createddate ASC
                        LIMIT 2
                    ];
                    if (contacts.size() == 1) lookupMethod = 'Member Number';
                }

                // When a single contact record is found in the system that matches the provided information...
                if (contacts.size() == 1) {
                    // Record the Contact Id that will be popped for the agent.  Trim the entity name to prevent overflow in the gadget.
                    this.contactId = contacts[0].Id;
                    this.contactName = contacts[0].Name.left(20);

                    // Determine is the current user's profile should have auto-created cases.
                    Id userProfileId = UserInfo.getProfileId();
                    List<Profile> profiles = [
                        SELECT id,
                            name
                        FROM Profile
                        WHERE id = :userProfileId
                    ];
                    Boolean autoCreateCase = profiles.size() > 0
                        && (profiles[0].name == 'RUL - MCC'
                            || profiles[0].name == 'RUL - MCC Supervisor');

                    // For the MCC, create a new case as applicable.
                    if (autoCreateCase) {
                        // Determine if there is one or more open cases for this member.
                        List<Case> openCases = [
                            SELECT id
                            FROM Case
                            WHERE contactId = :this.contactId
                                AND isClosed = false
                            LIMIT 1
                        ];

                        // If there are no open cases found, create a new case assigned to the agent and associated to the contact.
                        if (openCases.size() == 0) {
                            // Identify the user that is currently logged in that will own the case.
                            Id caseOwnerId = UserInfo.getUserId();

                            // Identify the ID of the "Default" case type that will be used.
                            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeConstants.CASE_MEMBER_SUPPORT).getRecordTypeId();

                            // Create the case associated with this new member contact assigned to the current user.  If a case
                            // can't be created, record the error to the debug log.  The error message is not assigned because it
                            // would prevent the contact record from being popped, which is much more important.
                            try {
                                Case caseForCall = new Case(
                                    ContactId = this.contactId,
                                    OwnerId = caseOwnerId,
                                    Status = 'Open',
                                    RecordTypeId = caseRecordTypeId,
                                    Origin = 'Phone'
                                );
                                insert caseForCall;
                                this.newCaseId = caseForCall.Id;
                            } catch (Exception e) {
                                System.debug(LoggingLevel.ERROR, 'CTIGadgetController failed to create a case. ' + e.getMessage());
                            }
                        }
                    }

                      return;
                }
            } else {
                List<User> users = [
                    SELECT id,
                        name
                    FROM User
                    WHERE phone = :phone
                        OR extension = :phone
                    ORDER BY createddate ASC LIMIT 2
                ];
                if (users.size() == 1) {
                    this.userId = users[0].id;
                    this.userName = users[0].name;
                    return;
                }
            }
        } catch (Exception e) {
            this.errorMessage = 'CTI lookup failed: ' + e.getMessage();
        }
    }

    public void updateActivityWithCustomerId() {
        // Retrieve the call activity/task so that the system can check that the WhoId is set.
        List<Task> tasks = [
            SELECT id,
                whoId
            FROM Task
            WHERE id = :this.callId
            LIMIT 2
        ];

        // If the activity/task was found, update it with the appropriate call information.
        if (tasks.size() == 1) {
            tasks[0].whoId = tasks[0].whoId == null && this.contactId != null ? this.contactId : tasks[0].whoId;
            tasks[0].ctiLookupMethod__c = this.lookupMethod;
            tasks[0].ctiLookupValue__c = this.lookup;
            update tasks[0];
        }
    }

}