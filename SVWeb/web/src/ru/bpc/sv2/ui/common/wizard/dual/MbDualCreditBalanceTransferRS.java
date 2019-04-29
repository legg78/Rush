package ru.bpc.sv2.ui.common.wizard.dual;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.operations.MbOperations;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualCreditBalanceTransferRS")
public class MbDualCreditBalanceTransferRS extends AbstractWizardStep {
	private static final Logger logger = Logger.getLogger(MbDualFeeCollectionRS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/dualCreditBalanceTransferRS.jspx";

	private String currentStatus;

	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		super.init(context, PAGE);
		setMakerCheckerMode(Mode.CHECKER);

		if (getContext().containsKey(WizardConstants.OPER_STATUS)) {
			currentStatus = (String) context.get(WizardConstants.OPER_STATUS);
		}
		getContext().put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");
		MbOperations operSearch = ManagedBeanWrapper.getManagedBean("MbOperations");
		operSearch.setOnlyUpdate(true);
		return getContext();
	}

	@Override
	public boolean validate() {
		return false;
	}

	public String getCurrentStatus() {
		return currentStatus;
	}

	public void setCurrentStatus(String currentStatus) {
		this.currentStatus = currentStatus;
	}
}
