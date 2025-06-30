@isTest
private class LoanTriggerHandlerTestInt {
	@isTest
	private static void shouldCreateLoanChargeOnInsert() {
		final Date currentDate = Date.Today();

		final Account acc = createAccount();
		insert acc;
		final Loan__c loan = createLoan(acc.id, currentDate);

		Test.startTest();
		insert loan;
		Test.stopTest();

		Loan_Charge__c[] loanCharges = fetchLoanCharges(loan.id);

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

	private static Loan__c createLoan(
		final Id accountId,
		final Date loanIssueDate
	) {
		return new Loan__c(
			Name = 'Test Loan',
			Account__c = accountId,
			Address__c = '1 Test Street, TestTown, UK',
			Gross_Loan_Amount__c = 1000.00,
			Balance_of_the_Loan__c = 0,
			Date_Loan_Issued__c = loanIssueDate,
			Term__c = 36,
			Total_Charges_on_the_Loan__c = 0
		);
	}

	private static Account createAccount() {
		return new Account(Name = 'Test Account');
	}

	private static Loan__c fetchLoan(final Id loanId) {
		return [
			SELECT
				Name,
				Account__c,
				Address__c,
				Gross_Loan_Amount__c,
				Balance_of_the_Loan__c,
				Date_Loan_Issued__c,
				Term__c,
				Total_Charges_on_the_Loan__c
			FROM Loan__c
			WHERE Id = :loanId
		];
	}

	private static Loan_Charge__c[] fetchLoanCharges(final Id loanId) {
		return [
			SELECT Name, Date__c, Charge_Type__c, Amount__c, Loan__c
			FROM Loan_Charge__c
			WHERE Loan__c = :loanId
		];
	}
}
