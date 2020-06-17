public class AOApplicantParser implements IAOPayloadParser {
    
    public void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        if (appInfo == null || payload == null) {
            return;
        }
        
        if (appInfo.isYouthApplication != null && appInfo.isYouthApplication == true) {
            this.parseYouthPayload(payload, appInfo);
        } else {
            AOConstants.FormXmlVersion xmlVersion = (AOConstants.FormXmlVersion)payload.get(AOConstants.XML_VERSION);
            switch on xmlVersion {
                when V1 {
                    parsePayloadV1(payload, appInfo);
                }
                when V2 {
                    parsePayloadV2(payload, appInfo);
                }
                when else {
                    parsePayloadDefault(payload, appInfo);
                }
            }
        }
    }
    public void parsePayloadV1(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadV2(Map<String, Object> payload, AOApplicationInfo appInfo) {
		parsePayloadDefault(payload, appInfo);
    }

    public void parsePayloadDefault(Map<String, Object> payload, AOApplicationInfo appInfo) {
    	// There are potentially two nodes provided in the payload.  The first is the main applicant node
		// and has the most complete information about the applicant.  This should be used if there is 
		// data present.

        Dom.XmlNode applicantNode = (Dom.XmlNode)payload.get(AOConstants.XML_APPLICANT_KEY);
        Dom.XmlNode applicantDetailsNode = applicantNode.getChildElement('Contact', applicantNode.getNamespace());

		// Determine if the AvokaSmartForm/Applicant/Contact node should be used or the AvokaSmartForm/Triage/Applicant.
		List<Dom.XmlNode> contactDetailNodes = null;
		String nodeName = null;
		String nodeText = null;
        
		if (appInfo.isJointApplication) {

		} else if (applicantDetailsNode != null) {
            // Determine if there are any child nodes of the Applicant/Contact that contain text.
        	Boolean useApplicantNode = false;
            contactDetailNodes = applicantDetailsNode.getChildElements();
            for (Dom.XmlNode detailNode : contactDetailNodes) {
                nodeText = detailNode.getText();
                if (nodeText != null && nodeText != '') {
                    useApplicantNode = true;
                    break;
                }
            }
            
            // If no nodes were found that contained text, use the Triage/Applicant node.
            if (!useApplicantNode) {
                applicantDetailsNode = (Dom.XmlNode)payload.get(AOConstants.XML_TRIAGE_APPLICANT_KEY);
            }
        }

        if (applicantDetailsNode != null) {
			contactDetailNodes = applicantDetailsNode.getChildElements();

			// Extract the contact specific information into the application info object.        
			for (Dom.XmlNode detailNode : contactDetailNodes) {
				nodeName = detailNode.getName();
				nodeText = detailNode.getText();

				switch on nodeName {
					when 'PersonNumber' {
						appInfo.personNumber = nodeText;
					}
					when 'Ssn' {
						appInfo.taxId = nodeText;
					}
					when 'FirstName' {
						appInfo.firstName = nodeText;
					}
					when 'LastName' {
						appInfo.lastName = nodeText;
					}
					when 'Email' {
						appInfo.email = nodeText;
					}
					when 'Phone' {
						appInfo.phone = PhoneUtils.format(nodeText);
					}
					when 'MobilePhone' {
						appInfo.mobilePhone = PhoneUtils.format(nodeText);
					}
					when 'WorkPhone' {
						appInfo.workPhone = PhoneUtils.format(nodeText);
					}
					when 'DateOfBirth' {
                        appInfo.birthDate = this.parseDate(detailNode);
					}
					when 'IDNumber' {
						appInfo.idNumber = nodeText;
					}
					when 'IDType' {
						appInfo.idType = nodeText;
					}
					when 'IDIssueState' {
						appInfo.idIssueState = nodeText;
					}
					when 'IDIssueDate' {
						appInfo.idIssueDate = this.parseDate(detailNode);
					}
					when 'IDExpiryDate' {
						appInfo.idExpiryDate = this.parseDate(detailNode);
					}
					when 'MailingStreet' {
						appInfo.mailingStreet = nodeText;
					}
					when 'MailingStreet2' {
						appInfo.mailingStreet2 = nodeText;
					}
					when 'MailingCity' {
						appInfo.mailingCity = nodeText;
					}
					when 'MailingState' {
						appInfo.mailingState = nodeText;
					}
					when 'MailingPostalCode' {
						appInfo.mailingPostalCode = nodeText;
					}
					when 'MailingCountryCode' {
						appInfo.mailingCountryCode = nodeText;
					}
					when else {
                        // No match do nothing. Else block is not required, but recommended by sf
                        system.debug('Unexpected nodeName: ' + nodeName);                    
					}  
				}
			}
			
			// Access the newAccount node to get the applicant details.
			Dom.XmlNode newAccountNode = applicantNode.getChildElement('NewAccount', applicantNode.getNamespace()); 
			
			this.parseNewAccounts(newAccountNode, appInfo);
		} else {
			appInfo.addError('AOApplicantParser', 'Could not identify the applicant in the XML.');
		}
	}
    
    private void parseNewAccounts(Dom.XmlNode newAccount, AOApplicationInfo appInfo) {
        // new account is not always presnet
        if (newAccount == null) {
            return;
        }

        Dom.XmlNode[] items = newAccount.getChildElements();
        
        // Extract newAccount information into application info object 
        for (Dom.XmlNode itemNode : items) {
            Dom.XmlNode[] newAccountDetailNodes = itemNode.getChildElements();                
            DNAAccount newDnaAccount = new DNAAccount();
            
            for (Dom.XmlNode account : newAccountDetailNodes) {
                String nodeName = account.getName();
                String nodeText = account.getText();    
                
                switch on nodeName {
                    when 'AccountNumber' {
                        newDnaAccount.setAccountNumber(nodeText);
                    }
                    when 'MajorTypeCode' {
                        newDnaAccount.setMajorType(nodeText);
                    }
                    when 'MinorTypeCode' {
                        newDnaAccount.setMinorType(nodeText);   
                    }
                    when else {
                        // No match do nothing. Else block is not required, but recommended by sf
                        system.debug('Applicant new Accounts unexpected nodeName: ' + nodeName);                    
                    } 							
                }           
            }
            
            if (newDnaAccount.getAccountNumber() != null) {
                appInfo.newAccounts.add(newDnaAccount);                                               
            }
        }
    }
    
    private void parseYouthPayload(Map<String, Object> payload, AOApplicationInfo appInfo) {
        this.parseYouthDetails(payload, appInfo);
        this.parseGuardianDetails(payload, appInfo);
    }
    
    private void parseYouthDetails(Map<String, Object> payload, AOApplicationInfo appInfo) {
        Dom.XmlNode applicantNode = (Dom.XmlNode)payload.get(AOConstants.XML_YOUTH_APPLICANT_KEY);
        
        if (applicantNode == null) {
            System.debug('Did not find Youth Applicant details...');
            return;
        }
        
        Dom.XmlNode contactNode = applicantNode.getChildElement('Contact', applicantNode.getNamespace());
        
        if (contactNode == null) {
            System.debug('Unable to get Contact node of youth applicant.');
            return;
        }
        
        for (Dom.XmlNode detailNode : contactNode.getChildElements()) {
            String nodeName = detailNode.getName();
            
            switch on nodeName {
                when 'PersonNumber' {
                    appInfo.personNumber = detailNode.getText();
                }
                when 'Ssn' {
                    appInfo.taxId = detailNode.getText();
                }
                when 'FirstName' {
                    appInfo.firstName = detailNode.getText();
                }
                when 'LastName' {
                    appInfo.lastName = detailNode.getText();
                }
                when 'DateOfBirth' {
                    appInfo.birthDate = this.parseDate(detailNode);
                }
                when 'Email' {
                    appInfo.email = detailNode.getText();
                }
                when 'Phone' {
                    appInfo.phone = detailNode.getText();
                }
                when 'MobilePhone' {
                    appInfo.mobilePhone = detailNode.getText();
                }
                when 'WorkPhone' {
                    appInfo.workPhone = detailNode.getText();
                }
                when 'MailingStreet' {
                    appInfo.mailingStreet = detailNode.getText();
                }
                when 'MailingStreet2' {
                    appInfo.mailingStreet2 = detailNode.getText();
                }
                when 'MailingCity' {
                    appInfo.mailingCity = detailNode.getText();
                }
                when 'MailingState' {
                    appInfo.mailingState = detailNode.getText();
                }
                when 'MailingPostalCode' {
                    appInfo.mailingPostalCode = detailNode.getText();
                }
                when 'MailingCountryCode' {
                    appInfo.mailingCountryCode = detailNode.getText();
                }
                when 'IDNumber' {
                    appInfo.idNumber = detailNode.getText();
                }
                when 'IDIssueAuthority' {
                    appInfo.idIssueState = detailNode.getText();
                }
                when 'IDIssueDate' {
                    appInfo.idIssueDate = this.parseDate(detailNode);
                }
                when 'IDExpiryDate' {
                    appInfo.idExpiryDate = this.parseDate(detailNode);
                }
                when 'IDType' {
                    appInfo.idType = detailNode.getText();
                }
                when else {
                    // No match do nothing. Else block is not required, but recommended by sf
                    System.debug('Unexpected youth nodeName: ' + nodeName);
                }  
            }
        }
        
        Dom.XmlNode newAccountsNode = applicantNode.getChildElement('NewAccount', applicantNode.getNamespace());
        this.parseNewAccounts(newAccountsNode, appInfo);
    }
    
    private void parseGuardianDetails(Map<String, Object> payload, AOApplicationInfo appInfo) {
        Dom.XmlNode applicantNode = (Dom.XmlNode)payload.get(AOConstants.XML_GUARDIAN_APPLICANT_KEY);
        
        if (applicantNode == null) {
            System.debug('Did not find Guardian Applicant details...');
            return;
        }

        List<Dom.XmlNode> detailNodes = applicantNode.getChildElements();
        
        System.debug('About to iterate on the detail nodes for guardian.');
        
        for (Dom.XmlNode detailNode : detailNodes) {
            String nodeName = detailNode.getName();
            
            switch on nodeName {
                when 'PersonNumber' {
                    appInfo.guardianPersonNumber = detailNode.getText();
                }
                when 'ParentFName' {
                    appInfo.guardianFirstName = detailNode.getText();
                }
                when 'ParentLName' {
                    appInfo.guardianLastName = detailNode.getText();
                }
                when 'DateOfBirth' {
                    appInfo.guardianBirthDate = this.parseDate(detailNode);
                }
                when 'ParentSSN' {
                    appInfo.guardianTaxId = detailNode.getText();
                }
                when 'ContactInfo' {
                    for (Dom.XmlNode contactDetailNode : detailNode.getChildElements()) {
                        String contactNodeName = contactDetailNode.getName();
                        switch on contactNodeName {
                            when 'ParentEmail' {
                                appInfo.guardianEmail = contactDetailNode.getText();
                            }
                            when 'ParentHomePhone' {
                                appInfo.guardianPhone = contactDetailNode.getText();
                            }
                            when 'ParentMobilePhone' {
                                appInfo.guardianMobilePhone = contactDetailNode.getText();
                            }
                            when 'ParentWorkPhone' {
                                appInfo.guardianWorkPhone = contactDetailNode.getText();
                            }
                            when else {
                                System.debug('Guardian contact unexpected nodeName: ' + nodeName);
                            }
                        }
                    }
                }
                when 'Address' {
                    for (Dom.XmlNode addresDetailNode : detailNode.getChildElements()) {
                        String addressNodeName = addresDetailNode.getName();
                        switch on addressNodeName {
                            when 'ParentAddressLine1' {
                                appInfo.guardianMailingStreet = addresDetailNode.getText();
                            }
                            when 'ParentAddressLine2' {
                                appInfo.guardianMailingStreet2 = addresDetailNode.getText();
                            }
                            when 'ParentCity' {
                                appInfo.guardianMailingCity = addresDetailNode.getText();
                            }
                            when 'ParentState' {
                                appInfo.guardianMailingState = addresDetailNode.getText();
                            }
                            when 'ParentPostalCode' {
                                appInfo.guardianMailingPostalCode = addresDetailNode.getText();
                            }
                            when 'ParentCountryCode' {
                                appInfo.mailingCountryCode = detailNode.getText();
                            }
                            when else {
                                System.debug('Guardian address unexpected nodeName: ' + nodeName);
                            }
                        }
                    }
                }
                when 'DriversLicenseInfo' {
                    for (Dom.XmlNode idDetailNode : detailNode.getChildElements()) {
                        String addressNodeName = idDetailNode.getName();
                        switch on addressNodeName {
                            when 'IDNumber' {
                                appInfo.guardianIdNumber = idDetailNode.getText();
                            }
                            when 'IDIssueAuthority' {
                                appInfo.guardianIdIssueState = idDetailNode.getText();
                            }
                            when 'IDIssueDate' {
                                appInfo.guardianIdIssueDate = this.parseDate(idDetailNode);
                            }
                            when 'IDExpiryDate' {
                                appInfo.guardianIdExpiryDate = this.parseDate(idDetailNode);
                            }
                            when 'IDType' {
                                appInfo.guardianIdType = idDetailNode.getText();
                            }
                            when else {
                                System.debug('Guardian ID unexpected nodeName: ' + nodeName);
                            }
                        }
                    }

                }
                when else {
                    // No match do nothing. Else block is not required, but recommended by sf
                    System.debug('Guardian root unexpected nodeName: ' + nodeName);
                }  
            }
        }
    }
    
    private Date parseDate(Dom.XmlNode node) {
        if (node == null || node.getText() == '') {
            return null;
        }

        try {
            return Date.valueOf(node.getText());
        } catch(Exception e) {
            // DO NOTHING.  MOVE ON.
            return null;
        }	
    }

}