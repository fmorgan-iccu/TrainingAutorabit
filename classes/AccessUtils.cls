public class AccessUtils {

    // Stores the cached profile names that have been identified to this point.
    public static Map<Id,String> profileIdToNameMap = new Map<Id,String>();

    /**
     * This function will retrieve a profile name given the Id and perform a lazy load/cache of this information
     * to prevent duplicate SOQL queries.
     */
    public static String getProfileName(Id profileId) {
        if (!profileIdToNameMap.containsKey(profileId)) {
            Profile prof = [
                SELECT Name
                FROM profile
                WHERE id = :profileId
                LIMIT 1
            ];
            profileIdToNameMap.put(profileId, prof.Name);
        }
        
        return profileIdToNameMap.get(profileId);
    }

    /**
     * Checks if the user has the specified permission set.  If the user is a System Administrator,
     * they are consider to have all permissions.
     */
    public static Boolean checkPermission(String permissionName) {
        Id profileId = UserInfo.getProfileId();
        if (profileId == IdUtils.SYSTEM_ADMIN_PROFILE_ID) {
            return true;
        }
        Boolean hasPermission = FeatureManagement.checkPermission(permissionName);
        return hasPermission;
    }

}