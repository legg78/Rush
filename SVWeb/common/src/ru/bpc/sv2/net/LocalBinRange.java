package ru.bpc.sv2.net;

import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;

public class LocalBinRange extends BinRange implements Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	
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

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public LocalBinRange clone() throws CloneNotSupportedException {
		
		return (LocalBinRange) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("panLow", getPanLow());
		result.put("panHigh", getPanHigh());
		result.put("panLength", getPanLength());
		result.put("priority", getPriority());
		result.put("cardTypeId", getCardTypeId());
		result.put("country", getCountry());
		result.put("issNetworkId", getIssNetworkId());
		result.put("issInstId", getIssInstId());
		result.put("cardNetworkId", getCardNetworkId());
		result.put("cardInstId", getCardInstId());
		return result;
	}
	
}
