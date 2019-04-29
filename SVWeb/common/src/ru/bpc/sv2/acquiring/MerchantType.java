package ru.bpc.sv2.acquiring;

import java.io.Serializable;
import java.util.ArrayList;

public class MerchantType implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private String type;
	private String parentType;
	private Integer instId;
	private String instName;
	private Integer branchId;
	private Integer seqNum;
	private int level;
	private boolean isLeaf;
	private ArrayList<MerchantType> children;

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getParentType() {
		return parentType;
	}

	public void setParentType(String parentType) {
		this.parentType = parentType;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getBranchId() {
		return branchId;
	}

	public void setBranchId(Integer branchId) {
		this.branchId = branchId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
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

	public ArrayList<MerchantType> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<MerchantType> children) {
		this.children = children;
	}

	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((branchId == null) ? 0 : branchId.hashCode());
		result = prime * result + ((instId == null) ? 0 : instId.hashCode());
		result = prime * result + ((type == null) ? 0 : type.hashCode());
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
		MerchantType other = (MerchantType) obj;
		if (branchId == null) {
			if (other.branchId != null)
				return false;
		} else if (!branchId.equals(other.branchId))
			return false;
		if (instId == null) {
			if (other.instId != null)
				return false;
		} else if (!instId.equals(other.instId))
			return false;
		if (type == null) {
			if (other.type != null)
				return false;
		} else if (!type.equals(other.type))
			return false;
		return true;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

}
