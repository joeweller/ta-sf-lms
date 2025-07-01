@isTest
public inherited sharing class LoanFixtures {
	@TestVisible
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

	@TestVisible
	private static Loan_Charge__c createLoanCharge(
		final Id loanId,
		final Date chargeDate,
		final String chargeType,
		final Decimal amount
	) {
		return new Loan_Charge__c(
			Date__c = chargeDate,
			Charge_Type__c = chargeType,
			Amount__c = amount,
			Loan__c = loanId
		);
	}

	@TestVisible
	private static Account createAccount() {
		return new Account(Name = 'Test Account');
	}

	@TestVisible
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

	@TestVisible
	private static Loan_Charge__c[] fetchLoanCharges(final Id loanId) {
		return [
			SELECT Name, Date__c, Charge_Type__c, Amount__c, Loan__c
			FROM Loan_Charge__c
			WHERE Loan__c = :loanId
		];
	}
}
