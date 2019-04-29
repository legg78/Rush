package ru.bpc.sv2.issuing;

import java.io.Serializable;
import java.util.ArrayList;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CommonHierarchyObject implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long parentId;
	private String name;
	private int uniqueIndex;
	private String entityType;
	private Long agentId;
	
	private int level;
	private boolean isLeaf;
	private ArrayList<CommonHierarchyObject> children;
	private Object object;
	private boolean errorNode;
	
	public CommonHierarchyObject() {
	}

	public CommonHierarchyObject(boolean errorNode) {
		this.errorNode = errorNode;
	}

	public Object getModelId() {
		return entityType + "_" + id + "_" + uniqueIndex;
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

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getUniqueIndex() {
		return uniqueIndex;
	}

	public void setUniqueIndex(int uniqueIndex) {
		this.uniqueIndex = uniqueIndex;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
	
	public Long getAgentId() {
		return agentId;
	}

	public void setAgentId(Long agentId) {
		this.agentId = agentId;
	}

	public Object getObject() {
		return object;
	}

	public void setObject(Object object) {
		this.object = object;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public ArrayList<CommonHierarchyObject> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<CommonHierarchyObject> children) {
		this.children = children;
	}

	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public boolean isErrorNode() {
		return errorNode;
	}

	public void setErrorNode(boolean errorNode) {
		this.errorNode = errorNode;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((agentId == null) ? 0 : agentId.hashCode());
		result = prime * result
				+ ((entityType == null) ? 0 : entityType.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + level;
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + uniqueIndex;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		CommonHierarchyObject other = (CommonHierarchyObject) obj;
		if (agentId == null) {
			if (other.agentId != null)
				return false;
		} else if (!agentId.equals(other.agentId))
			return false;
		if (entityType == null) {
			if (other.entityType != null)
				return false;
		} else if (!entityType.equals(other.entityType))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (level != other.level)
			return false;
		if (parentId == null) {
			if (other.parentId != null)
				return false;
		} else if (!parentId.equals(other.parentId))
			return false;
		if (uniqueIndex != other.uniqueIndex)
			return false;
		return true;
	}

}
