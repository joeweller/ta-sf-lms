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

	@IsTest
	private static void shouldUpdateLoanChargesWhenNewLoanIsCreated() {
		final Date currentDate = Date.Today();

		final Loan__c loan;
		Test.startTest();
		loan = createInitialLoanRecord(currentDate);
		Test.stopTest();

		final Loan__c updatedLoan = LoanFixtures.fetchLoan(loan.Id);
		Assert.areEqual(
			500,
			updatedLoan.Total_Charges_on_the_Loan__c,
			'loan charges should equal release charge amount'
		);
	}

	@IsTest
	private static void shouldUpdateLoanChargesWhenNewLoanChargeIsCreated() {
		final Date currentDate = Date.Today();

		final Loan__c loan = createInitialLoanRecord(currentDate);
		final Loan_Charge__c newCharge = LoanFixtures.createLoanCharge(
			loan.Id,
			currentDate.addDays(7),
			'Interest Charge',
			50.00
		);
		Test.startTest();
		insert newCharge;
		Test.stopTest();

		final Loan__c updatedLoan = LoanFixtures.fetchLoan(loan.Id);
		Assert.areEqual(
			550.0,
			updatedLoan.Total_Charges_on_the_Loan__c,
			'loan charges should equal release charge amount'
		);
	}

	@IsTest
	private static void shouldUpdateLoanChargesWhenNewLoanChargeIsCreatedMultiple() {
		final Date currentDate = Date.Today();

		final Loan__c loan1 = createInitialLoanRecord(currentDate);
		final Loan__c loan2 = createInitialLoanRecord(currentDate);
		final Loan_Charge__c newCharge1 = LoanFixtures.createLoanCharge(
			loan1.Id,
			currentDate.addDays(7),
			'Interest Charge',
			50.00
		);
		final Loan_Charge__c newCharge2 = LoanFixtures.createLoanCharge(
			loan2.Id,
			currentDate.addDays(7),
			'Interest Charge',
			100.00
		);
		Test.startTest();
		insert new List<Loan_Charge__c>{ newCharge1, newCharge2 };
		Test.stopTest();

		final Loan__c updatedLoan1 = LoanFixtures.fetchLoan(loan1.Id);
		Assert.areEqual(
			550.0,
			updatedLoan1.Total_Charges_on_the_Loan__c,
			'loan charges should equal release charge amount'
		);

		final Loan__c updatedLoan2 = LoanFixtures.fetchLoan(loan2.Id);
		Assert.areEqual(
			600.0,
			updatedLoan2.Total_Charges_on_the_Loan__c,
			'loan charges should equal release charge amount'
		);
	}

	private static Loan__c createInitialLoanRecord(final Date currentDate) {
		final Account acc = LoanFixtures.createAccount();
		insert acc;
		final Loan__c loan = LoanFixtures.createLoan(acc.id, currentDate);
		insert loan;
		return loan;
	}
}
