package ru.bpc.sv2.dpp;

import java.util.Date;

import ru.bpc.sv2.audit.AuditableObject;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

public class DppMacros implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long accountId;
	private String accountNumber;
	private Long cardId;
	private String cardNumber;
	private String cardMask;
	private Long macrosId;
	private Integer macrosTypeId;
	private String macrosTypeName;
	private String macrosTypeDescription;
	private String macrosTypeDetails;
	private Date operDate;
	private BigDecimal macrosAmount;
	private String macrosCurrency;
	private Date postingDate;
	private Long operId;
	private String operType;
	private String operDescription;
	private Integer instId;
	private String lang;

	private Date dateFrom;
	private Date dateTo;

	public Object getModelId() {
		return getAccountId() + "_" + getMacrosId();
	}

	public Long getAccountId(){
		return this.accountId;
	}
	public void setAccountId(Long accountId){
		this.accountId = accountId;
	}

	public String getAccountNumber(){
		return this.accountNumber;
	}
	public void setAccountNumber(String accountNumber){
		this.accountNumber = accountNumber;
	}

	public Long getCardId(){
		return this.cardId;
	}
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}

	public String getCardNumber(){
		return this.cardNumber;
	}
	public void setCardNumber(String cardNumber){
		this.cardNumber = cardNumber;
	}

	public String getCardMask() {
		return cardMask;
	}
	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public Long getMacrosId(){
		return this.macrosId;
	}
	public void setMacrosId(Long macrosId){
		this.macrosId = macrosId;
	}

	public Integer getMacrosTypeId(){
		return this.macrosTypeId;
	}
	public void setMacrosTypeId(Integer macrosTypeId){
		this.macrosTypeId = macrosTypeId;
	}

	public String getMacrosTypeName(){
		return this.macrosTypeName;
	}
	public void setMacrosTypeName(String macrosTypeName){
		this.macrosTypeName = macrosTypeName;
	}

	public String getMacrosTypeDescription(){
		return this.macrosTypeDescription;
	}
	public void setMacrosTypeDescription(String macrosTypeDescription){
		this.macrosTypeDescription = macrosTypeDescription;
	}

	public String getMacrosTypeDetails(){
		return this.macrosTypeDetails;
	}
	public void setMacrosTypeDetails(String macrosTypeDetails){
		this.macrosTypeDetails = macrosTypeDetails;
	}

	public Date getOperDate(){
		return this.operDate;
	}
	public void setOperDate(Date operDate){
		this.operDate = operDate;
	}

	public BigDecimal getMacrosAmount(){
		return this.macrosAmount;
	}
	public void setMacrosAmount(BigDecimal macrosAmount){
		this.macrosAmount = macrosAmount;
	}

	public String getMacrosCurrency(){
		return this.macrosCurrency;
	}
	public void setMacrosCurrency(String macrosCurrency){
		this.macrosCurrency = macrosCurrency;
	}

	public Date getPostingDate(){
		return this.postingDate;
	}
	public void setPostingDate(Date postingDate){
		this.postingDate = postingDate;
	}

	public Long getOperId(){
		return this.operId;
	}
	public void setOperId(Long operId){
		this.operId = operId;
	}

	public String getOperType(){
		return this.operType;
	}
	public void setOperType(String operType){
		this.operType = operType;
	}

	public String getOperDescription(){
		return this.operDescription;
	}
	public void setOperDescription(String operDescription){
		this.operDescription = operDescription;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getLang(){
		return this.lang;
	}
	public void setLang(String lang){
		this.lang = lang;
	}

	public Date getDateTo() {
		return dateTo;
	}
	public void setDateTo(Date dateTo) {
		this.dateTo = dateTo;
	}

	public Date getDateFrom() {
		return dateFrom;
	}
	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}

	public DefferedPaymentPlan toDPP() {
		DefferedPaymentPlan dpp = new DefferedPaymentPlan();
		dpp.setOperId(getOperId());
		dpp.setInstId(getInstId());
		dpp.setOperType(getOperType());
		dpp.setAccountId(getAccountId());
		dpp.setCardId(getCardId());
		dpp.setOperDate(getOperDate());
		dpp.setDppAmount(getMacrosAmount());
		dpp.setCurrency(getMacrosCurrency());
		dpp.setLang(getLang());
		dpp.setDateTo(getDateTo());
		dpp.setDateFrom(getDateFrom());
		dpp.setCardNumber(getCardNumber());
		dpp.setAccountNumber(getAccountNumber());
		dpp.setOperDesc(getOperDescription());
		dpp.setMacrosId(getMacrosId());
		dpp.setCardMask(getCardMask());
		return dpp;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> audit = new HashMap<String, Object>();
		audit.put("accountId", getAccountId());
		audit.put("cardId", getCardId());
		audit.put("cardNumber", getCardMask());
		audit.put("operId", getOperId());
		return audit;
	}
}