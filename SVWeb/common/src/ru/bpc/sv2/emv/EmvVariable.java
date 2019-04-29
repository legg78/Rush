package ru.bpc.sv2.emv;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class EmvVariable implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer applicationId;
	private String variableType;
	private String profile;
	private String name;
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
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Integer getApplicationId(){
		return this.applicationId;
	}
	
	public void setApplicationId(Integer applicationId){
		this.applicationId = applicationId;
	}
	
	public String getVariableType(){
		return this.variableType;
	}
	
	public void setVariableType(String variableType){
		this.variableType = variableType;
	}
	
	public String getProfile(){
		return this.profile;
	}
	
	public void setProfile(String profile){
		this.profile = profile;
	}
	
	public String getName(){
		return this.name;
	}
	
	public void setName(String name){
		this.name = name;
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
		result.put("variableType", this.getVariableType());
		result.put("profile", this.getProfile());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		
		return result;
	}
	
}