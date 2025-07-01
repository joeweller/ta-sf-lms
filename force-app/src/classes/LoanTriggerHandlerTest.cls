@isTest(isParallel=true)
private class LoanTriggerHandlerTest {
	@isTest
	private static void shouldCreateLoanChargeOnInsert() {
		disableActiveTriggers();

		final Date currentDate = Date.today();
		final Loan__c loan = LoanFixtures.createLoan(null, currentDate);

		final LoanTriggerHandler handler;
		
		Test.startTest();
		handler = new LoanTriggerHandler();
		handler.setIsAfter(true);
		handler.setIsInsert(true);
		handler.run(new List<Loan__c>{ loan }, null, null, null);
		Test.stopTest();

		final Loan_Charge__c[] charges = handler.loanChargesToInsert;

		Assert.areEqual(charges.size(), 1, '1 loan charge should be created');

		Loan_Charge__c initialCharge = charges[0];
		Assert.areEqual(
			initialCharge.Date__c,
			currentDate.addMonths(36),
			'Loan issue date should be the date of issue advanced by the term'
		);
		Assert.areEqual(
			initialCharge.Charge_Type__c,
			'Release Charge',
			'Initial charge should be Release Charge'
		);
		Assert.areEqual(
			initialCharge.Amount__c,
			500.00,
			'Initial charge amount should be 500'
		);
	}

	public static void disableActiveTriggers() {
		LoanTriggerHandler.performDMLOverride = false;
	}
}
