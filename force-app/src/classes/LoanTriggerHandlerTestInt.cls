@isTest(isParallel=true)
private class LoanTriggerHandlerTestInt {
	@isTest
	private static void shouldCreateLoanChargeOnInsert() {
		final Date currentDate = Date.Today();

		final Account acc = LoanFixtures.createAccount();
		insert acc;
		final Loan__c loan = LoanFixtures.createLoan(acc.id, currentDate);

		Test.startTest();
		insert loan;
		Test.stopTest();

		Loan_Charge__c[] loanCharges = LoanFixtures.fetchLoanCharges(loan.id);

		Assert.areEqual(
			loanCharges.size(),
			1,
			'1 loan charge should be created'
		);

		Loan_Charge__c initialCharge = loanCharges[0];
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
}
