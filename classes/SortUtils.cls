public with sharing class SortUtils {

	public static List<sObject> sortListByCreatedDate(List<sObject> sourceList) {
		List<CreatedDateSortWrapper> sortList = new List<CreatedDateSortWrapper>();
		for (sObject obj : sourceList) {
			sortList.add(new CreatedDateSortWrapper(obj));
		}
		sortList.sort();
		List<sObject> sortedList = new List<sObject>();
		for (CreatedDateSortWrapper wrapper : sortList) {
			sortedList.add(wrapper.obj);
		}
		return sortedList;
	}

	private class CreatedDateSortWrapper implements Comparable {
		// The object for sorting.
		public sObject obj;
		
		// Constructor
		public CreatedDateSortWrapper(sObject obj) {
			this.obj = obj;
		}
		
		// Compare the sObjects based on the creation date.
		public Integer compareTo(Object compareTo) {
			CreatedDateSortWrapper compareToObj = (CreatedDateSortWrapper)compareTo;
			
			// Because this is an sObject the createdDate must be retrieved by the get method.
			Datetime objCreatedDate = (Datetime)obj.get('CreatedDate');
			Datetime compareToCreatedDate = (Datetime)compareToObj.obj.get('CreatedDate');

			// Determine the ascending order of the created date.
			Integer returnValue = 0;
			if (objCreatedDate > compareToCreatedDate) {
				returnValue = 1;
			} else if (objCreatedDate < compareToCreatedDate) {
				returnValue = -1;
			}
			
			return returnValue;       
		}
	}

}