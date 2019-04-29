package ru.bpc.sv2.security;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class HmacKey implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long objectId;
	private String entityType;
	private Integer lmkId;
	private Integer keyIndex;
	private Integer keyLength;
	private String keyValue;
	private Date generateDate;
	private String generateUserName;
	private Long hsmId;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Long getObjectId(){
		return this.objectId;
	}
	
	public void setObjectId(Long objectId){
		this.objectId = objectId;
	}
	
	public String getEntityType(){
		return this.entityType;
	}
	
	public void setEntityType(String entityType){
		this.entityType = entityType;
	}
	
	public Integer getLmkId(){
		return this.lmkId;
	}
	
	public void setLmkId(Integer lmkId){
		this.lmkId = lmkId;
	}
	
	public Integer getKeyIndex(){
		return this.keyIndex;
	}
	
	public void setKeyIndex(Integer keyIndex){
		this.keyIndex = keyIndex;
	}
	
	public Integer getKeyLength(){
		return this.keyLength;
	}
	
	public void setKeyLength(Integer keyLength){
		this.keyLength = keyLength;
	}
	
	public String getKeyValue(){
		return this.keyValue;
	}
	
	public void setKeyValue(String keyValue){
		this.keyValue = keyValue;
	}
	
	public Date getGenerateDate(){
		return this.generateDate;
	}
	
	public void setGenerateDate(Date generateDate){
		this.generateDate = generateDate;
	}
	
	public String getGenerateUserName(){
		return this.generateUserName;
	}
	
	public void setGenerateUserName(String generateUserName){
		this.generateUserName = generateUserName;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public Long getHsmId() {
		return hsmId;
	}

	public void setHsmId(Long hsmId) {
		this.hsmId = hsmId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("objectId", getObjectId());
		result.put("entityType", getEntityType());
		result.put("hsmId", getHsmId());
		result.put("keyIndex", getKeyIndex());
		result.put("keyLength", getKeyLength());
		result.put("keyValue", getKeyValue());
		return result;
	}
}