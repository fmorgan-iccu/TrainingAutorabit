public class EmailMessageResult {
	
	public Boolean isSuccess {get; set;}
	public String errorMessage {get; set;}

	public EmailMessageResult(Boolean isSuccess, String message) {
		this.isSuccess = isSuccess;
		this.errorMessage = message;
	}
}