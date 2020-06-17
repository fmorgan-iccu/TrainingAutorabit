public class DNAMerchantTransaction implements Comparable {
	private String description;
    private integer count;
    
    public DNAMerchantTransaction(String description, integer count) {
        this.description = description;
        this.count = count;
    }
    
    public String getDescription() {
        return this.description;
    }
    
    public integer getCount() {
        return this.count;
    }
    
    public void setCount(integer count) {
        this.count = count;
    }
    
    public integer compareTo(Object trans) {
        DNAMerchantTransaction otherTrans = (DNAMerchantTransaction)trans;
        
        if (otherTrans.getCount() == this.count) {
            return 0;
        }
        
        if (this.count < otherTrans.getCount()) {
            return 1;
        }
        
        return -1;
    }
}