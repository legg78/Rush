package ru.bpc.sv2.security;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class DesKey implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private String keyType;
	private String keyPrefix;
	private String keyLength;
	private Integer keyIndex;
	private Integer componentsNumber;
	private String checkValue;
	private String keyValue;
	private String entityType;
	private String keyEncriptionType;
	private Long objectId;
	private boolean printComponents;
	private Integer formatId;
	private Integer hsmId;
	private Integer lmkId;
	private String lmkDescription;
	private String destKeyPrefix;
	private String standardKeyType;
	private String objectDescription;
	private Boolean checkKcv;
	private Integer keySchemaId;
    private Date generateDate;
    private String generateUserName;

	
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

	public String getKeyType() {
		return keyType;
	}

	public void setKeyType(String keyType) {
		this.keyType = keyType;
	}

	public String getKeyPrefix() {
		return keyPrefix;
	}

	public void setKeyPrefix(String keyPrefix) {
		this.keyPrefix = keyPrefix;
	}

	public String getKeyLength() {
		return keyLength;
	}

	public void setKeyLength(String keyLength) {
		this.keyLength = keyLength;
	}

	public String getCheckValue() {
		return checkValue;
	}

	public void setCheckValue(String checkValue) {
		this.checkValue = checkValue;
	}

	public String getKeyValue() {
		return keyValue;
	}

	public void setKeyValue(String keyValue) {
		this.keyValue = keyValue;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	@Override
	public DesKey clone() throws CloneNotSupportedException {
		return (DesKey)super.clone();
	}

	public Integer getKeyIndex() {
		return keyIndex;
	}

	public void setKeyIndex(Integer keyIndex) {
		this.keyIndex = keyIndex;
	}

	public Integer getComponentsNumber() {
		return componentsNumber;
	}

	public void setComponentsNumber(Integer componentsNumber) {
		this.componentsNumber = componentsNumber;
	}

	public String getKeyEncriptionType() {
		return keyEncriptionType;
	}

	public void setKeyEncriptionType(String keyEncriptionType) {
		this.keyEncriptionType = keyEncriptionType;
	}

	public boolean isPrintComponents() {
		return printComponents;
	}

	public void setPrintComponents(boolean printComponents) {
		this.printComponents = printComponents;
	}

	public Integer getFormatId() {
		return formatId;
	}

	public void setFormatId(Integer formatId) {
		this.formatId = formatId;
	}

	public Integer getHsmId() {
		return hsmId;
	}

	public void setHsmId(Integer hsmId) {
		this.hsmId = hsmId;
	}

	public Integer getLmkId() {
		return lmkId;
	}

	public void setLmkId(Integer lmkId) {
		this.lmkId = lmkId;
	}

	public String getLmkDescription() {
		return lmkDescription;
	}

	public void setLmkDescription(String lmkDescription) {
		this.lmkDescription = lmkDescription;
	}

	public String getDestKeyPrefix() {
		return destKeyPrefix;
	}

	public void setDestKeyPrefix(String destKeyPrefix) {
		this.destKeyPrefix = destKeyPrefix;
	}

	public String getStandardKeyType() {
		return standardKeyType;
	}

	public void setStandardKeyType(String standardKeyType) {
		this.standardKeyType = standardKeyType;
	}

	public Boolean getCheckKcv() {
		return checkKcv;
	}

	public void setCheckKcv(Boolean checkKcv) {
		this.checkKcv = checkKcv;
	}

	public String getObjectDescription() {
		return objectDescription;
	}

	public void setObjectDescription(String objectDescription) {
		this.objectDescription = objectDescription;
	}

	public Integer getKeySchemaId() {
		return keySchemaId;
	}

	public void setKeySchemaId(Integer keySchemaId) {
		this.keySchemaId = keySchemaId;
	}

    public Date getGenerateDate() {
        return generateDate;
    }

    public void setGenerateDate(Date generateDate) {
        this.generateDate = generateDate;
    }

    public String getGenerateUserName() {
        return generateUserName;
    }

    public void setGenerateUserName(String generateUserName) {
        this.generateUserName = generateUserName;
    }

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("objectId", getObjectId());
		result.put("entityType", getEntityType());
		result.put("hsmId", getHsmId());
		result.put("standardKeyType", getStandardKeyType());
		result.put("keyIndex", getKeyIndex());
		result.put("keyLength", getKeyLength());
		result.put("keyValue", getKeyValue());
		result.put("keyPrefix", getKeyPrefix());
		result.put("checkValue", getCheckValue());
		result.put("checkKcv", getCheckKcv());
		result.put("componentsNumber", getComponentsNumber());
		result.put("formatId", getFormatId());
		result.put("keyEncriptionType", getKeyEncriptionType());
		result.put("destKeyPrefix", getDestKeyPrefix());
		return result;
	}

}
