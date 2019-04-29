package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class MacrosType implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer bunchTypeId;
	private Integer instId;
	private String instName;
	private Integer seqNum;
	private String name;
	private String description;
	private String lang;
	private String bunchTypeName;
	private String details;
	private String status;

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getBunchTypeId() {
		return bunchTypeId;
	}
	public void setBunchTypeId(Integer bunchTypeId) {
		this.bunchTypeId = bunchTypeId;
	}

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

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getBunchTypeName() {
		return bunchTypeName;
	}
	public void setBunchTypeName(String bunchTypeName) {
		this.bunchTypeName = bunchTypeName;
	}

	public String getDetails() {
		return details;
	}
	public void setDetails(String details) {
		this.details = details;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	@Override
	public Object getModelId() {
		return hashCode();
	}
	@Override
	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			return null;
		}
	}
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((bunchTypeId == null) ? 0 : bunchTypeId.hashCode());
		result = prime * result
				+ ((bunchTypeName == null) ? 0 : bunchTypeName.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((lang == null) ? 0 : lang.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((instId == null) ? 0 : instId.hashCode());
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
		MacrosType other = (MacrosType) obj;
		if (bunchTypeId == null) {
			if (other.bunchTypeId != null)
				return false;
		} else if (!bunchTypeId.equals(other.bunchTypeId))
			return false;
		if (bunchTypeName == null) {
			if (other.bunchTypeName != null)
				return false;
		} else if (!bunchTypeName.equals(other.bunchTypeName))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (lang == null) {
			if (other.lang != null)
				return false;
		} else if (!lang.equals(other.lang))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (instId == null) {
			if (other.instId != null)
				return false;
		} else if (!instId.equals(other.instId))
			return false;
		return true;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("bunchTypeId", this.getBunchTypeId());
		result.put("instId", this.getInstId());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		result.put("details", this.getDetails());
		return result;
	}
}
