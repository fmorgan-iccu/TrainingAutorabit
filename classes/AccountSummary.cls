/**
 * Object representing an arbitrary summary of IAccount
 */
public class AccountSummary {
    private Double loanTotalOwner;
    private Double depositTotalOwner;

    public AccountSummary(Double loanTotalOwner, Double depositTotalOwner) {
        this.loanTotalOwner = loanTotalOwner;
        this.depositTotalOwner = depositTotalOwner;
    }

    public Double getLoanTotalOwner() {
        return this.loanTotalOwner;
    }

    public Double getDepositTotalOwner() {
        return this.depositTotalOwner;
    }
}