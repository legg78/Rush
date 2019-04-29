package ru.bpc.sv2.ui.utils;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.ManagedBeanWrapper;

import java.io.Serializable;
import java.util.Map;

public abstract class MakerCheckerAction implements Serializable {
	private static final long serialVersionUID = 1L;

	enum Mode {
		NONE, MAKER, CHECKER, BOTH, DEFAULT
	}

	private Mode mode = Mode.NONE;

	public MakerCheckerAction(String makerPrivilege, String checkerPrivilege, String defaultPrivilege) {
		initMode(makerPrivilege, checkerPrivilege, defaultPrivilege);
	}

	abstract public void makerAction();
	abstract public void makerCheckerAction();
	abstract public void defaultAction();

	public void checkerAction() { } // do nothing by default

	public void noneAction() { } // do nothing by default

	public void cancel() { } // do nothing by default

	public void doAction() {
		if (isNoneMode() || isCheckerMode()) {
			return;
		}
		if (isNoneMode()) {
			noneAction();
		} else if (isCheckerMode()) {
			checkerAction();
		} else if (isMakerMode()) {
			makerAction();
		} else if(isDefaultMode()) {
			defaultAction();
		} else if(isShowConfirmation()) {
			makerCheckerAction();
		} else {
			makerAction();
		}
	}

	public boolean hasActiveAction() {
		return !(isNoneMode() || isCheckerMode());
	}

	private void initMode(String makerPrivilege, String checkerPrivilege, String defaultPrivilege) {
		Map<String, Boolean> roles = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
		boolean maker = StringUtils.isNotBlank(makerPrivilege) && roles.get(makerPrivilege);
		boolean checker = StringUtils.isNotBlank(checkerPrivilege) && roles.get(checkerPrivilege);
		boolean defaultPriv = StringUtils.isNotBlank(defaultPrivilege) && roles.get(defaultPrivilege);

		initMode(maker, checker, defaultPriv);
	}

	protected void initMode(boolean maker, boolean checker, boolean defaultPriv) {
		if (maker && checker) {
			mode = Mode.BOTH;
		} else if (maker) {
			mode = Mode.MAKER;
		} else if (checker) {
			mode = Mode.CHECKER;
		} else if (defaultPriv) {
			mode = Mode.DEFAULT;
		} else {
			mode = Mode.NONE;;
		}
	}

	public boolean isCheckerMode() {
		return (Mode.CHECKER == mode);
	}
	public boolean isMakerMode() {
		return (Mode.MAKER == mode);
	}
	public boolean isBothMode() {
		return (Mode.BOTH == mode);
	}
	public boolean isNoneMode() {
		return (Mode.NONE == mode);
	}
	public boolean isDefaultMode() {
		return (Mode.DEFAULT == mode);
	}

	public boolean isShowConfirmation() {
		return isBothMode() &&
				Boolean.TRUE.equals(SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.MAKER_CHECKER_CONFIRMATION));
	}

	public Mode getMode() {
		return mode;
	}
}
