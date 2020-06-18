/*
 *	Interface for describing a class that accesses product applications that have been filled out by a person. 
 */
public interface IProductApplicationDataProvider {
    ProductApplicationResponse getOpenProductApplications(IPerson person, DateTime startDate, DateTime endDate);
    IAuthenticationManager getAuthenticationManager();
    String getSystemName();
}