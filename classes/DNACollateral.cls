public with sharing class DNACollateral implements ICollateral {

    private List<DNAAccount> accounts;
    private String description;
    private String id; // Government assigned ID (e.g. VIN)
    private String make;
    private String model;
    private String propertyNumber; // Unique ID in the system of record.
    private Double purchasePrice;
    private String typeCode;
    private Integer year;
    private Double value;

    public DNACollateral(
        List<DNAAccount> accounts,
        String description,
        String id,
        String make,
        String model,
        String propertyNumber,
        Double purchasePrice,
        String typeCode,
        Integer year,
        Double value)
    {
        this.accounts = accounts;
        this.description = description;
        this.id = id;
        this.make = make;
        this.model = model;
        this.propertyNumber = propertyNumber;
        this.purchasePrice = purchasePrice;
        this.typeCode = typeCode;
        this.year = year;
        this.value = value;
    }

    public List<DNAAccount> getAccounts() {
        return this.accounts;
    }

    public String getDescription() {
        return this.description;
    }

    public String getId() {
        return this.id;
    }

    public String getMake() {
        return this.make;
    }

    public String getModel() {
        return this.model;
    }

    public String getPropertyNumber() {
        return this.propertyNumber;
    }

    public Double getPurchasePrice() {
        return this.purchasePrice;
    }

    public String getTypeCode() {
        return this.typeCode;
    }

    public Integer getYear() {
        return this.year;
    }

    public Double getValue() {
        return this.value;
    }

}