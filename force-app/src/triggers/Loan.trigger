trigger Loan on Loan__c(after insert) {
	final Loan_Charge__c[] loanChargesToInsert = new List<Loan_Charge__c>();

	if (Trigger.isInsert) {
		for (Loan__c loan : Trigger.new) {
			//   Date issueDate = loan.Date_Loan_Issued__c;
			loanChargesToInsert.add(
				new Loan_Charge__c(
					Loan__c = loan.Id,
					Date__c = Date.valueOf(loan.Date_Loan_Issued__c)
						.addMonths(Integer.valueOf(loan.Term__c)),
					Charge_Type__c = 'Release Charge',
					Amount__c = 500.00
				)
			);
		}
	}

	if (loanChargesToInsert.size() > 0) {
		insert loanChargesToInsert;
	}
}
