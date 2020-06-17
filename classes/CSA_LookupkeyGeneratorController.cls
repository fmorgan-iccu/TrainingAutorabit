public with sharing class CSA_LookupkeyGeneratorController {
    public List<sObject> records {get;set;}
    public String errorMessage {get;Set;}
    public String object_api {get;set;}
    public string record_id {get;set;}

    public CSA_LookupkeyGeneratorController() {}

    public void buildAllKeys() {
        for(sObject r: records) {
            if(r.getSObjectType().getDescribe().name.contains(NFORCENAMESPACE)) {
                r.put(NFORCELOOKUPKEYFIELDAPI, generateRandomString(18));
            } else if(r.getSObjectType().getDescribe().name.contains(LLCBINAMESPACE)) {
                r.put(LLCBILOOKUPKEYFIELDAPI, generateRandomString(18));
            } else if(r.getSObjectType().getDescribe().name.contains(NDESIGNNAMESPACE)) {
                r.put(NDESIGNLOOKUPKEYFIELDAPI, generateRandomString(18));
            }
        }

        Database.update(records);
        this.findRecords();
    }

    public void buildKey() {
        sObject record = Schema.getGlobalDescribe().get(object_api).newSObject();
        String nforce_query = SELECTIFLOOKUPNFORCE + object_api + WHEREIDFIELD + record_id + EXTRAAPOSTRPHE;
        String llcbi_query = SELECTIFLOOKUPLLCBI + object_api + WHEREIDFIELD + record_id + EXTRAAPOSTRPHE;
        String ndesign_query = SELECTIFLOOKUPNDESIGN + object_api + WHEREIDFIELD + record_id + EXTRAAPOSTRPHE;
        try {
            if(this.object_api.contains(NFORCENAMESPACE)) {
                record = Database.query(nforce_query);
                record.put(NFORCELOOKUPKEYFIELDAPI, generateRandomString(18));
            } else if(this.object_api.contains(LLCBINAMESPACE)) {
                record = Database.query(llcbi_query);
                record.put(LLCBILOOKUPKEYFIELDAPI, generateRandomString(18));
            } else if(this.object_api.contains(NDESIGNNAMESPACE)) {
                record = Database.query(ndesign_query);
                record.put(NDESIGNLOOKUPKEYFIELDAPI, generateRandomString(18));
            }

            Database.update(record);

            for(Integer i = 0; i < this.records.size(); i++) {
                if(this.records[i].get(IDFIELDAPI) == record_id) {
                    this.records.remove(i);
                }
            }
        } catch (exception ex) {
            errorMessage = ex.getMessage();
        }
    }

    public void findRecords() {
        this.records = new List<sObject>();
        String query_string = SELECTIDNAME;
        if(this.object_api.contains(NFORCENAMESPACE)) {
            query_string += this.object_api + NFORCELOOKUPWHERE;
        } else if(this.object_api.contains(LLCBINAMESPACE)) {
            query_string += this.object_api + LLCBILOOKUPWHERE;
        } else if(this.object_api.contains(NDESIGNNAMESPACE)) {
            query_string += this.object_api + NDESIGNLOOKUPWHERE;
        }

        this.records = Database.query(query_string);
    }

    public static String generateRandomString(Integer len) {
        final String chars = NUMBERSFORRANDOMIZER;
        String randStr = BLANK;
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public List<SelectOption> getAvailbleObjects() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(BLANK, BLANK));
        options.add(new SelectOption(BUDGETAPI, getLabelName(BUDGETAPI), true));
        options.add(new SelectOption(BUDGETLINEITEMAPI, getLabelName(BUDGETLINEITEMAPI), true));
        options.add(new SelectOption(CONFIGKEYAPI, getLabelName(CONFIGKEYAPI)));
        options.add(new SelectOption(CONFIGVALUEAPI, getLabelName(CONFIGVALUEAPI)));
        options.add(new SelectOption(CLOSINGCHECKLISTAPI, getLabelName(CLOSINGCHECKLISTAPI)));
        options.add(new SelectOption(COLLATERALTYPEAPI, getLabelName(COLLATERALTYPEAPI), true));
        options.add(new SelectOption(CONNECTIONROLEAPI, getLabelName(CONNECTIONROLEAPI), true));
        options.add(new SelectOption(COVENANTTYPEAPI, getLabelName(COVENANTTYPEAPI), true));
        options.add(new SelectOption(CREDITMEMOAPI, getLabelName(CREDITMEMOAPI)));
        options.add(new SelectOption(DOCCLASSAPI, getLabelName(DOCCLASSAPI)));
        options.add(new SelectOption(DOCMANAGERAPI, getLabelName(DOCMANAGERAPI)));
        options.add(new SelectOption(DOCTABAPI, getLabelName(DOCTABAPI)));
        options.add(new SelectOption(DOCTYPEAPI, getLabelName(DOCTYPEAPI)));
        options.add(new SelectOption(FIELMAPAPI, getLabelName(FIELMAPAPI)));
        options.add(new SelectOption(GROUPAPI, getLabelName(GROUPAPI)));
        options.add(new SelectOption(LAYOUTAPI, getLabelName(LAYOUTAPI)));
        options.add(new SelectOption(OPTIONAPI, getLabelName(OPTIONAPI), true));
        options.add(new SelectOption(OPTIONRULEAPI, getLabelName(OPTIONRULEAPI), true));
        options.add(new SelectOption(POLICYEXCEPTIONMITIGATIONREASONAPI, getLabelName(POLICYEXCEPTIONMITIGATIONREASONAPI)));
        options.add(new SelectOption(POLICYEXCEPTIONTEMPLATEAPI, getLabelName(POLICYEXCEPTIONTEMPLATEAPI)));
        options.add(new SelectOption(PRODUCTAPI, getLabelName(PRODUCTAPI)));
        options.add(new SelectOption(PRODUCTFEATURE, getLabelName(PRODUCTFEATURE)));
        options.add(new SelectOption(PRODUCTLINEAPI, getLabelName(PRODUCTLINEAPI)));
        options.add(new SelectOption(PRODUCTSTATECONFIGAPI, getLabelName(PRODUCTSTATECONFIGAPI)));
        options.add(new SelectOption(PRODUCTTYPEAPI, getLabelName(PRODUCTTYPEAPI)));
        options.add(new SelectOption(RATEAPI, getLabelName(RATEAPI), true));
        options.add(new SelectOption(QUESTIONAPI, getLabelName(QUESTIONAPI), true));
        options.add(new SelectOption(RISKGRADEFACTORAPI, getLabelName(RISKGRADEFACTORAPI)));
        options.add(new SelectOption(RICKGRADEGROUPAPI, getLabelName(RICKGRADEGROUPAPI)));
        options.add(new SelectOption(RICKGRADETEMPLATEAPI, getLabelName(RICKGRADETEMPLATEAPI)));
        options.add(new SelectOption(RISKGRADECRITERIAAPI, getLabelName(RISKGRADECRITERIAAPI)));
        options.add(new SelectOption(ROLEAPI, getLabelName(ROLEAPI), true));
        options.add(new SelectOption(ROUTEAPI, getLabelName(ROUTEAPI)));
        options.add(new SelectOption(ROUTEGROUPAPI, getLabelName(ROUTEGROUPAPI)));
        options.add(new SelectOption(RULEENGINECONTEXTAPI, getLabelName(RULEENGINECONTEXTAPI)));
        options.add(new SelectOption(RULEENGINERULEAPI, getLabelName(RULEENGINERULEAPI), true));
        options.add(new SelectOption(SCREENAPI, getLabelName(SCREENAPI)));
        options.add(new SelectOption(SCREENSECTIONAPI, getLabelName(SCREENSECTIONAPI)));
        options.add(new SelectOption(VIEWAPI, getLabelName(VIEWAPI)));
        options.add(new SelectOption(SECTIONCONFIGURATIONAPI, getLabelName(SECTIONCONFIGURATIONAPI)));
        options.add(new SelectOption(SPREADSTATEMENTRECORDAPI, getLabelName(SPREADSTATEMENTRECORDAPI)));
        options.add(new SelectOption(SPREADSTATEMENTRECORDTOTAL, getLabelName(SPREADSTATEMENTRECORDTOTAL)));
        options.add(new SelectOption(SPREADSTATEMENTTYPEAPI, getLabelName(SPREADSTATEMENTTYPEAPI)));
        options.add(new SelectOption(TEAMAPI, getLabelName(TEAMAPI), true));
        options.add(new SelectOption(TEAMKEYSAPI, getLabelName(TEAMKEYSAPI), true));
        options.add(new SelectOption(TEMPLATERECORDSAPI, getLabelName(TEMPLATERECORDSAPI), true));
        options.add(new SelectOption(UNDERWRITINGBUNDLEAPI, getLabelName(UNDERWRITINGBUNDLEAPI)));
        options.add(new SelectOption(WIDGETAPI, getLabelName(WIDGETAPI)));
        options.add(new SelectOption(NDESIGNLAYOUTAPI, getLabelName(NDESIGNLAYOUTAPI)));
        options.add(new SelectOption(NDESIGNSCREENAPI, getLabelName(NDESIGNSCREENAPI)));
        options.add(new SelectOption(NDESIGNSCREENSECTIONAPI, getLabelName(NDESIGNSCREENSECTIONAPI)));
        options.add(new SelectOption(NDESIGNSCREENVIEWAPI, getLabelName(NDESIGNSCREENVIEWAPI)));
        options.add(new SelectOption(NDESIGNSECTIONCONFIGURATIONAPI, getLabelName(NDESIGNSECTIONCONFIGURATIONAPI)));
        options.add(new SelectOption(NDESIGNWIDGETAPI, getLabelName(NDESIGNWIDGETAPI)));
        return options;
    }

    private String getLabelName(String apiName) {
        DescribeSObjectResult[] describeSObjectResult = schema.describeSObjects(new String[] { apiName });
        return describeSObjectResult[0].getLabelPlural();
    }

    private static final String
            NUMBERSFORRANDOMIZER = '0123456789',
            BLANK = '',
            LLCBINAMESPACE = 'LLC_BI',
            NFORCENAMESPACE = 'nFORCE',
            NDESIGNNAMESPACE = 'nDESIGN',
            NFORCELOOKUPKEYFIELDAPI = 'nFORCE__lookupKey__c',
            LLCBILOOKUPKEYFIELDAPI = 'LLC_BI__lookupKey__c',
            NDESIGNLOOKUPKEYFIELDAPI = 'nDESIGN__lookupKey__c',
            IDFIELDAPI = 'Id',
            WHEREIDFIELD = ' WHERE Id = \'',
            EXTRAAPOSTRPHE = '\'',
            SELECTIFLOOKUPNFORCE = 'SELECT Id, nFORCE__lookupKey__c FROM ',
            SELECTIFLOOKUPLLCBI = 'SELECT Id, LLC_BI__lookupKey__c FROM ',
            SELECTIFLOOKUPNDESIGN = 'SELECT Id, nDESIGN__lookupKey__c FROM ',
            SELECTIDNAME = 'SELECT Id, Name FROM ',
            NFORCELOOKUPWHERE = ' WHERE nFORCE__lookupKey__c = \'\'',
            LLCBILOOKUPWHERE = ' WHERE LLC_BI__lookupKey__c = \'\'',
            NDESIGNLOOKUPWHERE = ' WHERE nDESIGN__lookupKey__c = \'\'',
            BUDGETAPI = 'LLC_BI__Budget__c',
            BUDGETLINEITEMAPI = 'LLC_BI__Budget_Line_Item__c',
            CONFIGKEYAPI = 'LLC_BI__CFG_ConfigKey__c',
            CONFIGVALUEAPI = 'LLC_BI__CFG_ConfigValue__c',
            CLOSINGCHECKLISTAPI = 'LLC_BI__ClosingChecklist__c',
            COLLATERALTYPEAPI = 'LLC_BI__Collateral_Type__C',
            CONNECTIONROLEAPI = 'LLC_BI__Connection_Role__c',
            COVENANTTYPEAPI = 'LLC_BI__Covenant_Type__c',
            CREDITMEMOAPI = 'LLC_BI__Credit_Memo__c',
            DOCCLASSAPI = 'LLC_BI__DocClass__c',
            DOCMANAGERAPI = 'LLC_BI__DocManager__c',
            DOCTABAPI = 'LLC_BI__DocTab__c',
            DOCTYPEAPI = 'LLC_BI__DocType__c',
            FIELMAPAPI = 'LLC_BI__Field_Map__c',
            GROUPAPI = 'nFORCE__Group__c',
            LAYOUTAPI = 'nFORCE__Layout__c',
            OPTIONAPI = 'nFORCE__Option__c',
            OPTIONRULEAPI = 'nFORCE__Option_Rule__c',
            POLICYEXCEPTIONMITIGATIONREASONAPI = 'LLC_BI__Policy_Exception_Mitigation_Reason__c',
            POLICYEXCEPTIONTEMPLATEAPI = 'LLC_BI__Policy_Exception_Template__c',
            PRODUCTAPI = 'LLC_BI__Product__c',
            PRODUCTFEATURE = 'LLC_BI__Product_Feature__c',
            PRODUCTLINEAPI = 'LLC_BI__Product_Line__c',
            PRODUCTSTATECONFIGAPI = 'LLC_BI__Product_State_Config__c',
            PRODUCTTYPEAPI = 'LLC_BI__Product_Type__c',
            RATEAPI = 'LLC_BI__Rate__c',
            QUESTIONAPI = 'nFORCE__Question__c',
            RISKGRADEFACTORAPI = 'LLC_BI__Risk_Grade_Factor__c',
            RICKGRADEGROUPAPI = 'LLC_BI__Risk_Grade_Group__c',
            RICKGRADETEMPLATEAPI = 'LLC_BI__Risk_Grade_Template__c',
            RISKGRADECRITERIAAPI = 'LLC_BI__Risk_Grade_Criteria__c',
            ROLEAPI = 'LLC_BI__Role__c',
            ROUTEAPI = 'nFORCE__Route__c',
            ROUTEGROUPAPI = 'nFORCE__Route_Group__c',
            RULEENGINECONTEXTAPI = 'nFORCE__Rule_Engine_Context__c',
            RULEENGINERULEAPI = 'nFORCE__Rule_Engine_Rule__c',
            SCREENAPI = 'nFORCE__Screen__c',
            SCREENSECTIONAPI = 'nFORCE__Screen_Section__c',
            VIEWAPI = 'nFORCE__View__c',
            SECTIONCONFIGURATIONAPI = 'nFORCE__Section_Configuration__c',
            SPREADSTATEMENTRECORDAPI = 'LLC_BI__Spread_Statement_Record__c',
            SPREADSTATEMENTRECORDTOTAL = 'LLC_BI__Spread_Statement_Record_Total__c',
            SPREADSTATEMENTTYPEAPI = 'LLC_BI__Spread_Statement_Type__c',
            TEAMAPI = 'LLC_BI__Team__c',
            TEAMKEYSAPI = 'LLC_BI__Team_Keys__c',
            TEMPLATERECORDSAPI = 'LLC_BI__Template_Records__c',
            UNDERWRITINGBUNDLEAPI = 'LLC_BI__Underwriting_Bundle__c',
            WIDGETAPI = 'nFORCE__Widget__c',
            NDESIGNLAYOUTAPI = 'nDESIGN__Layout__c',
            NDESIGNSCREENAPI = 'nDESIGN__Screen__c',
            NDESIGNSCREENSECTIONAPI = 'nDESIGN__Screen_Section__c',
            NDESIGNSCREENVIEWAPI = 'nDESIGN__View__c',
            NDESIGNSECTIONCONFIGURATIONAPI = 'nDESIGN__Section_Configuration__c',
            NDESIGNWIDGETAPI = 'nDESIGN__Widget__c';
}