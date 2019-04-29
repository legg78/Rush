package ru.bpc.sv2.ui.contextsearch;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;



import ru.bpc.sv2.ui.rules.MbRuleParams;
import ru.bpc.sv2.ui.rules.MbRules;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbRulesContext")
public class MbRulesContext extends MbRules {
	public MbRulesContext(){
		paramsBean = (MbRuleParams) ManagedBeanWrapper.getManagedBean("MbRuleParamsContext");
	}
}
