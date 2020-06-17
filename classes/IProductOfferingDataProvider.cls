/*
 *	Interface for describing a class that accesses product offerings for a person. 
 */
public interface IProductOfferingDataProvider {
	List<ProductOfferingGroup> getProductOfferings(IPerson person);
	IAuthenticationManager getAuthenticationManager();    
}