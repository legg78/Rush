package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Matrix implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer instId;
	private String xScale;
	private String yScale;
	private String matrixType;
	private String label;
	private String description;
	private String instName;
	private String lang;
	private String xScaleDesc;
	private String yScaleDesc;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getxScale() {
		return xScale;
	}

	public void setxScale(String xScale) {
		this.xScale = xScale;
	}

	public String getyScale() {
		return yScale;
	}

	public void setyScale(String yScale) {
		this.yScale = yScale;
	}

	public String getMatrixType() {
		return matrixType;
	}

	public void setMatrixType(String matrixType) {
		this.matrixType = matrixType;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getxScaleDesc() {
		return xScaleDesc;
	}

	public void setxScaleDesc(String xScaleDesc) {
		this.xScaleDesc = xScaleDesc;
	}

	public String getyScaleDesc() {
		return yScaleDesc;
	}

	public void setyScaleDesc(String yScaleDesc) {
		this.yScaleDesc = yScaleDesc;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("matrixType", this.getMatrixType());
		result.put("xScale", this.getxScale());
		result.put("yScale", this.getyScale());
		result.put("lang", this.getLang());
		result.put("label", this.getLabel());
		result.put("description", this.getDescription());
		
		return result;
	}

}
