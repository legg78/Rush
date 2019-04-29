package ru.bpc.sv2.ui.common.application;


public interface AppWizStep {
	ApplicationWizardContext release();
	void init(ApplicationWizardContext ctx);
	boolean validate();
	/**
	 * Checks either the key fields of this step has been modified
	 * @return true if some fields that have influence to the parts 
	 * of the application that can be used by another steps have been modified.
	 */
	boolean checkKeyModifications();
	boolean getLock();
}
