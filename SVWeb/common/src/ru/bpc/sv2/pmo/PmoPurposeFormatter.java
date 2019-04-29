package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PmoPurposeFormatter implements IAuditableObject, Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer purposeId;
	private Integer standardId;
	private Integer versionId;
	private String messType;
	private String formatter;
	private String purposeLabel;
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
	
	public Integer getPurposeId(){
		return this.purposeId;
	}
	
	public void setPurposeId(Integer purposeId){
		this.purposeId = purposeId;
	}
	
	public Integer getStandardId(){
		return this.standardId;
	}
	
	public void setStandardId(Integer standardId){
		this.standardId = standardId;
	}
	
	public Integer getVersionId(){
		return this.versionId;
	}
	
	public void setVersionId(Integer versionId){
		this.versionId = versionId;
	}
	
	public String getMessType(){
		return this.messType;
	}
	
	public void setMessType(String messType){
		this.messType = messType;
	}
	
	public String getFormatter(){
		return this.formatter;
	}
	
	public void setFormatter(String formatter){
		this.formatter = formatter;
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

	public String getPurposeLabel() {
		return purposeLabel;
	}

	public void setPurposeLabel(String purposeLabel) {
		this.purposeLabel = purposeLabel;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("purposeId", getPurposeId());
		result.put("standardId", getStandardId());
		result.put("versionId", getVersionId());
		result.put("messType", getMessType());
		result.put("formatter", getFormatter());
		return result;
	}
}