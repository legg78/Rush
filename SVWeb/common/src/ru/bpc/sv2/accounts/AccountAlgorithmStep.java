package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AccountAlgorithmStep implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer algoId;
	private Integer execOrder;
	private String step;
	private Integer seqNum;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getAlgoId() {
		return algoId;
	}

	public void setAlgoId(Integer algoId) {
		this.algoId = algoId;
	}

	public Integer getExecOrder() {
		return execOrder;
	}

	public void setExecOrder(Integer execOrder) {
		this.execOrder = execOrder;
	}

	public String getStep() {
		return step;
	}

	public void setStep(String step) {
		this.step = step;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.id);
		result.put("step", this.getStep());
		result.put("execOrder", this.getExecOrder());
		
		return result;
	}

}
