@isTest
public with sharing class SortUtilsTest {

	@isTest
	static void testSortListByCreatedDate() {
		List<Contact> listToSort = new List<Contact> {
			getTestContact('Test1'),
			getTestContact('Test2'),
			getTestContact('Test3'),
			getTestContact('Test4')
		};
		insert listToSort;
		Test.setCreatedDate(listToSort[0].id, DateTime.newInstance(2018,1,2));
		Test.setCreatedDate(listToSort[1].id, DateTime.newInstance(2017,10,3));
		Test.setCreatedDate(listToSort[2].id, DateTime.newInstance(2018,1,1));
		Test.setCreatedDate(listToSort[3].id, DateTime.newInstance(2019,12,25));

		// Must query the objects to get the created date set properly.
		listToSort = [SELECT id, createdDate FROM CONTACT];

		Test.startTest();

		List<Contact> sortedList = SortUtils.sortListByCreatedDate((List<sObject>)listToSort);

		Test.stopTest();

		System.assertEquals(sortedList[0].id, listToSort[1].id);
		System.assertEquals(sortedList[1].id, listToSort[2].id);
		System.assertEquals(sortedList[2].id, listToSort[0].id);
		System.assertEquals(sortedList[3].id, listToSort[3].id);
	}

	private static Contact getTestContact(String lastName) {
		Contact c = new Contact();
		c.lastName = lastName;
		return c;
	}

}