package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportTag implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer reportId;
	private Integer id;
	private String label;
	private String description;
	private String lang;
	private Integer instId;
	private Integer seqNum;
	private String instName;
	
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getReportId(){
		return this.reportId;
	}
	
	public void setReportId(Integer reportId){
		this.reportId = reportId;
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer tagId){
		this.id = tagId;
	}
	
	public String getLabel(){
		return this.label;
	}
	
	public void setLabel(String tagLabel){
		this.label = tagLabel;
	}
	
	public String getDescription(){
		return this.description;
	}
	
	public void setDescription(String tagDescription){
		this.description = tagDescription;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}
	
	public Object clone() throws CloneNotSupportedException{
		return super.clone();
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

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("label", getLabel());
		result.put("description", getDescription());
		result.put("lang", getLang());
		return result;
	}
}