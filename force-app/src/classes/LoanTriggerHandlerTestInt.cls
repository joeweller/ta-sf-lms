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
			'Loan charge date should be the date of loan issue advanced by the term'
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

	private static void shouldApplyAdminChargeWhenLoanTermIsChanged() {
		final Date currentDate = Date.Today();

		final Account acc = LoanFixtures.createAccount();
		insert acc;
		final Loan__c loan1 = LoanFixtures.createLoan(acc.id, currentDate);
		final Loan__c loan2 = LoanFixtures.createLoan(acc.id, currentDate);

		Test.startTest();
		insert new List<Loan__c>{ loan1, loan2 };
		Test.stopTest();

		Loan_Charge__c[] loan1Charges = LoanFixtures.fetchLoanCharges(loan1.id);

		Assert.areEqual(
			loan1Charges.size(),
			1,
			'1 loan charge should be created'
		);

		Loan_Charge__c initialCharge1 = loan1Charges[0];
		Assert.areEqual(
			initialCharge1.Date__c,
			currentDate.addMonths(36),
			'Loan charge date should be the date of loan issue advanced by the term'
		);
		Assert.areEqual(
			initialCharge1.Charge_Type__c,
			'Release Charge',
			'Initial charge should be Release Charge'
		);
		Assert.areEqual(
			initialCharge1.Amount__c,
			500.00,
			'Initial charge amount should be 500'
		);

		Loan_Charge__c[] loan2Charges = LoanFixtures.fetchLoanCharges(loan2.id);

		Assert.areEqual(
			loan2Charges.size(),
			1,
			'1 loan charge should be created'
		);

		Loan_Charge__c initialCharge2 = loan2Charges[0];
		Assert.areEqual(
			initialCharge2.Date__c,
			currentDate.addMonths(36),
			'Loan charge date should be the date of loan issue advanced by the term'
		);
		Assert.areEqual(
			initialCharge2.Charge_Type__c,
			'Release Charge',
			'Initial charge should be Release Charge'
		);
		Assert.areEqual(
			initialCharge2.Amount__c,
			500.00,
			'Initial charge amount should be 500'
		);
	}

	@isTest
	private static void shouldCreateAdminChargeWhenLoanTermUpdated() {
		final Date currentDate = Date.Today();

		final Account acc = LoanFixtures.createAccount();
		insert acc;
		final Loan__c loan = LoanFixtures.createLoan(acc.id, currentDate);
		insert loan;

		Test.startTest();
		loan.Term__c = 48;
		update loan;
		Test.stopTest();

		Loan_Charge__c[] loanCharges = LoanFixtures.fetchLoanCharges(loan.id);

		Assert.areEqual(
			2,
			loanCharges.size(),
			'2 loan charges should be present'
		);

		Loan_Charge__c adminCharge;

		for (Loan_Charge__c charge : loanCharges) {
			if (charge.Charge_Type__c == 'Admin Fee') {
				adminCharge = charge;
			}
		}

		Assert.areEqual(
			adminCharge.Date__c,
			currentDate,
			'Loan charge date should be the same as the current date'
		);
		Assert.areEqual(
			adminCharge.Charge_Type__c,
			'Admin Fee',
			'Charge should be Admin Fee'
		);
		Assert.areEqual(
			adminCharge.Amount__c,
			300.00,
			'Admin fee charge amount should be 500'
		);
	}
}
