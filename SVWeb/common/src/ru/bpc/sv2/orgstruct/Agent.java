package ru.bpc.sv2.orgstruct;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;


public class Agent extends OrgStructType implements Cloneable, IAuditableObject, TreeIdentifiable<Agent> {

	private static final long serialVersionUID = 1L;

	private Long userId;
	private Integer instId;
	private boolean isDefault;
	private String instName;
	private String externalNumber;
	private String statusReason;

	public Object getModelId() {
		return getId();
	}

	@Override
	public boolean isAgent() {
		return true;
	}

	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public boolean isDefault() {
		return isDefault;
	}
	public void setDefault(boolean isDefault) {
		this.isDefault = isDefault;
	}

	public String getExternalNumber() {
		return externalNumber;
	}
	public void setExternalNumber(String externalNumber) {
		this.externalNumber = externalNumber;
	}

	@SuppressWarnings("unchecked")
	public List<Agent> getChildren() {
		return (List<Agent>) children;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((instId == null) ? 0 : instId.hashCode());
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + ((seqNum == null) ? 0 : seqNum.hashCode());
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
		Agent other = (Agent) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (instId == null) {
			if (other.instId != null)
				return false;
		} else if (!instId.equals(other.instId))
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
	public Agent clone() throws CloneNotSupportedException {
		Agent agent = (Agent) super.clone();
		
		// deep copy
		if (agent.getChildren() != null && agent.getChildren().size() > 0) {
		List<Agent> arr = agent.getChildren();
			agent.setChildren(new ArrayList<Agent>(arr.size()));
			for (Agent ag: arr) {
				agent.getChildren().add(ag);
			}
		}
		
		return agent;
	}
	
	public void incrementSeqNum() {
		seqNum++;
	}
	
	public void copy(Agent to) {
		to.setAssignedToUser(assignedToUser);
		to.setChildren(children);
		to.setDefault(isDefault);
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

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("type", getType());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("lang", getLang());
		result.put("parentId", getParentId());
		result.put("default", isDefault());
		return result;
	}
	
}
