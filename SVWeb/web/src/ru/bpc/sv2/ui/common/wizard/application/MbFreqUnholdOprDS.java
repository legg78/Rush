package ru.bpc.sv2.ui.common.wizard.application;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbUnholdOprDS;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbFreqUnholdOprDS")
public class MbFreqUnholdOprDS extends MbUnholdOprDS {
	public MbFreqUnholdOprDS() {
	    setFlowId(ApplicationFlows.FRQ_UNHOLD_AUTHORIZATION);
		setMakerCheckerMode(Mode.MAKER);
	}
}
