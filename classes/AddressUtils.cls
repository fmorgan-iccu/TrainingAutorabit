public class AddressUtils {

    public static String combineCityStateZip(String city, String state, String zip) {
        final String commaSeparator = ', ';

        String cityStateZip = '';

        if (city != null) {
            cityStateZip = cityStateZip + city + commaSeparator;
        }

        if (state != null) {
            cityStateZip = cityStateZip + state + '  ';
        }

        if (zip != null) {
            cityStateZip = cityStateZip + zip;
        }

        if (cityStateZip.length() > 0) {
            if (cityStateZip.endsWith(commaSeparator)) {
                cityStateZip = cityStateZip.remove(commaSeparator);
            }

            return cityStateZip.trim();
        } else {
            return null;
        }
    }

    /**
     * Given a postal code, returns a SFAddress for a DNA record that matches.  This information
     * represents a "verified" DNA address that can be used to suggest the city and state for the
     * given postal code.
     * @param  postalCode postalCode description
     * @return a SFAddress for a DNA contact that matches the postal code
     */
    public static SFAddress getVerifiedAddress(String postalCode) {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordTypeConstants.CONTACT_DNA).getRecordTypeId();
        List<Contact> contacts = [
            SELECT id,
                mailingCity,
                mailingPostalCode,
                mailingState
            FROM Contact
            WHERE recordTypeId = :recordTypeId
                AND mailingPostalCode = :postalCode
                AND mailingCountry = 'USA'
            LIMIT 1
        ];
        // A postal code was not found but the original postal code is in the zip+4 format.  Try
        // to lookup just the base zip for a suggestion.
        if (contacts.size() == 0 && postalCode.length() == 10) {
            String shortPostalCode = postalCode.left(5);
            contacts = [
                SELECT id,
                    mailingCity,
                    mailingPostalCode,
                    mailingState
                FROM Contact
                WHERE recordTypeId = :recordTypeId
                    AND mailingPostalCode = :shortPostalCode
                    AND mailingCountry = 'USA'
                LIMIT 1
            ];
        }
        if (contacts.size() == 0) {
            return null;
        }
        SFAddress address = new SFAddress(contacts[0], AddressType.PRIMARY);
        return address;
    }

    /**
     * Checks an address line to determine if it contains information that identifies an Attention line.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches an Attention line
     */
    public static Boolean isAttention(String addressLine) {
        return Pattern.matches('(?i)^(c/o|co|fbo:|fbo) .*', addressLine);
    }

    /**
     * Checks an address line to determine if it contains information that identifies an Apartment line.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches an Apartment line
     */
    public static Boolean isApartment(String addressLine) {
        return Pattern.matches('(?i)^(apt[.]? .*|[0-9]+|[a-zA-Z]{0,2}[0-9]+)|.*( apt[0-9]*| apt[.]|apartment|#[0-9]+|#[a-zA-Z]{0,2}[0-9]*).*$', addressLine);
    }

    /**
     * Checks an address line to determine if it contains information that identifies an Building line.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches an Building line
     */
    public static Boolean isBuilding(String addressLine) {
        return Pattern.matches('(?i)^.*(trailer|trlr|trl |tlr |bldg|bld |bld[.]|building|unit|condo|annex|number).*$', addressLine);
    }

    /**
     * Checks an address line to determine if it contains information that identifies a PO Box.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches a PO Box
     */
    public static Boolean isPostOfficeBox(String addressLine) {
        return Pattern.matches('(?i).*(p[.]?\\s*(o|0)[.]?|p(ost|ostal)\\s+(o|0)ffice|postal)\\s+box.*', addressLine);
    }

    /**
     * Checks an address line to determine if it contains information that identifies a Rural Route line.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches a Rural Route line
     */
    public static Boolean isRuralRoute(String addressLine) {
        return Pattern.matches('(?i)^(rt |rt[.]|rr |rr[.]|rural route|route |ret).*', addressLine);
    }

    /**
     * Checks an address line to determine if it contains information that identifies a Suite line.
     * @param  addressLine An address line that will be checked
     * @return Indicates if the address line matches a Suite line
     */
    public static Boolean isSuite(String addressLine) {
        return Pattern.matches('(?i)^(suite|ste) .*', addressLine);
    }

}