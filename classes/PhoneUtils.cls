public class PhoneUtils {

	// Removes all special formatting from a phone number, including a leading 1 for a US number.
	public static String formatDigitsOnly(String phone) {
		if (phone == null) {
			return null;
		}
		
		String phoneDigits = phone.replaceAll('[^0-9]','');
		
		if (phoneDigits.length() == 11 && phoneDigits.substring(0,1) == '1') {
			return phoneDigits.right(10);
		}
		
		return phoneDigits;
	}

	// Formats the phone number to match the Salesforce standard (999) 999-9999.
	public static String format(String phone) {
		string phoneDigits;

		if (phone == null) {
			return null;
		}
		
		// Clean the phone number of any special characters.
		phoneDigits = formatDigitsOnly(phone);
		
		// Reformat the phone number in the Salesforce standard format.
		if (phoneDigits.length() == 10) {
			return '(' + phoneDigits.substring(0,3) + ') ' + phoneDigits.substring(3,6) + '-' + phoneDigits.substring(6,10);
		}
		
		// Return the original value since it is not in a standard US format and may include an international dial code
		// or an extension number.
		return phone;
	}

}