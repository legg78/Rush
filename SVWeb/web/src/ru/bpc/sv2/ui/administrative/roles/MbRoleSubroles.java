package ru.bpc.sv2.ui.administrative.roles;

import java.io.Serializable;

import ru.bpc.sv2.administrative.roles.ComplexRole;

import org.openfaces.component.table.TreePath;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name = "MbRoleSubroles")
public class MbRoleSubroles implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
    private ComplexRole subrole;
	private TreePath nodePath;
	private ComplexRole filter;
	
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

	
	public ComplexRole getSubrole() {
		return subrole;
	}

	public void setSubrole(ComplexRole subrole) {
		this.subrole = subrole;
	}

	public ComplexRole getFilter() {
		if (filter == null)
			filter = new ComplexRole();
		return filter;
	}

	public void setFilter(ComplexRole filter) {
		this.filter = filter;
	}



}
