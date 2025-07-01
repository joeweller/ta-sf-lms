public inherited sharing class LoanChargeTriggerHandler extends ATriggerHandler {
	@TestVisible
	private static Boolean performDMLOverride;

	public override void run(
		final List<SObject> newList,
		final Map<Id, SObject> newMap,
		final List<SObject> oldList,
		final Map<Id, SObject> oldMap
	) {
		List<Loan_Charge__c> newRecords = (List<Loan_Charge__c>) newList;
		Map<Id, Loan_Charge__c> newRecordsMap = (Map<Id, Loan_Charge__c>) newMap;

		if (this.isBefore) {
			if (this.isInsert) {
				this.validateUniqueReleaseCharge(newRecords);
			}

			if (this.isUpdate) {
				this.validateUniqueReleaseCharge(newRecords);
			}
		}

		if (this.shouldRun()) {
			/**
			 * Perform DML
			 */
		}
	}

	protected override Boolean shouldRun() {
		if (performDMLOverride != null) {
			return performDMLOverride;
		}
		return true;
	}

	private void validateUniqueReleaseCharge(
		final List<Loan_Charge__c> records
	) {
		final Map<Id, List<Loan_Charge__c>> loanIdToRecordMap = getLoanIdToChargeMap(
			records
		);

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
					newCharge.addError(
						'Cannot be assoiated with multiple charges'
					);
				}
			}
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
}
