package ru.bpc.sv2.ui.common.wizard.application;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.callcenter.card.MbCardOperationDS;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbFreqCardOperationDS")
public class MbFreqCardOperationDS extends MbCardOperationDS {
	public MbFreqCardOperationDS() {
		setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
		setMakerCheckerMode(Mode.MAKER);
	}
}
