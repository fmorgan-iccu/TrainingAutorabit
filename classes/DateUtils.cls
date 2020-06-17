public class DateUtils {
    public static String DATE_FORMAT = 'M/d/yyyy';

    public static DateTime parseISO8601Date(String isoDate) {
        if (isoDate == null) {
            return null;
        }

        String cleanedDate = isoDate.replace('T', ' ');
        DateTime parsedDate = DateTime.valueOfGmt(cleanedDate);

        return parsedDate;
    }

    public static String format(Date d, String format) {
        DateTime dt = datetime.newInstance(d.year(), d.month(),d.day());
        String formattedDate = dt.format(format);
        return formattedDate;
    }

    public static Date valueOf(String dateString, String format) {
        Date newDate = null;

        switch on format {
            when 'MM/dd/yyyy' {
                List<String> dateParts = dateString.split('/');
                if (dateParts.size() != 3) {
                    return null;
                }

                Integer month = Integer.valueOf(dateParts[0]);
                Integer day = Integer.valueOf(dateParts[1]);
                Integer year = Integer.valueOf(dateParts[2]);
                newDate = Date.newInstance(year, month, day);
            }
            when else {
                throw new IllegalArgumentException('Unsupported format in DateUtils.valueOf function.');
            }
        }

        return newDate;
    }
}