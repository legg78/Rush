package ru.bpc.sv2.common.rates;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class RatePair implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String rateType;
	private Integer instId;
	private String instName;
	private String srcCurrency;
	private String dstCurrency;
	private String baseRateType;
	private String baseRateMnemonic;
	private String baseRateFormula;
	private boolean reqRegularReg;
	private Double srcScale;
	private Double dstScale;
	private Boolean inverted;
	private String inputMode;
	private Integer displayOrder;
	private Double rateExample;
	private String label;
	private String lang;
	
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

	public String getSrcCurrency() {
		return srcCurrency;
	}

	public void setSrcCurrency(String srcCurrency) {
		this.srcCurrency = srcCurrency;
	}

	public String getDstCurrency() {
		return dstCurrency;
	}

	public void setDstCurrency(String dstCurrency) {
		this.dstCurrency = dstCurrency;
	}

	public String getBaseRateType() {
		return baseRateType;
	}

	public void setBaseRateType(String baseRateType) {
		this.baseRateType = baseRateType;
	}

	public String getBaseRateMnemonic() {
		return baseRateMnemonic;
	}

	public void setBaseRateMnemonic(String baseRateMnemonic) {
		this.baseRateMnemonic = baseRateMnemonic;
	}

	public String getBaseRateFormula() {
		return baseRateFormula;
	}

	public void setBaseRateFormula(String baseRateFormula) {
		this.baseRateFormula = baseRateFormula;
	}

	public boolean isReqRegularReg() {
		return reqRegularReg;
	}

	public void setReqRegularReg(boolean reqRegularReg) {
		this.reqRegularReg = reqRegularReg;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Double getSrcScale() {
		return srcScale;
	}

	public void setSrcScale(Double srcScale) {
		this.srcScale = srcScale;
	}

	public Double getDstScale() {
		return dstScale;
	}

	public void setDstScale(Double dstScale) {
		this.dstScale = dstScale;
	}

    public Boolean getInverted() {
        return inverted;
    }

    public void setInverted(Boolean inverted) {
        this.inverted = inverted != null ? inverted : Boolean.FALSE;
    }

	public String getInputMode() {
		return inputMode;
	}

	public void setInputMode(String inputMode) {
		this.inputMode = inputMode;
	}
	
	public boolean isSetBySystem() {
		return RateConstants.INPUT_MODE_SYSTEM.equals(getInputMode());
	}
	
	public boolean isSetByOperator() {
		return RateConstants.INPUT_MODE_OPERATOR.equals(getInputMode());
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("rateType", this.getRateType());
		result.put("baseRateType", this.getBaseRateType());
		result.put("srcCurrency", this.getSrcCurrency());
		result.put("srcScale", this.getSrcScale());
		result.put("dstCurrency", this.getDstCurrency());
		result.put("dstScale", this.getDstScale());
		result.put("baseRateFormula", this.getBaseRateFormula());		
		result.put("inputMode", this.getInputMode());
		result.put("inverted", this.getInverted());
		result.put("displayOrder", this.getDisplayOrder());
		return result;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public Double getRateExample() {
		return rateExample;
	}

	public void setRateExample(Double rateExample) {
		this.rateExample = rateExample;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

}
