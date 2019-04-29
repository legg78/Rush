package ru.bpc.sv2.emv;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class EmvTag implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String tag;
	private Integer minLength;
	private Integer maxLength;
	private String dataType;
	private String dataFormat;
	private String defaultValue;
	private String tagType;
	private String description;
	private String lang;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public String getTag(){
		return this.tag;
	}
	
	public void setTag(String tag){
		this.tag = tag;
	}
	
	public Integer getMinLength(){
		return this.minLength;
	}
	
	public void setMinLength(Integer minLength){
		this.minLength = minLength;
	}
	
	public Integer getMaxLength(){
		return this.maxLength;
	}
	
	public void setMaxLength(Integer maxLength){
		this.maxLength = maxLength;
	}
	
	public String getDataType(){
		return this.dataType;
	}
	
	public void setDataType(String dataType){
		this.dataType = dataType;
	}
	
	public String getDataFormat(){
		return this.dataFormat;
	}
	
	public void setDataFormat(String dataFormat){
		this.dataFormat = dataFormat;
	}
	
	public String getDefaultValue(){
		return this.defaultValue;
	}
	
	public void setDefaultValue(String defaultValue){
		this.defaultValue = defaultValue;
	}
	
	public String getTagType(){
		return this.tagType;
	}
	
	public void setTagType(String tagType){
		this.tagType = tagType;
	}
	
	public String getDescription(){
		return this.description;
	}
	
	public void setDescription(String description){
		this.description = description;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
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
		result.put("lang", this.getLang());
		result.put("tag", this.getTag());
		result.put("minLength", this.getMinLength());
		result.put("maxLength", this.getMaxLength());
		result.put("dataType", this.getDataType());
		result.put("dataFormat", this.getDataFormat());
		result.put("defaultValue", this.getDefaultValue());
		result.put("tagType", this.getTagType());
		result.put("description", this.getDescription());
		
		return result;
	}
	
}