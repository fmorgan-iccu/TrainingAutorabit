public interface IJointAccountOwner {
	String getFullName();
    String getEntityNumber();
    String getEntityType();
    String getRoleCode();
    String getRoleDescription();
    boolean getCanTransact();
    boolean isPerson();
    boolean isOrg();
}