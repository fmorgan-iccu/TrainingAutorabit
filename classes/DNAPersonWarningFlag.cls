public class DNAPersonWarningFlag implements IPersonWarningFlag {
    private DateTime effectiveDate;
    private String flagCode;
    private String flagCodeDescription;
    private DateTime inactiveDate;
    private String noteClassCode;
    private String noteClassCodeDescription;
    private String noteSubClassCode;
    private String noteSubClassCodeDescription;
    private String noteText;
    
    public DNAPersonWarningFlag(DateTime effectiveDate, String flagCode, String flagCodeDescription, DateTime inactiveDate, String noteClassCode, String noteClassCodeDescription, String noteSubClassCode, String noteSubClassCodeDescription, String noteText) {
        this.effectiveDate = effectiveDate;
        this.flagCode = flagCode;
        this.flagCodeDescription = flagCodeDescription;
        this.inactiveDate = inactiveDate;
        this.noteClassCode = noteClassCode;
        this.noteClassCodeDescription = noteClassCodeDescription;
        this.noteSubClassCode = noteSubClassCode;
        this.noteSubClassCodeDescription = noteSubClassCodeDescription;
        this.noteText = noteText;
    }
    
    public DateTime getEffectiveDate() {
        return this.effectiveDate;
    }
    
    public String getFlagCode() {
        return this.flagCode;
    }
    
    public String getFlagCodeDescription() {
        return this.flagCodeDescription;
    }
    
    public DateTime getInactiveDate() {
        return this.inactiveDate;
    }
    
    public String getNoteClassCode() {
        return this.noteClassCode;
    }
    
    public String getNoteClassCodeDescription() {
        return this.noteClassCodeDescription;
    }
    
    public String getNoteSubClassCode() {
        return this.noteSubClassCode;
    }
    
    public String getNoteSubClassCodeDescription() {
        return this.noteSubClassCodeDescription;
    }
    
    public String getNoteText() {
        return this.noteText;
    }
}