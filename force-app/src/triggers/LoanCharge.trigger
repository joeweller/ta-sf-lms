trigger LoanCharge on Loan_Charge__c(before insert, after insert) {
	final LoanChargeTriggerHandler handler = new LoanChargeTriggerHandler();
	handler.setIsBefore(Trigger.isBefore);
	handler.setIsAfter(Trigger.isAfter);
	handler.setIsInsert(Trigger.isInsert);
	handler.run(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}
