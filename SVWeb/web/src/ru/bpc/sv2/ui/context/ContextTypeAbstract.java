package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class ContextTypeAbstract implements ContextType {

	protected AcmAction selectedCtxItem;
	protected AcmAction defaultAction;
	protected Map<String, Object> params;

	String entityName;

	@Override
	public void setParams(Map<String, Object> params) {
		this.params = params;
	}

	@Override
	public AcmAction getSelectedCtxItem() {
		return selectedCtxItem;
	}

	@Override
	public void setSelectedCtxItem(AcmAction selectedCtxItem) {
		this.selectedCtxItem = selectedCtxItem;
	}

	@Override
	public void prepareDefaultAction() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctx.setEntityType(entityName);
		if (params.containsKey("objectType")) {
			ctx.setObjectType((String) params.get("objectType"));
		} else {
			ctx.setObjectType(null);
		}
		defaultAction = ctx.getDefaultAction((Integer) params.get("instId"));
		selectedCtxItem = defaultAction;
	}

	@Override
	public AcmAction getDefaultAction() {
		return defaultAction;
	}

	@Override
	public String ctxPageForward() {
		if (selectedCtxItem == null)
			return null;
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
//		FacesUtils.setSessionMapValue("backLink", thisBackLink);

		for (Map.Entry<String, Object> entry : params.entrySet()) {
			FacesUtils.setSessionMapValue(entry.getKey(), entry.getValue());
		}

		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(selectedCtxItem.getAction());

		return selectedCtxItem.getAction();
	}

	@Override
	public List<AcmAction> getMenuItems() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		HashMap<String, List<AcmAction>> map = ctx.getMenuItems();
		if (map == null)
			return null;
		List<AcmAction> acmList = map.get(entityName);
		List<AcmAction> list = new ArrayList<AcmAction>();
		if (acmList == null) return null;
		for (AcmAction acm : acmList) {
			if (!checkAction(acm)) continue;
			if (acm.getObjectType() == null || acm.getObjectType().equals(params.get("objectType")))
				list.add(acm);
		}
		return list;
	}

	private boolean checkAction(AcmAction acm) {
		boolean check = true;
		if (acm != null) {
			if (acm.isGroup()) {
				for (AcmAction a : acm.getChildren()) {
					check = check && checkAction(a);
				}
			}
			Object selfUrl = params.get("selfUrl");
			if (selfUrl != null && !acm.isGroup()) {
				if (selfUrl instanceof List) {
					if (((List) selfUrl).contains(acm.getAction())) check = false;
				}
				if (selfUrl instanceof String) {
					if (selfUrl.equals(acm.getAction())) check = false;
				}
			}
		}
		return check;
	}

	public void setSessParams(Map<String, Object> map, String key) {
		if (map.get(key) != null)
			FacesUtils.setSessionMapValue(key, map.get(key));
	}

	@Override
	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		if (selectedCtxItem != null && params.containsKey("id") && params.get("id") != null) {
			FacesUtils.setSessionMapValue("OBJECT_ID", Long.valueOf(params.get("id").toString()));
			ctxBean.initCtxParams(entityName, Long.valueOf(params.get("id").toString()));
		}
	}

}
