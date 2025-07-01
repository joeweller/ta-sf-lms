public inherited sharing class LoanTriggerHandler extends ATriggerHandler {
	@TestVisible
	private static Boolean performDMLOverride;

	final private List<Loan_Charge__c> loanChargesToInsert = new List<Loan_Charge__c>();

	public override void run(
		final List<SObject> newList,
		final Map<Id, SObject> newMap,
		final List<SObject> oldList,
		final Map<Id, SObject> oldMap
	) {
		final List<Loan__c> newLoans = (List<Loan__c>) newList;
		final List<Loan__c> oldLoans = (List<Loan__c>) oldList;

		if (this.isAfter) {
			if (this.isInsert) {
				for (Loan__c loan : newLoans) {
					this.loanChargesToInsert.add(
						createReleaseChargeRecord(loan)
					);
				}
			}

			if (this.isUpdate) {
				this.determineApplicableAdminFee(newList, oldList);
			}
		}

		if (this.shouldRun()) {
			if (this.loanChargesToInsert.size() > 0) {
				insert this.loanChargesToInsert;
			}
		}
	}

	protected override Boolean shouldRun() {
		if (performDMLOverride != null) {
			return performDMLOverride;
		}
		return true;
	}

	private void determineApplicableAdminFee(
		final List<Loan__c> newList,
		final List<Loan__c> oldList
	) {
		for (Integer i = 0; i < newList.size(); i++) {
			final Loan__c newLoan = newList[i];
			final Loan__c oldLoan = oldList[i];

			if (newLoan.Term__c != oldLoan.Term__c) {
				this.loanChargesToInsert.add(createAdminChargeRecord(newLoan));
			}
		}
	}

	private static Loan_Charge__c createReleaseChargeRecord(
		final Loan__c loan
	) {
		return createChargeRecord(
			loan.Id,
			Date.valueOf(loan.Date_Loan_Issued__c)
				.addMonths(Integer.valueOf(loan.Term__c)),
			'Release Charge',
			500.00
		);
	}

	private static Loan_Charge__c createAdminChargeRecord(final Loan__c loan) {
		return createChargeRecord(
			loan.Id,
			Date.today(),
			'Admin Fee',
			300.00
		);
	}

	private static Loan_Charge__c createChargeRecord(
		final Id loanId,
		final Date chargeDate,
		final String chargeType,
		final Decimal amount
	) {
		return new Loan_Charge__c(
			Loan__c = loanId,
			Date__c = chargeDate,
			Charge_Type__c = chargeType,
			Amount__c = amount
		);
	}
}
