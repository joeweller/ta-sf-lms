trigger Loan on Loan__c(after insert, after update) {
	final LoanTriggerHandler handler = new LoanTriggerHandler();
	handler.setIsAfter(Trigger.isAfter);
	handler.setIsInsert(Trigger.isInsert);
	handler.setIsUpdate(Trigger.isUpdate);
	handler.run(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}
