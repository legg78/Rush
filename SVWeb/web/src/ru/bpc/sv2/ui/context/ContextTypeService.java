package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeService extends ContextTypeAbstract {
	
	public ContextTypeService(){
		entityName = EntityNames.SERVICE;
	}
	
	@Override
	public void initCtxParams() {
		
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		ctxBean.initCtxParams(entityName, Long.valueOf(params.get("id").toString()));
		FacesUtils.setSessionMapValue("OBJECT_ID", Long.valueOf(params.get("id").toString()));

	}
	/* To follow a link to a form of service, pass the 2th parameter:
	 * instId
	 * serviceName
	 */
	@Override
	public String ctxPageForward() {
		if (selectedCtxItem == null) return null;
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		setSessParams(params, "instId");
		setSessParams(params, "serviceName");
		
//		FacesUtils.setSessionMapValue("backLink", thisBackLink);
		return selectedCtxItem.getAction();
	}
}
