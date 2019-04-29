package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class CardType implements Serializable, TreeIdentifiable<CardType>, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Long parentId;
	private Integer networkId;
	private String name;
	private String networkName;
	private String lang;
	private int level;
	private boolean isLeaf;
	private boolean isChecked;
	private boolean isCheckedOld;
	private List<CardType> children;
	private Integer minCount;
	private Integer avalCount;
	private Integer currentCount;
	private Integer maxCount;
	private Boolean virtual;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Integer getNetworkId() {
		return networkId;
	}
	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
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

	public boolean isChecked() {
		return isChecked;
	}
	public void setChecked(boolean checked) {
		isChecked = checked;
	}

	public boolean isCheckedOld() {
		return isCheckedOld;
	}
	public void setCheckedOld(boolean checkedOld) {
		isCheckedOld = checkedOld;
	}

	public List<CardType> getChildren() {
		return children;
	}

	public void setChildren(List<CardType> children) {
		this.children = children;
	}
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	
	public String getNetworkName() {
		return networkName;
	}
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public Integer getMinCount() {
		return minCount;
	}
	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Integer getAvalCount() {
		return avalCount;
	}
	public void setAvalCount(Integer avalCount) {
		this.avalCount = avalCount;
	}

	public Integer getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Integer currentCount) {
		this.currentCount = currentCount;
	}

	public Integer getMaxCount() {
		return maxCount;
	}
	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}

	public Boolean getVirtual() {
		return virtual;
	}

	public void setVirtual(Boolean virtual) {
		this.virtual = virtual;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + level;
		result = prime * result + ((networkId == null) ? 0 : networkId.hashCode());		
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
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
		CardType other = (CardType) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;		
		
		return true;
	}
	
	@Override
	public CardType clone() throws CloneNotSupportedException {
		return (CardType)super.clone();
	}
	
	public void copy(CardType to) {
//		to.setChildren(children);
		to.setId(id);
		to.setLang(lang);
//		to.setLeaf(isLeaf);
//		to.setLevel(level);
		to.setName(name);
		to.setParentId(parentId);
		to.setSeqNum(seqNum);
		to.setNetworkName(networkName);
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("parentId", getParentId());
		result.put("networkId", getNetworkId());
		result.put("lang", getLang());
		result.put("name", getName());
		return result;
	}
}
