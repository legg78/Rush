package ru.bpc.sv2.common.arrays;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Array implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer arrayTypeId;
	private String arrayTypeName;
	private Integer instId;
	private String instName;
	private String lang;
	private String name;
	private String description;

	private String dataType;
	private Integer lovId;
    private Integer agentId;
    private String agentName;
    private Integer modifierId;
    private String modifierName;
    private boolean isPrivate;
    private String className;
    private String agentNumber;

	private String idFilter;	// to filter objects by ID using wildcards


	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Integer getArrayTypeId() {
		return arrayTypeId;
	}

	public void setArrayTypeId(Integer arrayTypeId) {
		this.arrayTypeId = arrayTypeId;
	}

	public String getArrayTypeName() {
		return arrayTypeName;
	}

	public void setArrayTypeName(String arrayTypeName) {
		this.arrayTypeName = arrayTypeName;
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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
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

	public Object getModelId() {
		return getId();
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public Integer getLovId() {
		return lovId;
	}

	public void setLovId(Integer lovId) {
		this.lovId = lovId;
	}

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public Integer getModifierId() {
        return modifierId;
    }

    public void setModifierId(Integer modifierId) {
        this.modifierId = modifierId;
    }

    public boolean isPrivate() {
        return isPrivate;
    }

    public void setPrivate(boolean isPrivate) {
        this.isPrivate = isPrivate;
    }

    public String getAgentName() {
        return agentName;
    }

    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }

    public String getModifierName() {
        return modifierName;
    }

    public void setModifierName(String modifierName) {
        this.modifierName = modifierName;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

	public String getIdFilter() {
		return idFilter;
	}

	public void setIdFilter(String idFilter) {
		this.idFilter = idFilter;
	}

    @Override
	public Array clone() throws CloneNotSupportedException {
		return (Array) super.clone();
	}

    public String getAgentNumber() {
        return agentNumber;
    }

    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    @Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("arrayTypeId", this.getArrayTypeId());
		result.put("instId", this.getInstId());
		result.put("description", this.getDescription());
		
		return result;
	}

}
