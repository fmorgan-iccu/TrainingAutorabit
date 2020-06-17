public abstract class AOReportParser implements IAOPayloadParser {
    public static final String RAW_DATA_KEY = 'RawData';
	public static final String REPORT_TITLE_KEY = 'title';
    public static final String REPORT_SUMMARY_KEY = 'summary';
    public static final String REPORT_HEADERS_KEY = 'headers';
    public static final String REPORT_DATA_KEY = 'data';
    public static final String REPORT_WIDTH_KEY = 'width';
    public static final Integer REPORT_DEFAULT_WIDTH = 4;
    public static final Integer REPORT_FULL_WIDTH = 12;

    public abstract void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo);
    public abstract String getReportName();
    
    protected Map<String, Object> createExceptionMap(Exception e) {
        return new Map<String, Object>{
            REPORT_TITLE_KEY => this.getReportName(),
            REPORT_DATA_KEY => new List<Map<String, Object>> {
                new Map<String, Object> {
                    REPORT_TITLE_KEY => 'Error',
                 	REPORT_DATA_KEY => 'There was a problem generating the report. '
                },
                new Map<String, Object> {
                    REPORT_TITLE_KEY => 'Details',
                    REPORT_DATA_KEY => e.getMessage() + ' ' + e.getStackTraceString()
                }
            }
        };
    }
    
    protected Map<String, Object> createDataElement(String title, Object data) {
        return this.createDataElement(title, data, REPORT_DEFAULT_WIDTH);
    }
    
    protected Map<String, Object> createDataElement(String title, Object data, Integer width) {
        return new Map<String, Object> {
            REPORT_TITLE_KEY => title,
            REPORT_WIDTH_KEY => width,
            REPORT_DATA_KEY => data
        };
    }
    
    protected Map<String, Object> createReport(List<Map<String, Object>> summaryData, List<Map<String, Object>> sections) {
        Map<String, Object> report = new Map<String, Object> {
            REPORT_TITLE_KEY => this.getReportName(),
            REPORT_SUMMARY_KEY => summaryData,
            REPORT_DATA_KEY => sections
        };
        
        return report;
    }
    
    /**
     * Utility method for conditionally adding an element to the list
     */
    protected void addDataElementToList(Map<String, Object> element, List<Map<String, Object>> mapList) {
        if (element != null) {
            mapList.add(element);
        }
    }
    
    /**
     * Utility method for conditionally creating and adding an element to the list
     */
    protected void addDataToList(String title, Object data, List<Map<String, Object>> mapList) {
        Map<String, Object> element = this.createDataElement(title, data);
        this.addDataElementToList(element, mapList);
    }
    
    /**
     * Utility method for creating a table node
     */
    protected Map<String, Object> createTable(List<String> headers, List<List<String>> values) {
        
        return new Map<String, Object> {
            REPORT_HEADERS_KEY => headers,
            REPORT_DATA_KEY => values
        };
    }
    
    protected void addValueToList(String value, List<String> values) {
        if (value == null) {
            value = '';
        }
        
        values.add(value);
    }
}