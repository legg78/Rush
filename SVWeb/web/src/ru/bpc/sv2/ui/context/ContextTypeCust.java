package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeCust extends ContextTypeAbstract {
	
	public ContextTypeCust(){
		entityName = EntityNames.CUSTOMER;
	}
	
	@Override
	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		ctxBean.initCtxParams(entityName, (Long)params.get("id"));
		
		FacesUtils.setSessionMapValue("OBJECT_ID", (Long)params.get("id"));
	}
	/* To follow a link to a form of Customers, pass the 4th parameter:
	 * initFromContext = TRUE
	 * instId
	 * customerNumber
	 * agentId
	 */

	@Override
	public String ctxPageForward() {
		if (selectedCtxItem == null) return null;
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		setSessParams(params, "instId");
		setSessParams(params, "customerNumber");
		setSessParams(params, "agentId");
		setSessParams(params, "contractNumber");
		
//		FacesUtils.setSessionMapValue("backLink", thisBackLink);
		return selectedCtxItem.getAction();
	}
}