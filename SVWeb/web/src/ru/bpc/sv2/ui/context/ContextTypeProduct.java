package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeProduct extends ContextTypeAbstract {
	
	public ContextTypeProduct(){
		entityName = EntityNames.PRODUCT;
	}
	
	@Override
	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		FacesUtils.setSessionMapValue("OBJECT_ID", Long.valueOf(params.get("id").toString()));
		ctxBean.initCtxParams(entityName, Long.valueOf(params.get("id").toString()));
		
	}
	/* To follow a link to a form of product, pass the 4th parameter:
	 * initFromContext = TRUE
	 * contractType
	 * instId
	 * objectType
	 */
	@Override
	public String ctxPageForward() {
		if (selectedCtxItem == null) return null;
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		setSessParams(params, "contractType");
		setSessParams(params, "instId");
		setSessParams(params, "objectType");
		setSessParams(params, "productName");
		
//		FacesUtils.setSessionMapValue("backLink", thisBackLink);
		return selectedCtxItem.getAction();
	}
}
