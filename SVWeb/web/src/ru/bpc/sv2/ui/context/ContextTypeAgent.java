package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeAgent extends ContextTypeAbstract {

	public ContextTypeAgent(){
		entityName = EntityNames.AGENT;
	}
	
	@Override
	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		FacesUtils.setSessionMapValue("OBJECT_ID", Long.valueOf(params.get("id").toString()));
		ctxBean.initCtxParams(entityName, Long.valueOf(params.get("id").toString()));
	}
}