public with sharing class CSA_LookupkeyGeneratorConfigController {
    public String successMessage {get;Set;}
    public String errorMessage {get;Set;}

    public Boolean getIsInstalled() {
        List<nFORCE__System_Properties__c> property = this.getProperty(PROPERTYCATEGORY, PROPERTYKEY);
        if (property.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    public void install() {
        try {
            new CSA_LookupkeyGeneratorDataInstaller().onInstall(null);
            this.successMessage = System.Label.LG_Config_Success_Install;
        } catch (Exception ex) {
            this.errorMessage = ex.getMessage();
        }
    }

    public void uninstall() {
        try {
            new CSA_LookupkeyGeneratorDataInstaller().onUninstall(null);
            this.successMessage = System.Label.LG_Config_Success_Uninstall;
        } catch (Exception ex) {
            this.errorMessage = ex.getMessage();
        }
    }

    public PageReference finish() {
        PageReference pageRef = new PageReference(INSTALLEDPACKAGEURL);
        return pageRef;
    }

    private List<nFORCE__System_Properties__c> getProperty(String category, String key) {
        return [SELECT
                    Id
                FROM
                    nFORCE__System_Properties__c
                WHERE
                    nFORCE__Category_Name__c = :category
                AND
                    nFORCE__Key__c = :key];
    }

    private static final String
            INSTALLEDPACKAGEURL= '/0A3',
            PROPERTYCATEGORY = 'CSA Lookupkey Generator',
            PROPERTYKEY = 'Lookupkey Generator Data Installer';
}