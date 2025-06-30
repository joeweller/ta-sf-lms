trigger Loan on Loan__c(after insert) {
	LoanTriggerHandler handler = new LoanTriggerHandler();
	handler.run(
		Trigger.isBefore,
		Trigger.isAfter,
		Trigger.isInsert,
		Trigger.isUpdate,
		Trigger.isDelete,
		Trigger.new,
		Trigger.newMap,
		Trigger.old,
		Trigger.oldMap
	);
}
