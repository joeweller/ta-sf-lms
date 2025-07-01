@isTest(isParallel=true)
private class LoanChargeTriggerHandlerTestInt {
	@IsTest
	private static void shouldFailValidationOnMultipleReleaseCharges() {
		final Date currentDate = Date.Today();

		final Loan__c loan = createInitialLoanRecord(currentDate);

		Assert.areEqual(
			1,
			LoanFixtures.fetchLoanCharges(loan.Id).size(),
			'initial loan charge should have been created throuw the existing loan trigger'
		);

		final Loan_Charge__c newLoanCharge = LoanFixtures.createLoanCharge(
			loan.Id,
			Date.Today().addDays(10),
			'Release Charge',
			200.00
		);

		Test.startTest();
		try {
			insert newLoanCharge;
			Assert.fail('Exception should have been thrown');
		} catch (System.DmlException ex) {
			Assert.isTrue(
				ex.getMessage()
					.contains('Cannot be assoiated with multiple charges'),
				'expected validation message should have been provided'
			);
		}
		Test.stopTest();
	}

	private static Loan__c createInitialLoanRecord(final Date currentDate) {
		final Account acc = LoanFixtures.createAccount();
		insert acc;
		final Loan__c loan = LoanFixtures.createLoan(acc.id, currentDate);
		insert loan;
		return loan;
	}
}
