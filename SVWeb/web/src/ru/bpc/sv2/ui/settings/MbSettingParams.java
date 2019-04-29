package ru.bpc.sv2.ui.settings;

import java.io.Serializable;

import ru.bpc.sv2.settings.SettingParam;

import org.openfaces.component.table.TreePath;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbSettingParams")
public class MbSettingParams implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
    private SettingParam selectedParam;
	private TreePath nodePath;
	private SettingParam filter;
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public SettingParam getSelectedParam() {
		return selectedParam;
	}

	public void setSelectedParam(SettingParam selectedParam) {
		this.selectedParam = selectedParam;
	}

	public SettingParam getFilter() {
		if (filter == null)
			filter = new SettingParam();
		return filter;
	}

	public void setFilter(SettingParam filter) {
		this.filter = filter;
	}



}
