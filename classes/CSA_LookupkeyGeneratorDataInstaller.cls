global with sharing class CSA_LookupkeyGeneratorDataInstaller implements InstallHandler, UninstallHandler {
    global void onInstall(InstallContext context) {
       nFORCE__System_Properties__c property = this.getCreateSystemProperty(PROPERTYCATEGORY,
                                                                            true,
                                                                            PROPERTYKEY,
                                                                            PROPERTYVALUE);

        Database.insert(property);

        nForce__Route__c route = this.getCreateRoute(ROUTENAME,
                                                     ROUTEBODY,
                                                     ROUTEAPP,
                                                     ROUTENAVIGATION,
                                                     ROUTESUBNAV,
                                                     ROUTETOPBAR);

        Database.insert(route);

        Id adminGroupId = getAdminGroup().Id;

        List<nFORCE__Route_Group__c> newRouteGroups = new List<nFORCE__Route_Group__c>();
        newRouteGroups.add(getCreateRouteGroup(adminGroupId, route.Id, null, 100));
        newRouteGroups.add(getCreateRouteGroup(adminGroupId, route.Id, route.Id, 101));

        Database.insert(newRouteGroups);
    }

    global void onUninstall(UninstallContext context) {
        List<nForce__Route__c> routes = this.getRoutes(ROUTEBODY);
        List<nForce__Route_Group__c> routeGroups = new List<nForce__Route_Group__c>();

        if (!routes.isEmpty()) {
            routeGroups = this.getRouteGroups(routes);
            Database.delete(routeGroups);
            Database.delete(routes);
        }

        List<nFORCE__System_Properties__c> systemProperties = this.getSystemProperties(PROPERTYCATEGORY, PROPERTYKEY);

        if (!systemProperties.isEmpty()) {
            Database.delete(systemProperties);
        }
    }

    private nFORCE__Group__c getAdminGroup() {
        return [SELECT
                        Id
                FROM
                        nFORCE__Group__c
                WHERE
                        nFORCE__App__c = :GROUPAPP];
    }

    private List<nForce__Route__c> getRoutes(String body) {
        return [SELECT
                        Id
                FROM
                        nForce__Route__c
                WHERE
                        nForce__Body__c = :body];
    }

    private nForce__Route__c getCreateRoute(String name,
                                            String body,
                                            String app,
                                            String nav,
                                            String subNav,
                                            String topbar) {
        nForce__Route__c newR = new nForce__Route__c(
                Name = name,
                nFORCE__Body__c = body,
                nForce__App__c = app,
                nFORCE__lookupKey__c = generateRandomString(18),
                nFORCE__Navigation__c = nav,
                nFORCE__Sub_Navigation__c = subnav,
                nFORCE__Topbar__c = topbar);

        return newR;
    }

    private List<nFORCE__Route_Group__c> getRouteGroups(List<nForce__Route__c> routes) {
        String[] ids = new List<String>();
        for (nForce__Route__c r: routes) {
            ids.add(r.Id);
        }

        return [SELECT
                        Id,
                        nForce__Route__c
                FROM
                        nFORCE__Route_Group__c
                WHERE
                        nForce__Route__c IN :ids];
    }

    private nFORCE__Route_Group__c getCreateRouteGroup(Id adminGroup,
                                                       Id route,
                                                       Id parentRoute,
                                                       Decimal dOrder) {
        nFORCE__Route_Group__c newRG = new nFORCE__Route_Group__c(
                nFORCE__Group__c = adminGroup,
                nFORCE__lookupKey__c = generateRandomString(18),
                nFORCE__Order__c = dOrder,
                nFORCE__Parent_Route__c = parentRoute,
                nFORCE__Route__c = route);

        return newRG;
    }

    private List<nFORCE__System_Properties__c> getSystemProperties(String category, String key) {
        return [SELECT
                    Id
                FROM
                    nFORCE__System_Properties__c
                WHERE
                    nFORCE__Category_Name__c = :category
                AND
                    nFORCE__Key__c = :key];
    }

    private nFORCE__System_Properties__c getCreateSystemProperty(String category,
            Boolean active,
            String key,
            String value) {
        nFORCE__System_Properties__c newSP = new nFORCE__System_Properties__c(
                Name = generateRandomString(18),
                nFORCE__Category_Name__c = category,
                nFORCE__Is_Active__c = active,
                nFORCE__Key__c = key,
                nFORCE__Value__c = value);

        return newSP;
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

    private static final String
            ROUTENAME = 'LookupKey Generator',
            ROUTEBODY = 'c__CSA_LookupkeyGenerator',
            ROUTEAPP = 'lookupkey-generator',
            ROUTENAVIGATION = 'nforce__navigation',
            ROUTESUBNAV = 'nforce__sub_navigation',
            ROUTETOPBAR = 'nforce__topbar',
            PROPERTYCATEGORY = 'CSA Lookupkey Generator',
            PROPERTYKEY = 'Lookupkey Generator Data Installer',
            PROPERTYVALUE = 'true',
            NUMBERSFORRANDOMIZER = '0123456789',
            BLANK = '',
            GROUPAPP = 'admin';

}