package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeCards extends ContextTypeAbstract {
	
	public ContextTypeCards(){
		entityName = EntityNames.CARD;
	}

	@Override
	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		FacesUtils.setSessionMapValue("instId", params.get("instId"));
		FacesUtils.setSessionMapValue("customerNumber", params.get("customerNumber"));

		FacesUtils.setSessionMapValue("OBJECT_ID", params.get("id"));
		
//		ctxBean.initCtxParams(entityName, (Long)params.get("id"));
		
	}


}
