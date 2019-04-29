package ru.bpc.sv2.ui.context;

import java.util.Map;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeAccount extends ContextTypeAbstract {
	
	public ContextTypeAccount(){
		entityName = EntityNames.ACCOUNT;
	}
	
	@Override
	public void initCtxParams() {
		
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		ctxBean.initCtxParams(entityName, (Long)params.get("id"));
		FacesUtils.setSessionMapValue("OBJECT_ID", (Long)params.get("id"));

	}
	/* To follow a link to a form of accounts, pass the 4th parameter:
	 * initFromContext = TRUE
	 * customerNumber
	 * instId
	 * accountNumber
	 */
	@Override
	public String ctxPageForward() {
		if (selectedCtxItem == null) return null;
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		setSessParams(params, "customerNumber");
		setSessParams(params, "instId");
		setSessParams(params, "accountNumber");
		setSessParams(params, "module");
		
//		FacesUtils.setSessionMapValue("backLink", thisBackLink);
		return selectedCtxItem.getAction();
	}
}
