package ru.bpc.sv2.common.rates;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Rate implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer instId;
	private Date effDate;
	private Date regDate;
	private String rateType;
	private Double srcScale;
	private String srcCurrency;
	private Double srcExponentScale;
	private Double dstScale;
	private String dstCurrency;
	private Double dstExponentScale;
	private String status;
	private Date expDate;
	private boolean inverted;
	private Double rate;
	private Double effRate;
	private boolean validated;
	private String message;
	private String instName;
	private Integer initiateId;
	private Integer count; //returned count value of created rates 
	private boolean invalidate;
	private Double rateExample;
	private String label;
	
	private boolean needSave = true; //Used in input simple mode to check/uncheck  
	
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

	public Date getEffDate() {
		return effDate;
	}

	public void setEffDate(Date effDate) {
		this.effDate = effDate;
	}

	public Date getRegDate() {
		return regDate;
	}

	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	public String getRateType() {
		return rateType;
	}

	public void setRateType(String rateType) {
		this.rateType = rateType;
	}

	public Double getSrcScale() {
		return srcScale;
	}

	public void setSrcScale(Double srcScale) {
		this.srcScale = srcScale;
	}

	public String getSrcCurrency() {
		return srcCurrency;
	}

	public void setSrcCurrency(String srcCurrency) {
		this.srcCurrency = srcCurrency;
	}

	public Double getSrcExponentScale() {
		return srcExponentScale;
	}

	public void setSrcExponentScale(Double srcExponentScale) {
		this.srcExponentScale = srcExponentScale;
	}

	public Double getDstScale() {
		return dstScale;
	}

	public void setDstScale(Double dstScale) {
		this.dstScale = dstScale;
	}

	public String getDstCurrency() {
		return dstCurrency;
	}

	public void setDstCurrency(String dstCurrency) {
		this.dstCurrency = dstCurrency;
	}

	public Double getDstExponentScale() {
		return dstExponentScale;
	}

	public void setDstExponentScale(Double dstExponentScale) {
		this.dstExponentScale = dstExponentScale;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Date getExpDate() {
		return expDate;
	}

	public void setExpDate(Date expDate) {
		this.expDate = expDate;
	}

	public Double getRate() {
		return rate;
	}

	public void setRate(Double rate) {
		this.rate = rate;
	}

	public Double getEffRate() {
		return effRate;
	}

	public void setEffRate(Double effRate) {
		this.effRate = effRate;
	}

	public boolean isInverted() {
		return inverted;
	}

	public void setInverted(boolean inverted) {
		this.inverted = inverted;
	}

	public boolean isValidated() {
		return validated;
	}

	public void setValidated(boolean validated) {
		this.validated = validated;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getInitiateId() {
		return initiateId;
	}

	public void setInitiateId(Integer initiateId) {
		this.initiateId = initiateId;
	}

	public Integer getCount() {
		return count;
	}

	public void setCount(Integer count) {
		this.count = count;
	}

	public boolean isInvalidate() {
		return invalidate;
	}

	public void setInvalidate(boolean invalidate) {
		this.invalidate = invalidate;
	}

	public boolean isNeedSave() {
		return needSave;
	}

	public void setNeedSave(boolean needSave) {
		this.needSave = needSave;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("rateType", this.getRateType());
		result.put("effDate", this.getEffDate());
		result.put("expDate", this.getExpDate());
		result.put("srcCurrency", this.getSrcCurrency());
		result.put("srcScale", this.getSrcScale());
		result.put("dstCurrency", this.getDstCurrency());
		result.put("dstScale", this.getDstScale());
		result.put("rate", this.getRate());
		result.put("inverted", this.isInverted());
		
		return result;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
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
}
