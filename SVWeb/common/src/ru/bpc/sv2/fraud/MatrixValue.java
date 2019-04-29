package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class MatrixValue implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer matrixId;
	private String xValue;
	private String yValue;
	private String matrixValue;
	
	public MatrixValue() {
	}
	
	public MatrixValue(Integer matrixId) {
		this.matrixId = matrixId;
	}

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

	public Integer getMatrixId() {
		return matrixId;
	}

	public void setMatrixId(Integer matrixId) {
		this.matrixId = matrixId;
	}

	public String getxValue() {
		return xValue;
	}

	public void setxValue(String xValue) {
		this.xValue = xValue;
	}

	public String getyValue() {
		return yValue;
	}

	public void setyValue(String yValue) {
		this.yValue = yValue;
	}

	public String getMatrixValue() {
		return matrixValue;
	}

	public void setMatrixValue(String matrixValue) {
		this.matrixValue = matrixValue;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("xValue", this.getxValue());
		result.put("yValue", this.getyValue());
		result.put("matrixValue", this.getMatrixValue());
		
		return result;
	}

}
