public inherited sharing class LoanChargeTriggerHandler extends ATriggerHandler {
	@TestVisible
	private static Boolean performDMLOverride;

	private List<Loan__c> loansToUpdate = new List<Loan__c>();

	public override void run(
		final List<SObject> newList,
		final Map<Id, SObject> newMap,
		final List<SObject> oldList,
		final Map<Id, SObject> oldMap
	) {
		List<Loan_Charge__c> newRecords = (List<Loan_Charge__c>) newList;
		Map<Id, Loan_Charge__c> newRecordsMap = (Map<Id, Loan_Charge__c>) newMap;
		Map<Id, List<Loan_Charge__c>> loanToNewChargesMap = getLoanIdToChargeMap(
			newRecords
		);

		if (this.isBefore) {
			if (this.isInsert) {
				this.validateUniqueReleaseCharge(loanToNewChargesMap);
			}

			if (this.isUpdate) {
				this.validateUniqueReleaseCharge(loanToNewChargesMap);
			}
		}

		if (this.isAfter) {
			this.calculateLoanRollup(loanToNewChargesMap.keySet());
		}

		if (this.shouldRun()) {
			if (loansToUpdate.size() > 0) {
				update loansToUpdate;
			}
		}
	}

	protected override Boolean shouldRun() {
		if (performDMLOverride != null) {
			return performDMLOverride;
		}
		return true;
	}

	private void validateUniqueReleaseCharge(
		final Map<Id, List<Loan_Charge__c>> loanIdToRecordMap
	) {
		List<Loan_Charge__c> existingCharges = [
			SELECT Id, Loan__c
			FROM Loan_Charge__c
			WHERE
				Loan__c IN :loanIdToRecordMap.keySet()
				AND Charge_Type__c = 'Release Charge'
		];

		for (Loan_Charge__c existingCharge : existingCharges) {
			List<Loan_Charge__c> newCharges = loanIdToRecordMap.get(
				existingCharge.Loan__c
			);
			if (newCharges != null) {
				for (Loan_Charge__c newCharge : newCharges) {
					if (newCharge.Charge_Type__c == 'Release Charge') {
						newCharge.addError(
							'Cannot be assoiated with multiple charges'
						);
					}
				}
			}
		}
	}

	private void calculateLoanRollup(final Set<Id> loanIds) {
		calculateLoanRollup(new List<Id>(loanIds));
	}

	private void calculateLoanRollup(final List<Id> loanIds) {
		final List<Loan_Charge__c> existingCharges = [
			SELECT Id, Amount__c, Loan__c
			FROM Loan_Charge__c
			WHERE Loan__c IN :loanIds
		];

		final Map<Id, LoanSummary> results = new Map<Id, LoanSummary>();

		for (Loan_Charge__c existingCharge : existingCharges) {
			final Id loanId = existingCharge.Loan__c;
			if (results.get(loanId) == null) {
				results.put(loanId, new LoanSummary());
			}
			results.get(loanId).charges += existingCharge.Amount__c;
		}

		for (Id loanId : results.keySet()) {
			final LoanSummary summary = results.get(loanId);
			this.loansToUpdate.add(
				new Loan__c(
					Id = loanId,
					Total_Charges_on_the_Loan__c = summary.charges
				)
			);
		}
	}

	private Map<Id, List<Loan_Charge__c>> getLoanIdToChargeMap(
		final List<Loan_Charge__c> records
	) {
		final Map<Id, List<Loan_Charge__c>> loanIdToRecordMap = new Map<Id, List<Loan_Charge__c>>();
		for (Loan_Charge__c record : records) {
			final Id loanId = record.Loan__c;
			if (loanId != null) {
				if (loanIdToRecordMap.get(loanId) == null) {
					loanIdToRecordMap.put(loanId, new List<Loan_Charge__c>());
				}
				loanIdToRecordMap.get(loanId).add(record);
			}
		}
		return loanIdToRecordMap;
	}

	private class LoanSummary {
		public Decimal charges = 0.0;
	}
}
