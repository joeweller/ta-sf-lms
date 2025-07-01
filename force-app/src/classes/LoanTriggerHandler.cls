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
		if (this.isAfter) {
			if (this.isInsert) {
				for (Loan__c loan : newLoans) {
					loanChargesToInsert.add(createReleaseChargeRecord(loan));
				}
			}
		}

		if (this.shouldRun()) {
			if (loanChargesToInsert.size() > 0) {
				insert loanChargesToInsert;
			}
		}
	}

	protected override Boolean shouldRun() {
		if (performDMLOverride != null) {
			return performDMLOverride;
		}
		return true;
	}

	private static Loan_Charge__c createReleaseChargeRecord(
		final Loan__c loan
	) {
		return new Loan_Charge__c(
			Loan__c = loan.Id,
			Date__c = Date.valueOf(loan.Date_Loan_Issued__c)
				.addMonths(Integer.valueOf(loan.Term__c)),
			Charge_Type__c = 'Release Charge',
			Amount__c = 500.00
		);
	}
}
