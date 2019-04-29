package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbProvideCreditLimitDS")
public class MbProvideCreditLimitDS extends MbAccountOperationDS {
	private static final Logger classLogger = Logger.getLogger(MbProvideCreditLimitDS.class);

	@Override
	public void init(Map<String, Object> context) {
		super.init(context);
        setDefaultReason("BLTP1001");
	}
}
