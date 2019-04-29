package ru.bpc.sv2.issuing;

import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.rules.naming.NameIndexRange;

public class IssuerBinIndexRange extends NameIndexRange implements IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer binId;
	private Integer seqNum;
	private Integer binIndexRangeId;	// id of relation between BIN and index range
										// ("ID" field of ISS_UI_BIN_INDEX_RANGE_VW) 
	
	public Object getModelId() {
		return getBinIndexRangeId();
	}
	
	public Integer getBinId() {
		return binId;
	}
	
	public void setBinId(Integer binId) {
		this.binId = binId;
	}
	
	public Integer getBinIndexRangeId() {
		return binIndexRangeId;
	}

	public void setBinIndexRangeId(Integer binIndexRangeId) {
		this.binIndexRangeId = binIndexRangeId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
	
	public NameIndexRange getNameIndexRange() {
		NameIndexRange range = new NameIndexRange();
		range.setId(id);
		range.setAlgorithm(algorithm);
		range.setCurrentValue(currentValue);
		range.setEntityType(entityType);
		range.setLowValue(lowValue);
		range.setHighValue(highValue);
		range.setInstId(instId);
		range.setInstName(instName);
		range.setName(name);
		range.setLang(lang);
		
		return range;
	}
	
	public void setNameIndexRange(NameIndexRange range) {
		id = range.getId();
		algorithm = range.getAlgorithm();
		currentValue = range.getCurrentValue();
		entityType = range.getEntityType();
		lowValue = range.getLowValue();
		highValue = range.getHighValue();
		instId = range.getInstId();
		instName = range.getInstName();
		name = range.getName();
		lang = range.getLang();
	}

	@Override
	public IssuerBinIndexRange clone() throws CloneNotSupportedException {
		return (IssuerBinIndexRange) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("entityType", getEntityType());
		result.put("algorithm", getAlgorithm());
		result.put("lowValue", getLowValue());
		result.put("highValue", getHighValue());
		result.put("currentValue", getCurrentValue());
		result.put("lang", getLang());
		result.put("name", getName());
		result.put("binIndexRangeId", getBinIndexRangeId());
		result.put("binId", getBinId());
		return result;
	}
}
