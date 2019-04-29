package ru.bpc.sv2.application;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationDependence implements ModelIdentifiable, Serializable {

	/**
	 *
	 */
	private static final long serialVersionUID = -4991241886310869900L;
	private Integer id;
	private Integer structId;
	private Integer dependStructId;
	private Integer seqnum;
	private String condition;
	private String dependence;
	private String description;
	private String lang;
	
	private String elementName;
	private String valueV;
	private BigDecimal valueN;
	private Date valueD;
	
	private String affectedZone;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public Integer getStructId() {
		return structId;
	}
	public void setStructId(Integer structId) {
		this.structId = structId;
	}
	public Integer getDependStructId() {
		return dependStructId;
	}
	public void setDependStructId(Integer dependStructId) {
		this.dependStructId = dependStructId;
	}
	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}
	public String getCondition() {
		return condition;
	}
	public void setCondition(String condition) {
		this.condition = condition;
	}
	public String getDependence() {
		return dependence;
	}
	public void setDependence(String dependence) {
		this.dependence = dependence;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getElementName() {
		return elementName;
	}
	public void setElementName(String elementName) {
		this.elementName = elementName;
	}
	public String getValueV() {
		return valueV;
	}
	public void setValueV(String valueV) {
		this.valueV = valueV;
	}
	public BigDecimal getValueN() {
		return valueN;
	}
	public void setValueN(BigDecimal valueN) {
		this.valueN = valueN;
	}
	public Date getValueD() {
		return valueD;
	}
	public void setValueD(Date valueD) {
		this.valueD = valueD;
	}
	public Object getModelId() {
		return getId();
	}
	public String getAffectedZone() {
		return affectedZone;
	}
	public void setAffectedZone(String affectedZone) {
		this.affectedZone = affectedZone;
	}
	
}

