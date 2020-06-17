public with sharing class CardTravelNotificationInfo {

    public class Detail {
        public String id { get; private set; }
        public Date fromDate { get; private set; }
        public Date toDate { get; private set; }
        public String stateCode { get; private set; }
        public String countryCode { get; private set; }
        public String note { get; private set; }

        public Detail(String id, Date fromDate, Date toDate, String stateCode, String countryCode, String note) {
            this.id = id;
            this.fromDate = fromDate;
            this.toDate = toDate;
            this.stateCode = stateCode;
            this.countryCode = countryCode;
            this.note = note;
        }

        public Detail(Date fromDate, Date toDate, String stateCode, String countryCode, String note) {
            this.id = null;
            this.fromDate = fromDate;
            this.toDate = toDate;
            this.stateCode = stateCode;
            this.countryCode = countryCode;
            this.note = note;
        }
    }

    public String cardNumber { get; private set; }
    public String firstName { get; private set; }
    public String lastName { get; private set; }
    public String primaryPhone { get; private set; }
    public List<Detail> details { get; private set; }
    
    public CardTravelNotificationInfo(String cardNumber, String firstName, String lastName, String primaryPhone, List<Detail> details) {
        this.cardNumber = cardNumber;
        this.firstName = firstName;
        this.lastName = lastName;
        this.primaryPhone = primaryPhone;
        this.details = details;
    }
}