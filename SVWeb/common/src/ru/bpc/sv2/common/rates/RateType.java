package ru.bpc.sv2.common.rates;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class RateType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String rateType;
	private Integer instId;
	private String instName;
	private boolean useCrossRate;
	private boolean useBaseRate;
	private boolean isReversible;
	private BigDecimal warningLevel;
	private boolean useDoubleTyping;
	private boolean useVerification;
	private boolean adjustExponent;
	private String baseCurrency;
	private Integer expPeriod;
	private Integer roundingAccuracy;
	
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

	public String getRateType() {
		return rateType;
	}

	public void setRateType(String rateType) {
		this.rateType = rateType;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public boolean isUseCrossRate() {
		return useCrossRate;
	}

	public void setUseCrossRate(boolean useCrossRate) {
		this.useCrossRate = useCrossRate;
	}

	public boolean isUseBaseRate() {
		return useBaseRate;
	}

	public void setUseBaseRate(boolean useBaseRate) {
		this.useBaseRate = useBaseRate;
	}

	public boolean isReversible() {
		return isReversible;
	}

	public void setReversible(boolean isReversible) {
		this.isReversible = isReversible;
	}

	public BigDecimal getWarningLevel() {
		return warningLevel;
	}

	public void setWarningLevel(BigDecimal warningLevel) {
		this.warningLevel = warningLevel;
	}

	public boolean isUseDoubleTyping() {
		return useDoubleTyping;
	}

	public void setUseDoubleTyping(boolean useDoubleTyping) {
		this.useDoubleTyping = useDoubleTyping;
	}

	public boolean isUseVerification() {
		return useVerification;
	}

	public void setUseVerification(boolean useVerification) {
		this.useVerification = useVerification;
	}

	public boolean isAdjustExponent() {
		return adjustExponent;
	}

	public void setAdjustExponent(boolean adjustExponent) {
		this.adjustExponent = adjustExponent;
	}

	public String getBaseCurrency() {
		return baseCurrency;
	}

	public void setBaseCurrency(String baseCurrency) {
		this.baseCurrency = baseCurrency;
	}

	public Integer getExpPeriod() {
		return expPeriod;
	}

	public void setExpPeriod(Integer expPeriod) {
		this.expPeriod = expPeriod;
	}

	public Integer getRoundingAccuracy() {
		return roundingAccuracy;
	}

	public void setRoundingAccuracy(Integer roundingAccuracy) {
		this.roundingAccuracy = roundingAccuracy;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("rateType", this.getRateType());
		result.put("useCrossRate", this.isUseCrossRate());
		result.put("useBaseRate", this.isUseBaseRate());
		result.put("useBaseRate", this.isUseBaseRate());
		result.put("baseCurrency", this.getBaseCurrency());
		result.put("expPeriod", this.getExpPeriod());
		result.put("roundingAccuracy", this.getRoundingAccuracy());
		result.put("warningLevel", this.getWarningLevel());
		result.put("reversible", this.isReversible());
		result.put("adjustExponent", this.isAdjustExponent());
		
		return result;
	}

}
