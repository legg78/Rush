package ru.bpc.sv2.ui.orgstruct;

import java.io.Serializable;

import org.openfaces.component.table.TreePath;

import ru.bpc.sv2.orgstruct.Institution;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbInstSess")
public class MbInstSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
    private Institution selectedInstitution;
	private TreePath nodePath;
	private Institution filter;
	
	public Institution getFilter() {
		return filter;
	}

	public void setFilter(Institution filter) {
		this.filter = filter;
	}

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

	public Institution getSelectedInstitution() {
		return selectedInstitution;
	}

	public void setSelectedInstitution(Institution selectedInstitution) {
		this.selectedInstitution = selectedInstitution;
	}

}
