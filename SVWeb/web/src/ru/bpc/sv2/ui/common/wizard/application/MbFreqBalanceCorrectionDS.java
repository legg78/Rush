package ru.bpc.sv2.ui.common.wizard.application;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbBalanceCorrectionDS;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbFreqBalanceCorrectionDS")
public class MbFreqBalanceCorrectionDS extends MbBalanceCorrectionDS {
	public MbFreqBalanceCorrectionDS() {
        setFlowId(ApplicationFlows.FRQ_BALANCE_CORRECTION);
		setMakerCheckerMode(Mode.MAKER);
	}
}
