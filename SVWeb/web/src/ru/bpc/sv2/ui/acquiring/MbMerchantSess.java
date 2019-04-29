package ru.bpc.sv2.ui.acquiring;

import java.io.Serializable;

import org.openfaces.component.table.TreePath;

import ru.bpc.sv2.acquiring.Merchant;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbMerchantSess")
public class MbMerchantSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
	private TreePath nodePath;
	private boolean searching;
	private Merchant filter;
	
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

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public Merchant getFilter() {
		return filter;
	}

	public void setFilter(Merchant filter) {
		this.filter = filter;
	}
}
