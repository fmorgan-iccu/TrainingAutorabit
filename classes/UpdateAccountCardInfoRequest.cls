/**
 * Model object representing a proposed status change for a AccountCardInfo object.
 */
public class UpdateAccountCardInfoRequest {
    public AccountCardInfo cardInfo { get; private set; }
    public String changeReason { get; private set; }
    public String changeReasonCode { get; private set; }
    public String status { get; private set; }

    public UpdateAccountCardInfoRequest(AccountCardInfo cardInfo, String changeReason, String changeReasonCode, String status) {
        this.cardInfo = cardInfo;
        this.changeReason = changeReason;
        this.changeReasonCode = changeReasonCode;
        this.status = status;
    }
}