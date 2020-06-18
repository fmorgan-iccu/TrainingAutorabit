public with sharing class SortUtils {

    public static List<sObject> sortListByCreatedDate(List<sObject> sourceList) {
        return sortListByCreatedDate(sourceList, Metadata.SortOrder.ASC_X);
    }

    public static List<sObject> sortListByCreatedDate(List<sObject> sourceList, Metadata.SortOrder sortOrder) {
        // Create and sort a list of objects.
        List<SobjectComparable> sortList = new List<SobjectComparable>();
        for (sObject obj : sourceList) {
            sortList.add(new SobjectComparable(obj, true));
        }
        sortList.sort();

        // Create the resulting sorted array of the original objects in the requested order.
        List<sObject> sortedList = new List<sObject>();
        if (sortOrder == Metadata.SortOrder.ASC_X) {
            for (SobjectComparable wrapper : sortList) {
                sortedList.add(wrapper.obj);
            }
        } else {
            for (Integer i = sortList.size() - 1; i >= 0; i--) {
                sortedList.add(sortList[i].obj);
            }
        }
        return sortedList;
    }

    /**
     * The sortListByDate variants sort the sObject by a closed/activity date and the created date.  They attempt to
     * use a closed/activity date to determine when the last significant event occurred for an object.  It DOES NOT use
     * the last modified date/time because there are frequent times that mass data loads/updates will set the last
     * modified date/time in bulk.  This makes using the last modified date/time for ordering less useful.
     */
    public static List<sObject> sortListByDate(List<sObject> sourceList) {
        return sortListByDate(sourceList, Metadata.SortOrder.ASC_X);
    }

    public static List<sObject> sortListByDate(List<sObject> sourceList, Metadata.SortOrder sortOrder) {
        // Create and sort a list of objects.
        List<SobjectComparable> sortList = new List<SobjectComparable>();
        for (sObject obj : sourceList) {
            sortList.add(new SobjectComparable(obj, false));
        }
        sortList.sort();

        // Create the resulting sorted array of the original objects in the requested order.
        List<sObject> sortedList = new List<sObject>();
        if (sortOrder == Metadata.SortOrder.ASC_X) {
            for (SobjectComparable wrapper : sortList) {
                sortedList.add(wrapper.obj);
            }
        } else {
            for (Integer i = sortList.size() - 1; i >= 0; i--) {
                sortedList.add(sortList[i].obj);
            }
        }
        return sortedList;
    }

    private class SobjectComparable implements Comparable {
        // The object for sorting.
        public sObject obj;
        public Boolean createdDateOnly;

        // Constructor
        public SobjectComparable(sObject obj, Boolean createdDateOnly) {
            this.obj = obj;
            this.createdDateOnly = createdDateOnly;
        }

        // Compare the sObjects based on the creation date.
        public Integer compareTo(Object compareTo) {
            SobjectComparable compareToObj = (SobjectComparable)compareTo;

            Datetime objDate = getComparableDatetime(obj);
            Datetime compareDate = getComparableDatetime(compareToObj.obj);

            // Determine the ascending order of the created date.
            Integer returnValue = 0;
            if (objDate > compareDate) {
                returnValue = 1;
            } else if (objDate < compareDate) {
                returnValue = -1;
            }

            return returnValue;
        }

        private Datetime getComparableDatetime(sObject o) {
            Datetime createdDate = (Datetime)o.get('CreatedDate');
            if (createdDateOnly) {
                return createdDate;
            }
            if (o instanceof Case) {
                Datetime closedDate = (Datetime)o.get('ClosedDate');
                return  closedDate != null ? closedDate : createdDate;
            }
            if (o instanceof Opportunity) {
                Datetime closedDate = (Datetime)o.get('CloseDate');
                return  closedDate != null ? closedDate : createdDate;
            }
            if (o instanceof Task) {
                Datetime activityDate = (Datetime)o.get('ActivityDate');
                return  activityDate != null ? activityDate : createdDate;
            }
            return createdDate;
        }
    }

}