package ru.bpc.sv2.ui.common.wizard.dual;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.operations.MbOperations;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualCreateOperForNotRcnMsgRS")
public class MbDualCreateOperForNotRcnMsgRS extends AbstractWizardStep {
	private static final Logger logger = Logger.getLogger(MbDualFeeCollectionRS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/reconciliation/createOperForNotRcnMsgRS.jspx";

	private boolean freq;
	private Long operId;

	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		super.init(context, PAGE);
		setMakerCheckerMode(Mode.CHECKER);

		if (getContext().containsKey("OPER_ID")) {
			operId = (Long) context.get("OPER_ID");
		} else {
			throw new IllegalStateException("OPER_ID is not defined in wizard context");
		}

		if (getContext().containsKey("FREQ")) {
			freq = Boolean.TRUE.equals(context.get("FREQ"));
		} else {
			throw new IllegalStateException("FREQ is not defined in wizard context");
		}
		getContext().put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");
		return getContext();
	}

	@Override
	public boolean validate() {
		return false;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public boolean isFreq() {
		return freq;
	}

	public void setFreq(boolean freq) {
		this.freq = freq;
	}
}
