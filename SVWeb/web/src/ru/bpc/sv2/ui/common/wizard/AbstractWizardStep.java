package ru.bpc.sv2.ui.common.wizard;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.ManagedBeanWrapper;
import ru.bpc.sv2.common.Lov;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.SessionWrapper;

import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class AbstractWizardStep implements CommonWizardStep {
	protected final Logger logger = Logger.getLogger(getClass());

	private Map<String, Object> context;
	private Map<Integer, List<SelectItem>> lovs;
	protected String curLang;
	protected Long userSessionId;

	private Mode mode = Mode.CHECKER;
	private int flowId = 0;
	private String operStatus;

	private transient DictUtils dictUtils;

	private CommonDao commonDao = new CommonDao();

	private String makerCheckerButtonLabel = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Form", "create_operation");

	public AbstractWizardStep() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
	}

	@Override
	public void init(Map<String, Object> context) {
		init(context, null);
	}

	protected void init(Map<String, Object> context, String page) {
		init(context, page, null);
	}

	protected void init(Map<String, Object> context, String page, Boolean validatedStep) {
		logger.trace("init...");
		this.context = context;

		if (getContext(MAKER_CHECKER_MODE) == null) {
			setMakerCheckerMode(this.mode);
		}
		if (isMaker() && !Boolean.TRUE.equals(context.get(MAKER_CHECKER_NOTIFIED)) && getMakerCheckerMode() != Mode.BOTH) {
			Boolean ask = SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.MAKER_CHECKER_CONFIRMATION);
			if (ask != null && ask) {
				FacesUtils.addWarningMessage(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "app_will_created"));
				putContext(MAKER_CHECKER_NOTIFIED, Boolean.TRUE);
			}
		}
		if (page != null) {
			putContext(MbCommonWizard.PAGE, page);
		}
		if (validatedStep != null) {
			putContext(MbCommonWizard.VALIDATED_STEP, validatedStep);
		}
	}

	public String getCurLang() {
		return curLang;
	}

	public Long getUserSessionId() {
		return userSessionId;
	}

	protected <T> void putContext(String name, T value) {
		context.put(name, value);
	}

	protected <T> T getContext(String name) {
		return (T) context.get(name);
	}

	protected <T> T getContextRequired(String name) {
		if (!context.containsKey(name)) {
			throw new IllegalStateException(name + " is not defined in wizard context");
		}
		return getContext(name);
	}

	protected Map<String, Object> getContext() {
		return context;
	}

	protected boolean isPrivilegeAssigned(String privilege) {
	    Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
		if (role != null && StringUtils.isNotEmpty(privilege)) {
			return role.get(privilege);
		} else {
			return false;
		}
	}

    protected void setMakerCheckerMode(Mode mode) {
	    this.mode = mode;
        if (context != null) {
            putContext(MAKER_CHECKER, mode);
            putContext(MAKER_CHECKER_MODE, mode);
        }
    }

	protected void setMakerCheckerMode(String makerPrivilege, String checkerPrivilege) {
		boolean maker = isPrivilegeAssigned(makerPrivilege);
		boolean checker = isPrivilegeAssigned(checkerPrivilege);
		if (maker && checker) {
			setMakerCheckerMode(Mode.BOTH);
		} else if (maker) {
			setMakerCheckerMode(Mode.MAKER);
		} else if (checker) {
			setMakerCheckerMode(Mode.CHECKER);
		} else {
			setMakerCheckerMode(Mode.NONE);
		}
	}

	protected void setFlowId(int flowId) {
		this.flowId = flowId;
	}

	protected int getFlowId() {
		return flowId;
	}

	public Mode getMakerCheckerMode() {
        Mode mode = getContext(MAKER_CHECKER_MODE);
        if (mode == null) {
            mode = this.mode;
        }
	    return mode;
    }


	public Mode getCurrentMode() {
        Mode mode = getContext(MAKER_CHECKER);
        if (mode == null) {
            mode = this.mode;
        }
        return mode;
    }

	public boolean isMaker() {
        return getCurrentMode() == Mode.MAKER;
	}

    public boolean isChecker() {
        return getCurrentMode() == Mode.CHECKER;
    }

	public boolean isMakerChecker() {
        return getCurrentMode() == Mode.BOTH;
    }

	public void setMakerChecker(Mode mode) {
		if (context != null) {
			putContext(MAKER_CHECKER, mode);
		}
	}

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public Map<Integer, List<SelectItem>> getLovs() {
        if (lovs == null) {
            lovs = new HashMap<Integer, List<SelectItem>>(0);
            List<Lov> lovList = commonDao.getLovsList(userSessionId, new SelectionParams());
            if (lovList != null) {
                for (Lov lov : lovList) {
                    if (!lov.getParametrized()) {
                        lovs.put(lov.getId(), getDictUtils().getLov(lov.getId()));
                    }
                }
            }
        }
        return lovs;
    }

    public List<SelectItem> getLov(int lovId) {
        return getDictUtils().getLov(lovId);
    }

	public String getMakerCheckerButtonLabel() {
		return makerCheckerButtonLabel;
	}

	public void setMakerCheckerButtonLabel(String makerCheckerButtonLabel) {
		this.makerCheckerButtonLabel = makerCheckerButtonLabel;
	}
}
