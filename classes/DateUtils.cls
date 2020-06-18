public class DateUtils {
    public static String DATE_FORMAT = 'M/d/yyyy';

    public static Datetime convertToDatetime(Date d) {
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime result = Datetime.newInstance(d, t);
        return result;
    }

    public static String format(Date d) {
        return format(d, DATE_FORMAT);
    }

    public static String format(Date d, String format) {
        DateTime dt = datetime.newInstance(d.year(), d.month(),d.day());
        String formattedDate = dt.format(format);
        return formattedDate;
    }

    /**
     * Retrieves the number of hours difference the user's timezone is from UTC.  For MST, this returns -7.
     */
    public static Integer getTimezoneOffsetHours() {
        DateTime gmt = DateTime.now();
        Integer offset = UserInfo.getTimezone().getOffset(gmt);
        offset = offset / (1000 * 60 * 60); // Offset is the number of milliseconds from UTC; convert to hours.
        return offset;
    }

    public static DateTime parseISO8601Date(String isoDate) {
        if (isoDate == null) {
            return null;
        }

        String cleanedDate = isoDate.replace('T', ' ');
        DateTime parsedDate = DateTime.valueOfGmt(cleanedDate);

        return parsedDate;
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