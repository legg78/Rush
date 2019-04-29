package ru.bpc.sv2.ui.context;

import java.util.List;
import java.util.Map;

import ru.bpc.sv2.acm.AcmAction;

public interface ContextType {
	public void setParams(Map<String,Object> params);
	public AcmAction getSelectedCtxItem();
	public void setSelectedCtxItem(AcmAction selectedCtxItem);
	public void initCtxParams();
	public void prepareDefaultAction();
	public AcmAction getDefaultAction();
	public String ctxPageForward();
	public List <AcmAction> getMenuItems();
}
