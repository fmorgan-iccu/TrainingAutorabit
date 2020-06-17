public class DNAJointAccountOwner implements IJointAccountOwner {
    private boolean canTransact;
    private String entityNumber;
    private String entityType;
    private String fullName;
    private String roleCode;
    private String roleDescription;

    public DNAJointAccountOwner(boolean canTransact, String entityNumber, String entityType, String fullName,  String roleCode, String roleDescription) {
        this.canTransact = canTransact;
        this.entityNumber = entityNumber;
        this.entityType = entityType;
        this.fullName = fullName;
        this.roleCode = roleCode;
        this.roleDescription = roleDescription;
    }
    
    public boolean getCanTransact() {
        return this.canTransact;
    }
    
    public String getEntityNumber() {
        return this.entityNumber;
    }
    
    public String getEntityType() {
        return this.entityType;
    }
    
    public String getFullName() {
        return this.fullName;
    }

    public String getRoleCode() {
        return this.roleCode;
    }
    
    public String getRoleDescription() {
        return this.roleDescription;
    }
    
    public boolean isOrg() {
        return 'ORG'.equals(this.entityType);
    }
    
    public boolean isPerson() {
        return 'PERS'.equals(this.entityType);
    }
}