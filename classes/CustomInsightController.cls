public class CustomInsightController {
	@AuraEnabled
    public static List<Map<String, Object>> getInsightTypes() {
        List<Map<String, Object>> picklist = new List<Map<String, Object>>();

        Schema.DescribeFieldResult field = MemberInsight__c.InsightType__c.getDescribe();

        for (Schema.PicklistEntry entry : field.getPicklistValues()) {
            String label = entry.getLabel();
            String value = entry.getValue();
            boolean isDefault = entry.isDefaultValue();
            
            Map<String, Object> entryMap = new Map<String, Object>();
            entryMap.put('label', label);
            entryMap.put('value', value);
            entryMap.put('isDefault', isDefault);

            picklist.add(entryMap);
        }

        return picklist;
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> getMemberInsights(String contactId) {
        if (contactId == null) {
            return new List<Map<String, Object>>();
        }
        
        Date today = Date.today();

        MemberInsight__c[] insights = [
            SELECT
            	ExpirationDate__c,
            	ExtraDetails__c,
            	Id,
	            InsightType__c,
            	Name
            FROM MemberInsight__c
            WHERE ContactID__c = :contactId AND 
            (ExpirationDate__c = NULL OR ExpirationDate__c > :today)
            ORDER BY CreatedDate ASC
        ];
        
        /**
         * This is a ton of BS code, but basically, PickList aren't very dev friendly.  You can't use a SOQL
         * query to get the picklist label and value.  Just one or the other.  This map is to be able to 
         * present back both.
         */
        Map<String, Map<String, Object>> insightMap = new Map<String, Map<String, Object>>();
        
        // Iterate throught the picklist metadata to get all the info and build our map
        Schema.DescribeFieldResult field = MemberInsight__c.InsightType__c.getDescribe();
        for (Schema.PicklistEntry entry : field.getPicklistValues()) {
            String label = entry.getLabel();
            String value = entry.getValue();
            boolean isDefault = entry.isDefaultValue();
            
            Map<String, Object> entryMap = new Map<String, Object>();
            entryMap.put('label', label);
            entryMap.put('value', value);
            entryMap.put('isDefault', isDefault);

            insightMap.put(label, entryMap);
        }
        
        /**
         * We don't want to expose the color and icon of these picklist items to the agents and don't know if a good 
         * administrative way to set them when created/saved, so these maps exist to provide those values,
         * plus a reasonable default...
         */
        Map<String, String> colorMap = new Map<String, String>();
        colorMap.put('Declined', 'Gray');
        colorMap.put('Fraud', 'Red');
        colorMap.put('Gender', 'Purple');
        colorMap.put('Medical', 'Teal');
        colorMap.put('Military', 'Yellow');
        colorMap.put('Name Pronunciation', 'Pink');

        Map<String, String> iconMap = new Map<String, String>();
        iconMap.put('Declined', 'minus-circle');
        iconMap.put('Fraud', 'flag');
        iconMap.put('Gender', 'transgender-alt');
        iconMap.put('Medical', 'medkit');
        iconMap.put('Military', 'star');
        iconMap.put('Name Pronunciation', 'comment');
        
        List<Map<String, Object>> insightList = new List<Map<String, Object>>();
        for (MemberInsight__c insight : insights) {
            String color = colorMap.get(insight.InsightType__c);
            if (color == null) {
                color = 'Purple';
            }
            
            String iconName = iconMap.get(insight.InsightType__c);
            if (iconName == null) {
                iconName = 'info-circle';
            }
            
            Map<String, Object> mappedInsight = new Map<String, Object>();
            mappedInsight.put('expirationDate', insight.ExpirationDate__c);
            mappedInsight.put('extraDetails', insight.ExtraDetails__c);
            mappedInsight.put('id', insight.Id);
            mappedInsight.put('insightType', insight.InsightType__c);
            mappedInsight.put('insightTypeName', insightMap.get(insight.InsightType__c));
            mappedInsight.put('name', insight.Name);
            mappedInsight.put('icon', iconName);
            mappedInsight.put('color', color);

            insightList.add(mappedInsight);
        }

        return insightList;
    }
}