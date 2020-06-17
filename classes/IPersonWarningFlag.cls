public interface IPersonWarningFlag {
	DateTime getEffectiveDate();
    String getFlagCode();
    String getFlagCodeDescription();
    DateTime getInactiveDate();
    String getNoteClassCode();
    String getNoteClassCodeDescription();
    String getNoteSubClassCode();
    String getNoteSubClassCodeDescription();
    String getNoteText();
}