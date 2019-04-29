package ru.bpc.sv2.ui.administrative.roles;

import java.io.Serializable;

import ru.bpc.sv2.administrative.roles.ComplexRole;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name = "MbRoles")
public class MbRoles implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ComplexRole role;
	private ComplexRole roleFilter;

	private boolean modalMode = true;
	private String backLink;
	private boolean searching;
	private String tabName;
	private int rowsNum;
	private int pageNumber;
	private boolean selectMode;
	private boolean addRolesToUser;
	private boolean addRolesToProcess;
	private boolean addRolesToReport;
	private Long objectId;
	
	public MbRoles() {
	}

	public ComplexRole getRole() {
		return role;
	}

	public void setRole(ComplexRole role) {
		this.role = role;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public ComplexRole getRoleFilter() {
		return roleFilter;
	}

	public void setRoleFilter(ComplexRole roleFilter) {
		this.roleFilter = roleFilter;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public boolean isAddRolesToUser() {
		return addRolesToUser;
	}

	public void setAddRolesToUser(boolean addRolesToUser) {
		this.addRolesToUser = addRolesToUser;
	}

	public boolean isAddRolesToProcess() {
		return addRolesToProcess;
	}

	public void setAddRolesToProcess(boolean addRolesToProcess) {
		this.addRolesToProcess = addRolesToProcess;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public boolean isAddRolesToReport() {
		return addRolesToReport;
	}

	public void setAddRolesToReport(boolean addRolesToReport) {
		this.addRolesToReport = addRolesToReport;
	}
}
