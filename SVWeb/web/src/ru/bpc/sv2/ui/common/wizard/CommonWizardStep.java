package ru.bpc.sv2.ui.common.wizard;

import java.util.Map;

public interface CommonWizardStep {
	String MAKER_CHECKER_MODE = "MAKER_CHECKER_MODE";
	String MAKER_CHECKER_NOTIFIED = "MAKER_CHECKER_NOTIFIED";
	String MAKER_CHECKER = "MAKER_CHECKER_CONTEXT";

	enum Mode {
		NONE, MAKER, CHECKER, BOTH
	}

	enum Direction {
		BACK, FORWARD
	}

	void init(Map<String, Object> context);

	Map<String, Object> release(Direction direction);

	boolean validate();
}
