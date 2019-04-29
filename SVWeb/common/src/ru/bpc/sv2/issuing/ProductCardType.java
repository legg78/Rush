package ru.bpc.sv2.issuing;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.issuing.personalization.PersonalizationConstants;

public class ProductCardType implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer productId;
	private Integer cardTypeId;
	private String cardTypeName;
	private Integer seqNum;
	private Integer seqNumberLow;
	private Integer seqNumberHigh;
	private Integer binId;
	private String binName;
	private String binBin;
	
	private Integer indexRangeId;
	private String indexRangeName;
	
	private Integer numberFormatId;
	private String numberFormatName;
	
	private Integer methodId;
	private String methodName;
	
	private String onlineStatus;	
	private String pinRequest;
	private String embossingRequest;
	private String pinMailerRequest;
	private String persoPriority;

	private String reissStartDateRule;
	private String reissExpirDateRule;
	private Integer reissCardTypeId;
	private Integer reissContractId;
	private String reissCommand;
	private String reissCardTypeName;
	private String reissContractNumber;
	
	private Integer blankTypeId;
	private String blankTypeName;
	private Integer emvApplicationId;
	private String emvApplicationName;
	private String warningMsg;
	
	private String cardState;
	private Long serviceId;
	private String serviceDict;
	private Long reissProductId;
	private String reissProductName;
	private Long reissBinId;
	private String reissBinName;
	private String reissBinBin;
	private Integer uidFormatId;

	private String entityType;
	private Integer minCount;
	private Integer avalCount;
	private Integer currentCount;
	private Integer maxCount;
	private boolean isChecked;
	private boolean isCheckedOld;

	public Object getModelId() {
		return getId();
	}
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getCardTypeId() {
		return cardTypeId;
	}

	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}

	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getSeqNumberLow() {
		return seqNumberLow;
	}

	public void setSeqNumberLow(Integer seqNumberLow) {
		this.seqNumberLow = seqNumberLow;
	}

	public Integer getSeqNumberHigh() {
		return seqNumberHigh;
	}

	public void setSeqNumberHigh(Integer seqNumberHigh) {
		this.seqNumberHigh = seqNumberHigh;
	}

	public Integer getBinId() {
		return binId;
	}

	public void setBinId(Integer binId) {
		this.binId = binId;
	}

	public Integer getIndexRangeId() {
		return indexRangeId;
	}

	public void setIndexRangeId(Integer indexRangeId) {
		this.indexRangeId = indexRangeId;
	}

	public String getIndexRangeName() {
		return indexRangeName;
	}

	public void setIndexRangeName(String indexRangeName) {
		this.indexRangeName = indexRangeName;
	}

	public Integer getNumberFormatId() {
		return numberFormatId;
	}

	public void setNumberFormatId(Integer numberFormatId) {
		this.numberFormatId = numberFormatId;
	}

	public String getNumberFormatName() {
		return numberFormatName;
	}

	public void setNumberFormatName(String numberFormatName) {
		this.numberFormatName = numberFormatName;
	}

	public Integer getMethodId() {
		return methodId;
	}

	public void setMethodId(Integer methodId) {
		this.methodId = methodId;
	}

	public String getMethodName() {
		return methodName;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}

	public String getOnlineStatus() {
		return onlineStatus;
	}

	public void setOnlineStatus(String onlineStatus) {
		this.onlineStatus = onlineStatus;
	}

	public String getPinRequest() {
		return pinRequest;
	}

	public void setPinRequest(String pinRequest) {
		this.pinRequest = pinRequest;
	}

	public String getEmbossingRequest() {
		return embossingRequest;
	}

	public void setEmbossingRequest(String embossingRequest) {
		this.embossingRequest = embossingRequest;
	}

	public String getPinMailerRequest() {
		return pinMailerRequest;
	}

	public void setPinMailerRequest(String pinMailerRequest) {
		this.pinMailerRequest = pinMailerRequest;
	}

	public String getPersoPriority() {
		return persoPriority;
	}

	public void setPersoPriority(String persoPriority) {
		this.persoPriority = persoPriority;
	}

	public String getBinName() {
		return binName;
	}

	public void setBinName(String binName) {
		this.binName = binName;
	}

	public String getBinBin() {
		return binBin;
	}

	public void setBinBin(String binBin) {
		this.binBin = binBin;
	}

	public String getReissStartDateRule() {
		return reissStartDateRule;
	}

	public void setReissStartDateRule(String reissStartDateRule) {
		this.reissStartDateRule = reissStartDateRule;
	}

	public String getReissExpirDateRule() {
		return reissExpirDateRule;
	}

	public void setReissExpirDateRule(String reissExpirDateRule) {
		this.reissExpirDateRule = reissExpirDateRule;
	}

	public Integer getReissCardTypeId() {
		return reissCardTypeId;
	}

	public void setReissCardTypeId(Integer reissCardTypeId) {
		this.reissCardTypeId = reissCardTypeId;
	}

	public Integer getReissContractId() {
		return reissContractId;
	}

	public void setReissContractId(Integer reissContractId) {
		this.reissContractId = reissContractId;
	}

	public String getReissCommand() {
		return reissCommand;
	}

	public void setReissCommand(String reissCommand) {
		this.reissCommand = reissCommand;
	}

	public String getReissCardTypeName() {
		return reissCardTypeName;
	}

	public void setReissCardTypeName(String reissCardTypeName) {
		this.reissCardTypeName = reissCardTypeName;
	}

	public String getReissContractNumber() {
		return reissContractNumber;
	}

	public void setReissContractNumber(String reissContractNumber) {
		this.reissContractNumber = reissContractNumber;
	}

	public Integer getBlankTypeId() {
		return blankTypeId;
	}

	public void setBlankTypeId(Integer blankTypeId) {
		this.blankTypeId = blankTypeId;
	}

	public String getBlankTypeName() {
		return blankTypeName;
	}

	public void setBlankTypeName(String blankTypeName) {
		this.blankTypeName = blankTypeName;
	}

	@Override
	public ProductCardType clone() throws CloneNotSupportedException {
		return (ProductCardType) super.clone();
	}
	
	public boolean isEmbossingRequestTrue() {
		return PersonalizationConstants.REQUEST_EMBOSSING.equals(embossingRequest);
	}

	public String getWarningMsg() {
		return warningMsg;
	}

	public void setWarningMsg(String warningMsg) {
		this.warningMsg = warningMsg;
	}

	public String getCardState() {
		return cardState;
	}

	public void setCardState(String cardState) {
		this.cardState = cardState;
	}

	public Integer getEmvApplicationId() {
		return emvApplicationId;
	}

	public void setEmvApplicationId(Integer emvApplicationId) {
		this.emvApplicationId = emvApplicationId;
	}

	public String getEmvApplicationName() {
		return emvApplicationName;
	}

	public void setEmvApplicationName(String emvApplicationName) {
		this.emvApplicationName = emvApplicationName;
	}

	public Long getServiceId() {
		return serviceId;
	}

	public void setServiceId(Long serviceId) {
		this.serviceId = serviceId;
	}

	public String getServiceDict() {
		return serviceDict;
	}

	public void setServiceDict(String serviceDict) {
		this.serviceDict = serviceDict;
	}

	public Long getReissProductId() {
		return reissProductId;
	}

	public void setReissProductId(Long reissProductId) {
		this.reissProductId = reissProductId;
	}

	public String getReissProductName() {
		return reissProductName;
	}

	public void setReissProductName(String reissProductName) {
		this.reissProductName = reissProductName;
	}

	public Long getReissBinId() {
		return reissBinId;
	}

	public void setReissBinId(Long reissBinId) {
		this.reissBinId = reissBinId;
	}

	public String getReissBinName() {
		return reissBinName;
	}

	public void setReissBinName(String reissBinName) {
		this.reissBinName = reissBinName;
	}

	public String getReissBinBin() {
		return reissBinBin;
	}

	public void setReissBinBin(String reissBinBin) {
		this.reissBinBin = reissBinBin;
	}

	public Integer getUidFormatId() {
		return uidFormatId;
	}

	public void setUidFormatId(Integer uidFormatId) {
		this.uidFormatId = uidFormatId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getMinCount() {
		return minCount;
	}

	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Integer getAvalCount() {
		return avalCount;
	}

	public void setAvalCount(Integer avalCount) {
		this.avalCount = avalCount;
	}

	public Integer getCurrentCount() {
		return currentCount;
	}

	public void setCurrentCount(Integer currentCount) {
		this.currentCount = currentCount;
	}

	public Integer getMaxCount() {
		return maxCount;
	}

	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}

	public boolean isChecked() {
		return isChecked;
	}

	public void setChecked(boolean checked) {
		isChecked = checked;
	}

	public boolean isCheckedOld() {
		return isCheckedOld;
	}

	public void setCheckedOld(boolean checkedOld) {
		isCheckedOld = checkedOld;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("productId", getProductId());
		result.put("cardTypeId", getCardTypeId());
		result.put("seqNumberLow", getSeqNumberLow());
		result.put("seqNumberHigh", getSeqNumberHigh());
		result.put("binId", getBinId());
		result.put("indexRangeId", getIndexRangeId());
		result.put("numberFormatId", getNumberFormatId());
		result.put("emvApplicationId", getEmvApplicationId());
		result.put("pinRequest", getPinRequest());
		result.put("pinMailerRequest", getPinMailerRequest());
		result.put("embossingRequest", getEmbossingRequest());
		result.put("onlineStatus", getOnlineStatus());
		result.put("persoPriority", getPersoPriority());
		result.put("reissCommand", getReissCommand());
		result.put("reissStartDateRule", getReissStartDateRule());
		result.put("reissExpirDateRule", getReissExpirDateRule());
		result.put("reissCardTypeId", getReissCardTypeId());
		result.put("reissContractId", getReissContractId());
		result.put("blankTypeId", getBlankTypeId());
		result.put("cardState", getCardState());
		result.put("methodId", getMethodId());
		result.put("serviceId", getServiceId());
		result.put("uidFormatId", getUidFormatId());
		return result;
	}
	
	public boolean isWithNewNumber(){
		boolean result = "RCMDNEWN".equalsIgnoreCase(getReissCommand());
		if (!result){
			setReissCardTypeId(null);
		}
		return result;
	}
}
