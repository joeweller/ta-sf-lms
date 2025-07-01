public with sharing abstract class ATriggerHandler {
	protected Boolean isBefore = false;
	protected Boolean isAfter = false;
	protected Boolean isInsert = false;
	protected Boolean isUpdate = false;
	protected Boolean isDelete = false;

	public abstract void run(
		final List<SObject> newList,
		final Map<Id, SObject> newMap,
		final List<SObject> oldList,
		final Map<Id, SObject> oldMap
	);

	protected abstract Boolean shouldRun();

	public void setIsBefore(final Boolean value) {
		this.isBefore = value;
	}

	public void setIsAfter(final Boolean value) {
		this.isAfter = value;
	}

	public void setIsInsert(final Boolean value) {
		this.isInsert = value;
	}

	public void setIsUpdate(final Boolean value) {
		this.isUpdate = value;
	}

	public void setIsDelete(final Boolean value) {
		this.isDelete = value;
	}
}
