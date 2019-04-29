package ru.bpc.sv2.ui.administrative.users;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.administrative.users.User;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbUsers")
public class MbUsers implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private User user;
	private User newUser;

	private boolean managingNew;
	private boolean modalMode = true;
	private String backLink;
	private boolean personNeeded = false;
	private boolean searching;
	private String tabName;
	private int pageNum;
	private int rowsNum;
	private Integer defaultInst;
	private Integer defaultRole;

	private List<User> usersList;
	private int numberOfUser;
	
	public MbUsers() {
	}

	public User getUser() {
		if (user == null) {
			user = new User();
		}
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isPersonNeeded() {
		return personNeeded;
	}

	public void setPersonNeeded(boolean personNeeded) {
		this.personNeeded = personNeeded;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public Integer getDefaultInst() {
		return defaultInst;
	}

	public void setDefaultInst(Integer defaultInst) {
		this.defaultInst = defaultInst;
	}

	public Integer getDefaultRole() {
		return defaultRole;
	}

	public void setDefaultRole(Integer defaultRole) {
		this.defaultRole = defaultRole;
	}

	public int getPageNum() {
		return pageNum;
	}

	public void setPageNum(int pageNum) {
		this.pageNum = pageNum;
	}

	public User getNewUser() {
		return newUser;
	}

	public void setNewUser(User newUser) {
		this.newUser = newUser;
	}

	public List<User> getUsersList() {
		return usersList;
	}

	public void setUsersList(List<User> usersList) {
		this.usersList = usersList;
	}

	public int getRowsNum() {
		return rowsNum;
	}
	
	public void setNumberOfUser(int numberOfUser) {
		this.numberOfUser = numberOfUser;
	}
	
	public int getNumberOfUser() {
		return numberOfUser;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

}
