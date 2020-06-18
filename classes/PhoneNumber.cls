public class PhoneNumber {
	private PhoneNumberType phoneType;
    private String value;

    public PhoneNumber(String value, PhoneNumberType phoneType) {
        this.phoneType = phoneType;
        this.value = value;
    }

    public PhoneNumberType getPhoneType() {
        return this.phoneType;
    }

    public String getValue() {
        return this.value;
    }

    public String getAreaCode() {
        if (this.value.length() != 10) {
            return null;
        }
        
        return this.value.substring(0, 3);
    }

    public String getPrefix() {
        if (this.value.length() != 10) {
            return null;
        }
        
        return this.value.substring(3, 6);
    }

    public String getLineNumber() {
        if (this.value.length() != 10) {
            return null;
        }
        
        return this.value.substring(6);
    }    
}