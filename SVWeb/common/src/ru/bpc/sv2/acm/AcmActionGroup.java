package ru.bpc.sv2.acm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.orgstruct.OrgStructType;

public class AcmActionGroup extends OrgStructType implements Cloneable, IAuditableObject, TreeIdentifiable<AcmActionGroup> {

	private static final long serialVersionUID = 1L;

	private Integer instId;
	private String instName;
	private String entityType;

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Object getModelId() {
		return getId();
	}

	@Override
	public boolean isAgent() {
		return false;
	}

	@SuppressWarnings("unchecked")
	public ArrayList<AcmActionGroup> getChildren() {
		return (ArrayList<AcmActionGroup>) children;
	}

	public void copy(AcmActionGroup to) {
		to.setAssignedToUser(assignedToUser);
		to.setChildren(children);
		to.setEntityType(entityType);
		to.setDefaultForUser(defaultForUser);
		to.setDescription(description);
		to.setId(id);
		to.setInstId(instId);
		to.setLang(lang);
		to.setLeaf(isLeaf);
		to.setLevel(level);
		to.setName(name);
		to.setParentId(parentId);
		to.setSeqNum(seqNum);
		to.setType(type);
		to.setInstName(instName);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result
		        + ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + seqNum;
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
		AcmActionGroup other = (AcmActionGroup) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (parentId == null) {
			if (other.parentId != null)
				return false;
		} else if (!parentId.equals(other.parentId))
			return false;
		if (seqNum == null) {
			if (other.seqNum != null)
				return false;
		} else if (!seqNum.equals(other.seqNum))
			return false;
		return true;
	}

	@Override
	public AcmActionGroup clone() throws CloneNotSupportedException {
		AcmActionGroup actionGroup = (AcmActionGroup) super.clone();

		if (actionGroup.getChildren() != null && actionGroup.getChildren().size() > 0) {
			ArrayList<AcmActionGroup> arr = actionGroup.getChildren();
			actionGroup.setChildren(new ArrayList<AcmActionGroup>(arr.size()));
			for (AcmActionGroup instit : arr) {
				actionGroup.getChildren().add(instit.clone());
			}
		}

		return actionGroup;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("entityType", this.getEntityType());
		result.put("parentId", this.getParentId());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		
		return result;
	}

}
