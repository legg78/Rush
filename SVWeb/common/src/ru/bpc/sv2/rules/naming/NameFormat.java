package ru.bpc.sv2.rules.naming;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class NameFormat implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer instId;
	private Integer seqNum;
	private String entityType;
	private Integer nameLength;
	private String padType;
	private String padString;
	private String checkAlgorithm;
	private Integer checkPosition;
	private Integer checkBasePosition;
	private Integer checkBaseLength;
	private Integer indexRangeId;
	private String indexRangeName;
	private String instName;
	private String label;
	private String lang;
	private Boolean check;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
	
	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getNameLength() {
		return nameLength;
	}

	public void setNameLength(Integer nameLength) {
		this.nameLength = nameLength;
	}

	public String getPadType() {
		return padType;
	}

	public void setPadType(String padType) {
		this.padType = padType;
	}

	public String getPadString() {
		return padString;
	}

	public void setPadString(String padString) {
		this.padString = padString;
	}

	public String getCheckAlgorithm() {
		return checkAlgorithm;
	}

	public void setCheckAlgorithm(String checkAlgorithm) {
		this.checkAlgorithm = checkAlgorithm;
	}

	public Integer getCheckPosition() {
		return checkPosition;
	}

	public void setCheckPosition(Integer checkPosition) {
		this.checkPosition = checkPosition;
	}

	public Integer getCheckBasePosition() {
		return checkBasePosition;
	}

	public void setCheckBasePosition(Integer checkBasePosition) {
		this.checkBasePosition = checkBasePosition;
	}

	public Integer getCheckBaseLength() {
		return checkBaseLength;
	}

	public void setCheckBaseLength(Integer checkBaseLength) {
		this.checkBaseLength = checkBaseLength;
	}

	public Integer getIndexRangeId() {
		return indexRangeId;
	}

	public void setIndexRangeId(Integer indexRangeId) {
		this.indexRangeId = indexRangeId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getIndexRangeName() {
		return indexRangeName;
	}

	public void setIndexRangeName(String indexRangeName) {
		this.indexRangeName = indexRangeName;
	}

	public Boolean getCheck() {
		return check;
	}

	public void setCheck(Boolean check) {
		this.check = check;
	}

	@Override
	public NameFormat clone() throws CloneNotSupportedException{
		return (NameFormat)super.clone();		
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("entityType", getEntityType());
		result.put("nameLength", getNameLength());
		result.put("padType", getPadType());
		result.put("padString", getPadString());
		result.put("checkAlgorithm", getCheckAlgorithm());
		result.put("checkBasePosition", getCheckBasePosition());
		result.put("checkBaseLength", getCheckBaseLength());
		result.put("checkPosition", getCheckPosition());
		result.put("indexRangeId", getIndexRangeId());
		result.put("lang", getLang());
		result.put("label", getLabel());
		result.put("check", getCheck());
		return result;
	}
}
