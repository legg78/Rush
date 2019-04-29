package ru.bpc.sv2.common.arrays;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ArrayConversion implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer inArrayId;
	private String inArrayName;
	private Integer inLovId;
	private String inLovName;
	private Integer outArrayId;
	private String outArrayName;
	private Integer outLovId;
	private String outLovName;
	private String convType;
	private String lang;
	private String name;
	private String description;
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

	public Integer getInArrayId() {
		return inArrayId;
	}

	public void setInArrayId(Integer inArrayId) {
		this.inArrayId = inArrayId;
	}

	public String getInArrayName() {
		return inArrayName;
	}

	public void setInArrayName(String inArrayName) {
		this.inArrayName = inArrayName;
	}

	public Integer getInLovId() {
		return inLovId;
	}

	public void setInLovId(Integer inLovId) {
		this.inLovId = inLovId;
	}

	public String getInLovName() {
		return inLovName;
	}

	public void setInLovName(String inLovName) {
		this.inLovName = inLovName;
	}

	public Integer getOutArrayId() {
		return outArrayId;
	}

	public void setOutArrayId(Integer outArrayId) {
		this.outArrayId = outArrayId;
	}

	public String getOutArrayName() {
		return outArrayName;
	}

	public void setOutArrayName(String outArrayName) {
		this.outArrayName = outArrayName;
	}

	public Integer getOutLovId() {
		return outLovId;
	}

	public void setOutLovId(Integer outLovId) {
		this.outLovId = outLovId;
	}

	public String getOutLovName() {
		return outLovName;
	}

	public void setOutLovName(String outLovName) {
		this.outLovName = outLovName;
	}

	public String getConvType() {
		return convType;
	}

	public void setConvType(String convType) {
		this.convType = convType;
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

    public String getIdFilter() {
        return idFilter;
    }

    public void setIdFilter(String idFilter) {
        this.idFilter = idFilter;
    }

	@Override
	public ArrayConversion clone() throws CloneNotSupportedException {
		return (ArrayConversion) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("inArrayId", this.getInArrayId());
		result.put("inLovId", this.getInLovId());
		result.put("outArrayId", this.getOutArrayId());
		result.put("outLovId", this.getOutLovId());
		result.put("convType", this.getConvType());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		
		return result;
	}

}
