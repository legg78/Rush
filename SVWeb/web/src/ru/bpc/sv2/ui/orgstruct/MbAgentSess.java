package ru.bpc.sv2.ui.orgstruct;

import java.io.Serializable;

import ru.bpc.sv2.orgstruct.Agent;

import org.openfaces.component.table.TreePath;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbAgentSess")
public class MbAgentSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
	private TreePath nodePath;
	private Agent filter;
	private boolean loadImmediately;
	
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

	public Agent getFilter() {
		return filter;
	}

	public void setFilter(Agent filter) {
		this.filter = filter;
	}

	public boolean isLoadImmediately() {
		return loadImmediately;
	}

	public void setLoadImmediately(boolean loadImmediately) {
		this.loadImmediately = loadImmediately;
	}
	
}
