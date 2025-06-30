public inherited sharing class LoanTriggerHandler {
	final List<Loan_Charge__c> loanChargesToInsert = new List<Loan_Charge__c>();

	public void run(
		final Boolean isBefore,
		final Boolean isAfter,
		final Boolean isInsert,
		final Boolean isUpdate,
		final Boolean isDelete,
		final List<Loan__c> newList,
		final Map<Id, Loan__c> newMap,
		final List<Loan__c> oldList,
		final Map<Id, Loan__c> oldMap
	) {
		System.debug('Start run trigger');
		if (isAfter) {
			if (isInsert) {
				for (Loan__c loan : newList) {
					loanChargesToInsert.add(createReleaseChargeRecord(loan));
				}
			}
		}

		System.debug(JSON.serialize(loanChargesToInsert));
		if (loanChargesToInsert.size() > 0) {
			insert loanChargesToInsert;
		}
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
