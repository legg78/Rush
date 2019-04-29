package ru.bpc.sv2.ui.navigation;

import java.io.Serializable;
import java.util.List;

public class NavTreeElement extends RoleVisibility implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private boolean _leaf = false;
	private String _icon = null;
	private String _action = null;
	private String _name = null;
	private List<String> _ancestorPath = null;
	private boolean _rolesPropagated = false;
	private boolean selected;
	private boolean last;
	private Long id;
	private Long parentId;
	private String type;
	private String title;
	private String managedBeanName;

	public void setAncestorPath(List<String> ancestorPath) {
		_ancestorPath = ancestorPath;
	}

	public List<String> getAncestorPath() {
		return _ancestorPath;
	}

	public boolean isLeaf() {
		return _leaf;
	}

	public void setLeaf(boolean leaf) {
		this._leaf = leaf;
	}

	public String getIcon() {
		return _icon;
	}

	public void setIcon(String icon) {
		this._icon = icon;
	}

	//mimic getAction. Not sure which one JSF impl will call
	public String action() {
		return getAction();
	}

	public String getAction() {
		return _action;
	}

	public void setAction(String nav) {
		this._action = nav;
	}

	public String getName() {
		return _name;
	}

	public void setName(String title) {
		this._name = title;
	}

	public void setRolesPropagated(boolean rolesPropagated) {
		_rolesPropagated = rolesPropagated;
	}

	public boolean isRolesPropagated() {
		return _rolesPropagated;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getType() {
		if (type != null) {
			return type;
		}
		if (_icon == null && _leaf == true) {
			return "page";
		} else if (_icon != null && _leaf == true) {
			return "page_i";
		} else if (_icon == null && _leaf == false) {
			return "folder";
		} else if (_icon != null && _leaf == false) {
			return "folder_i";
		}
		return null;
	}

	public boolean isSelected() {
		return selected;
	}

	public void setSelected(boolean selected) {
		this.selected = selected;
	}

	public boolean isLast() {
		return last;
	}

	public void setLast(boolean last) {
		this.last = last;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	/**
	 * @return node's name with path
	 */
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getManagedBeanName() {
		return managedBeanName;
	}

	public void setManagedBeanName(String managedBeanName) {
		this.managedBeanName = managedBeanName;
	}

}
