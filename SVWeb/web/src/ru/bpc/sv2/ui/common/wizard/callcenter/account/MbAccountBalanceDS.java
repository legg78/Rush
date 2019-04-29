package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbAccountBalanceDS")
public class MbAccountBalanceDS extends MbAccountOperationDS {

	private static final Logger classLogger = Logger.getLogger(MbAccountBalanceDS.class);

	@Override
	public void init(Map<String, Object> context) {
		PAGE = "/pages/common/wizard/callcenter/account/amountReasonDS.jspx";
		super.init(context);
	}

	@Override
	public List<SelectItem> getOperReasons() {
		if (operReasons == null) {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("ACCOUNT_ID", account.getId());
			operReasons = getDictUtils().getLov(LovConstants.BALANCE_TYPES_BY_ACCOUNT_ID, params);
		}
		return operReasons;
	}
}
