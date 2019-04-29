package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.List;

public class MenuNode implements Cloneable, Serializable {
	private Integer id;
	private Integer parentId;
	private String name;
	private Integer privId;
	private String action;
	private String type;
	private Integer level;
	private boolean isLeaf;
	private String label;
	private List<MenuNode> children;
	private String lang;
	private Integer displayOrder;
	private String managedBeanName;
	private boolean visible;
	
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getParentId() {
		return parentId;
	}

	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getPrivId() {
		return privId;
	}

	public void setPrivId(Integer privId) {
		this.privId = privId;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public List<MenuNode> getChildren() {
		return children;
	}

	public void setChildren(List<MenuNode> children) {
		this.children = children;
	}

	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public boolean isFolder() {
		return "folder".equalsIgnoreCase(type);
	}

	public String getManagedBeanName() {
		return managedBeanName;
	}

	public void setManagedBeanName(String managedBeanName) {
		this.managedBeanName = managedBeanName;
	}

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean visible) {
		this.visible = visible;
	}
}
