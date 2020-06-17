@isTest
private class TriggerUtilsTest {

	@isTest
    static void testAll() {
		System.assert(TriggerUtils.isExecuted('missing') == false, 'Missing name should not be executed.');
		TriggerUtils.setExecuted('testBlock');
		System.assert(TriggerUtils.executedBlocks.contains('testBlock'), 'The testBlock key is not present in executed blocks.');
		System.assert(TriggerUtils.isExecuted('testBlock') == true, 'IsExecuted didn\'t return true for the testBlock.');
		System.assert(TriggerUtils.checkExecuted('testBlock2') == false, 'The checkExecuted method should return false on the first call.');
		System.assert(TriggerUtils.isExecuted('testBlock2') == true, 'The checkExecuted method didn\'t set the testBlock2 value to true.');
		System.assert(TriggerUtils.checkExecuted('testBlock2') == true, 'The checkExecuted method should return true on all subsequent calls.');
		System.assert(TriggerUtils.checkExecuted('testBlock2') == true, 'The checkExecuted method should return true on all subsequent calls.');
		TriggerUtils.setExecuted('testBlock3');
		System.assert(TriggerUtils.executedBlocks.size() == 3, 'The utility didn\'t properly track three block names.');
		TriggerUtils.resetExecuted('testBlock3');
		System.assert(TriggerUtils.isExecuted('testBlock3') == false, 'The resetExecuted method didn\'t properly reset the block name.');
		System.assert(TriggerUtils.executedBlocks.size() == 2, 'The resetExecuted method didn\'t properly remove a single block from the list.');
		TriggerUtils.resetExecuted();
		System.assert(TriggerUtils.executedBlocks.size() == 0, 'The resetExecuted method didn\'t properly remove all blocks from the list.');
    }

}