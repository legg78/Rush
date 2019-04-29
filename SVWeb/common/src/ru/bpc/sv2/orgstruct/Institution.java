package ru.bpc.sv2.orgstruct;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;


public class Institution extends OrgStructType implements Cloneable, TreeIdentifiable<Institution>, IAuditableObject {
	public static final int DEFAULT_INSTITUTION = 9999;
	private static final long serialVersionUID = 1L;

	private Long userId;
	private Integer networkId;
	private String networkName;
	private boolean changed = false;
	private String command;
	private String institutionNumber = null;
	private String status;
	private String statusReason;

	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public Integer getNetworkId() {
		return networkId;
	}
	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public String getNetworkName() {
		return networkName;
	}
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public boolean isChanged() {
		return changed;
	}
	public void setChanged(boolean changed) {
		this.changed = changed;
	}

	public String getCommand() {
		return command;
	}
	public void setCommand(String command) {
		this.command = command;
	}

	public void copy(Institution to, boolean copyChildren) {
		to.setAssignedToUser(assignedToUser);
		to.setDefaultForUser(defaultForUser);
		to.setDescription(description);
		to.setId(id);
		to.setLang(lang);
		to.setLeaf(isLeaf);
		to.setLevel(level);
		to.setName(name);
		to.setParentId(parentId);
		to.setSeqNum(seqNum);
		to.setType(type);
		to.setNetworkId(networkId);
		to.setNetworkName(networkName);
		to.setInstitutionNumber(institutionNumber);
		if (copyChildren && children != null && children.size() > 0) {
			to.setChildren(new ArrayList<Institution>(children.size()));
			for (Institution child: getChildren()) {
				try {
					to.getChildren().add(child.clone());
				} catch (CloneNotSupportedException e) {
					to.getChildren().add(child);
				}
			}
		}
	}

	public String getInstitutionNumber() {
		return institutionNumber;
	}
	public void setInstitutionNumber(String number) {
		this.institutionNumber = number;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	@SuppressWarnings("unchecked")
	@Override
	public ArrayList<Institution> getChildren() {
		return (ArrayList<Institution>) children;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("parentId", getParentId());
		result.put("type", getType());
		result.put("networkId", getNetworkId());
		result.put("description", getDescription());
		result.put("status", getStatus());
		return result;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + seqNum;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		Institution other = (Institution) obj;
		if (id == null) {
			if (other.id != null) {
				return false;
			}
		} else if (!id.equals(other.id)) {
			return false;
		}
		if (parentId == null) {
			if (other.parentId != null) {
				return false;
			}
		} else if (!parentId.equals(other.parentId)) {
			return false;
		}
		if (seqNum == null) {
			if (other.seqNum != null) {
				return false;
			}
		} else if (!seqNum.equals(other.seqNum)) {
			return false;
		}
		return true;
	}

	@Override
	public Institution clone() throws CloneNotSupportedException {
		Institution inst = (Institution) super.clone();
		if (inst.getChildren() != null && inst.getChildren().size() > 0) {
			ArrayList<Institution> arr = inst.getChildren();
			inst.setChildren(new ArrayList<Institution>(arr.size()));
			for (Institution instit: arr) {
				inst.getChildren().add(instit.clone());
			}
		}
		return inst;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public boolean isAgent() {
		return false;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}
}
