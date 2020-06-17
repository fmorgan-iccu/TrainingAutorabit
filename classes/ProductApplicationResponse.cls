public class ProductApplicationResponse {
	private List<IProductApplication> applications;
    private List<String> errors;

    public ProductApplicationResponse(List<IProductApplication> applications, List<String> errors) {
        if (applications == null) {
            applications = new List<IProductApplication>();
        }
        
        this.applications = applications;
        
        if (errors == null) {
            errors = new List<String>();
        }
        
        this.errors = errors;
    }

    public List<IProductApplication> getApplications() {
        return this.applications;
    }

    public List<String> getErrors() {
        return this.errors;
    }
}