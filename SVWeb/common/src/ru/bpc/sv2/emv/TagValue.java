package ru.bpc.sv2.emv;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class TagValue implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Long objectId;
	private String entityType;
	private Integer tagId;
	private String tagValue;
	private String profile;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
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
	
	public Integer getTagId(){
		return this.tagId;
	}
	
	public void setTagId(Integer tagId){
		this.tagId = tagId;
	}
	
	public String getTagValue(){
		return this.tagValue;
	}
	
	public void setTagValue(String tagValue){
		this.tagValue = tagValue;
	}
	
	public String getProfile(){
		return this.profile;
	}
	
	public void setProfile(String profile){
		this.profile = profile;
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

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("profile", this.getProfile());
		result.put("tagValue", this.getTagValue());
		
		return result;
	}
}