/**
 * Utility class for string manipulation
 */
public class StringUtils {
    public static String toProperCase(String value) {
        if (value == null) {
            return null;
        }
        
        if (value.length() == 0) {
            return '';
        }
        
        // Normalize - Convert to lowercase
        value = value.toLowerCase();
        
        // Hold each word
        List<String> pieces = new List<String>();
        
        // Split
        for(String s : value.split(' ')) {
            // Capitalize each piece
            s = s.capitalize();
            
            // Add to pieces
            pieces.add(s);
        }
        
        // Join
        return String.join(pieces, ' ');
    }
}