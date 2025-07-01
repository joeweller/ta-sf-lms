public inherited sharing class LoanChargeTriggerHandler extends ATriggerHandler {
	@TestVisible
	private static Boolean performDMLOverride;

	private List<Loan_Charge__c> existingChargesCache;
	private List<Loan_Charge__c> existingReleaseChargesCache;

	private List<Loan__c> loansToUpdate = new List<Loan__c>();
	private List<Loan_Charge__c> releaseChargesToUpdate = new List<Loan_Charge__c>();

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

		this.existingChargesCache = this.getExistingReleaseCharges(
			loanToNewChargesMap.keySet()
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

	private List<Loan_Charge__c> getAllExistingCharges() {
		return this.existingChargesCache;
	}

	private List<Loan_Charge__c> getAllExistingReleaseCharges() {
		if (this.existingReleaseChargesCache == null) {
			List<Loan_Charge__c> results = new List<Loan_Charge__c>();
			for (Loan_Charge__c charge : this.getAllExistingCharges()) {
				if (charge.Charge_Type__c == 'Release Charge') {
					results.add(charge);
				}
			}
			this.existingReleaseChargesCache = results;
		}
		return this.existingReleaseChargesCache;
	}

	private List<Loan_Charge__c> getExistingReleaseCharges(
		final Set<Id> loanIds
	) {
		return [
			SELECT
				Id,
				Loan__c,
				Date__c,
				Charge_Type__c,
				Amount__c,
				Loan__r.Gross_Loan_Amount__c
			FROM Loan_Charge__c
			WHERE Loan__c IN :loanIds
		];
	}

	private void validateUniqueReleaseCharge(
		final Map<Id, List<Loan_Charge__c>> loanIdToRecordMap
	) {
		for (
			Loan_Charge__c existingCharge : this.getAllExistingReleaseCharges()
		) {
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
		final Map<Id, LoanSummary> results = new Map<Id, LoanSummary>();

		for (Loan_Charge__c existingCharge : this.getAllExistingCharges()) {
			final Id loanId = existingCharge.Loan__c;
			if (results.get(loanId) == null) {
				results.put(
					loanId,
					new LoanSummary(existingCharge.Loan__r.Gross_Loan_Amount__c)
				);
			}
			results.get(loanId).addCharge(existingCharge);
		}

		for (Id loanId : results.keySet()) {
			final LoanSummary summary = results.get(loanId);
			this.loansToUpdate.add(this.createLoanFromSummary(loanId, summary));
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

	private Loan__c createLoanFromSummary(
		final Id loanId,
		final LoanSummary summary
	) {
		return new Loan__c(
			Id = loanId,
			Total_Charges_on_the_Loan__c = summary.chargesTotal,
			Balance_of_the_Loan__c = summary.grossAmount + summary.chargesTotal
		);
	}

	private class LoanSummary {
		public Decimal grossAmount = 0.0;
		public Decimal chargesTotal = 0.0;

		public LoanSummary(final Decimal grossLoanAmount) {
			this.grossAmount = grossLoanAmount;
		}

		public void addCharge(final Loan_Charge__c record) {
			this.chargesTotal += record.Amount__c;
		}
	}
}
