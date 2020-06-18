/*
 * Class representing a note associated with a product application.
 */
public class ProductApplicationNote {
    private ProductApplicationAgent agent;
	private DateTime createdDate;
    private String text;
    private String title;
    private DateTime updatedDate;
    
    public ProductApplicationNote(ProductApplicationAgent agent, DateTime createdDate, String text, String title, DateTime updatedDate) {
        this.agent = agent;
        this.createdDate = createdDate;
        this.text = text;
        this.title = title;
        this.updatedDate = updatedDate;
    }
    
    public ProductApplicationAgent getAgent() {
        return this.agent;
    }
    
    public DateTime getCreatedDate() {
        return this.createdDate;
    }
    
    public String getText() {
        return this.text;
    }
    
    public String getTitle() {
        return this.title;
    }
    
    public DateTime getUpdatedDate() {
        return this.updatedDate;
    }
}