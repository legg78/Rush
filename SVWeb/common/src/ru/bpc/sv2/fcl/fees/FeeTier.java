package ru.bpc.sv2.fcl.fees;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FeeTier implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = -4665571321606984711L;
	private Integer id;
	private String seqnum;
	private Integer feeId;
	private BigDecimal fixedRate;
	private BigDecimal percentRate;
	private BigDecimal minValue;
	private BigDecimal maxValue;
	private String lengthType;
	private String lengthTypeAlgorithm;
	private boolean needLengthType;
	private BigDecimal sumThreshold;
	private Long countThreshold;
	private Date startDate;
	private Integer instId;

	public FeeTier() {}

	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(String seqnum) {
		this.seqnum = seqnum;
	}

	public Integer getFeeId() {
		return feeId;
	}
	public void setFeeId(Integer feeId) {
		this.feeId = feeId;
	}

	public String getLengthType() {
		return lengthType;
	}
	public void setLengthType(String lengthType) {
		this.lengthType = lengthType;
	}

	public String getLengthTypeAlgorithm() {
		return lengthTypeAlgorithm;
	}
	public void setLengthTypeAlgorithm(String lengthTypeAlgorithm) {
		this.lengthTypeAlgorithm = lengthTypeAlgorithm;
	}

	public boolean isNeedLengthType() {
		return needLengthType;
	}
	public void setNeedLengthType(boolean needLengthType) {
		this.needLengthType = needLengthType;
	}

	public BigDecimal getFixedRate() {
		return fixedRate;
	}
	public void setFixedRate(BigDecimal fixedRate) {
		this.fixedRate = fixedRate;
	}

	public BigDecimal getPercentRate() {
		return percentRate;
	}
	public void setPercentRate(BigDecimal percentRate) {
		this.percentRate = percentRate;
	}

	public BigDecimal getMinValue() {
		return minValue;
	}
	public void setMinValue(BigDecimal minValue) {
		this.minValue = minValue;
	}

	public BigDecimal getMaxValue() {
		return maxValue;
	}
	public void setMaxValue(BigDecimal maxValue) {
		this.maxValue = maxValue;
	}

	public BigDecimal getSumThreshold() {
		return sumThreshold;
	}
	public void setSumThreshold(BigDecimal sumThreshold) {
		this.sumThreshold = sumThreshold;
	}

	public Long getCountThreshold() {
		return countThreshold;
	}
	public void setCountThreshold(Long countThreshold) {
		this.countThreshold = countThreshold;
	}

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + feeId;
		result = prime * result + id;
		result = prime * result + ((instId == null) ? 0 : instId.hashCode());
		result = prime * result
				+ ((startDate == null) ? 0 : startDate.hashCode());
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		FeeTier other = (FeeTier) obj;
		if (id != other.id)
			return false;
		return true;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		FeeTier clone = (FeeTier) super.clone();
		if (startDate != null) {
			clone.setStartDate(new Date(startDate.getTime()));
		}
		return clone;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("countThreshold", this.getCountThreshold());
		result.put("sumThreshold", this.getSumThreshold());
		result.put("fixedRate", this.getFixedRate());
		result.put("percentRate", this.getPercentRate());
		result.put("minValue", this.getMinValue());
		result.put("maxValue", this.getMaxValue());
		result.put("lengthType", this.getLengthType());
		result.put("lengthTypeAlgorithm", this.getLengthTypeAlgorithm());
		return result;
	}
}