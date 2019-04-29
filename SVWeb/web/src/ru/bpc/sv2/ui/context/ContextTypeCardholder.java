package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

public class ContextTypeCardholder extends ContextTypeAbstract {
	
	public ContextTypeCardholder(){
		entityName = EntityNames.CARDHOLDER;
	}
	
	@Override
	public void initCtxParams() {
		
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);

		ctxBean.initCtxParams(entityName, (Long)params.get("id"));
		FacesUtils.setSessionMapValue("OBJECT_ID", (Long)params.get("id"));

	}
	/* To follow a link to a form of cardholder, pass the 4th parameter:
	 * initFromContext = TRUE
	 * cardholderNumber
	 * instId
	 * cardholderName
	 */
}
