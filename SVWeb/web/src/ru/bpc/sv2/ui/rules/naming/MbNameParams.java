package ru.bpc.sv2.ui.rules.naming;

import java.io.Serializable;

import ru.bpc.sv2.rules.naming.NameBaseParam;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbNameParams")
public class MbNameParams implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	private NameBaseParam paramsFilter;
	private NameBaseParam activeBaseParam;	
	private String tabName;
	

	public NameBaseParam getParamsFilter() {
		return paramsFilter;
	}

	public void setParamsFilter(NameBaseParam paramsFilter) {
		this.paramsFilter = paramsFilter;
	}

	public NameBaseParam getActiveBaseParam() {
		return activeBaseParam;
	}

	public void setActiveBaseParam(NameBaseParam activeBaseParam) {
		this.activeBaseParam = activeBaseParam;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
}
