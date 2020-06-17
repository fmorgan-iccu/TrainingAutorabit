/**
 * Provides functionality to prevent recursion within triggers.  Blocks of code can be identified
 * by a specific name to prevent the code from executing again.  The name can even be a
 * concatenation of a block identifier and the record Id to allow for the block of code to run again
 * for a different record if required.
 *
 * The typical use case is outlined in the example below and uses the automic checkExecution method
 * to prevent muliple calls in a single call.
 *
 *		trigger name on sObjectType (after insert) {
 *			if (!checkExecuted('MyBlockName')) {
 *				// Do stuff...
 *			}	 
 *		}
 *
 * Other methods are provided to check/set/reset the block state for other use cases.
 */
public with sharing class TriggerUtils {

    // Stores the distinct block names that have been previously executed.
	@testVisible
	private static Set<String> executedBlocks = new Set<String>();

	/**
	 * Conditional block logic can call this single function in the if statement to check and set
	 * the block status in a single call.
	 *
	 * @param  name identifies the name of the block to check
	 * @return indicates if the block has been executed already, prior to the update
	 */
	public static Boolean checkExecuted(String name) {
		Boolean executed = isExecuted(name);
		setExecuted(name);
		return executed;
	}
	
	/**
	 * Determines whether a section of code has been previously executed with the indicated name.
	 */
	public static Boolean isExecuted(String name){
		Boolean executed = executedBlocks.contains(name);
		return executed;
	}
	
	/**
	 * Indicates that a section of code has been executed with the indicated name.
	 */
	public static void setExecuted(String name) {
		executedBlocks.add(name);
	}
	
	/**
	 * Used in testing routines to allow the flag to be reset if the data setup would trigger this.
	 */
	public static void resetExecuted(String name) {
		executedBlocks.remove(name);
	}
	
	/**
	 * This function is provided for test methods to be able to reset all flags that may have been
	 * setup during the data initialization.
	 */
	public static void resetExecuted() {
		executedBlocks.clear();
	}

}