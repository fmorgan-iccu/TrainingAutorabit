public with sharing class PdfUtils {

    public static String generateXfdf(String filePath, Map<String, String> values) {
        if (String.isBlank(filePath)) {
            throw new IllegalArgumentException('`filePath` must be provided.');
        }
        if (values == null) {
            throw new IllegalArgumentException('`values` must be provided.');
        }

        String s =
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">' +
            '<f href="' + filePath + '"/>' +
            '<fields>';

        for (String fieldName : values.keySet()) {
            String value = values.get(fieldName);
            s += '<field name="' + fieldName + '"><value>' + value + '</value></field>';
        }

        s += '</fields></xfdf>';

        return s;
    }

}