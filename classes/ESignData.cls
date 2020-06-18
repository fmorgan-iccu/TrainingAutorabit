/**
 * Model object representing prefill data on a template.
 */
public class ESignData {
    /**
     * Model object representing textual data.
     */
    public class ESignTextData {
        /**
         * key The key of the text data.
         */
        public String key { get; private set; }

        /**
         * value The value of the text data.
         */
        public String value { get; private set; }

        public ESignTextData(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }

    /**
     * Model object representing selectionable data (radio buttons, check boxes, etc.)
     */
    public class ESignSelectData {
        /**
         * groupName The group name of the select data.
         */
        public String groupName { get; private set; }

        /**
         * key The key of the select data.
         */
        public String key { get; private set; }

        /**
         * groupName Whether the item is selected, or not.
         */
        public Boolean selected { get; private set; }

        public ESignSelectData(String groupName, String key, Boolean selected) {
            this.groupName = groupName;
            this.key = key;
            this.selected = selected;
        }
    }

    public static ESignData empty() {
        return new ESignData(new List<ESignData.ESignTextData>(), new List<ESignData.ESignSelectData>(), new List<ESignData.ESignSelectData>());
    }

    /**
     * textData The list of ESignTextData associated with a template.
     */
    public List<ESignTextData> textData { get; private set; }

    /**
     * radioData The list of ESignSelectData radio button data associated with a template.
     */
    public List<ESignSelectData> radioData { get; private set; }

    /**
     * checkData The list of ESignSelectData checkbox data associated with a template.
     */
    public List<ESignSelectData> checkData { get; private set; }

    /**
     * listData The list of ESignSelectData list data associated with a template.
     */
    public List<ESignSelectData> listData { get; private set; }

    public ESignData(List<ESignTextData> textData, List<ESignSelectData> radioData, List<ESignSelectData> checkData) {
        this.textData = textData;
        this.radioData = radioData;
        this.checkData = checkData;
        this.listData = new List<ESignSelectData>();
    }
}