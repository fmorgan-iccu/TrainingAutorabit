public with sharing class DNABusinessServicesAuthCredential implements IPasswordCredential {
    
    private String username;
    private String password;
    private String cashBox;
    private String networkNodeName;
    private Date effectiveDate;
    private Date postingDate;
    
    public DNABusinessServicesAuthCredential(
        String username,
        String password,
        String cashBox,
        Date postingDate,
        Date effectiveDate,
        String networkNodeName)
    {
        this.username = username;
        this.password = password;
        this.cashBox = cashBox;
        this.networkNodeName = networkNodeName;
        this.effectiveDate = effectiveDate;
        this.postingDate = postingDate;
    }

    public String getUsername() {
        return this.username;
    }
    
    public String getPassword() {
        return this.password;
    }

    public String getCashBox() {
        return this.cashBox;
    }

    public String getNetworkNodeName() {
        return this.networkNodeName;
    }

    public Date getEffectiveDate() {
        return this.effectiveDate;
    }

    public Date getPostingDate() {
        return this.postingDate;
    }

}