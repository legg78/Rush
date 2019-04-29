package ru.bpc.sv2.atm;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class FraudOperation implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long terminalId;
	private Date operDate;
	private String operType;
	private String operTypeName;
	private String operCurrency;
	private String operCurrencyName;
	private Integer exponent;
	private Double operAmount;
	private String eventType;
	private String eventTypeName;
	private Integer caseId;
	private String caseLabel;
	private String cardNumber;
	private String cardMask;
	private String lang;
	private Long id;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getTerminalId(){
		return this.terminalId;
	}
	
	public void setTerminalId(Long terminalId){
		this.terminalId = terminalId;
	}
	
	public Date getOperDate(){
		return this.operDate;
	}
	
	public void setOperDate(Date operDate){
		this.operDate = operDate;
	}
	
	public String getOperType(){
		return this.operType;
	}
	
	public void setOperType(String operType){
		this.operType = operType;
	}
	
	public String getOperTypeName(){
		return this.operTypeName;
	}
	
	public void setOperTypeName(String operTypeName){
		this.operTypeName = operTypeName;
	}
	
	public String getOperCurrency(){
		return this.operCurrency;
	}
	
	public void setOperCurrency(String operCurrency){
		this.operCurrency = operCurrency;
	}
	
	public String getOperCurrencyName(){
		return this.operCurrencyName;
	}
	
	public void setOperCurrencyName(String operCurrencyName){
		this.operCurrencyName = operCurrencyName;
	}
	
	public Integer getExponent(){
		return this.exponent;
	}
	
	public void setExponent(Integer exponent){
		this.exponent = exponent;
	}
	
	public Double getOperAmount(){
		return this.operAmount;
	}
	
	public void setOperAmount(Double operAmount){
		this.operAmount = operAmount;
	}
	
	public String getEventType(){
		return this.eventType;
	}
	
	public void setEventType(String eventType){
		this.eventType = eventType;
	}
	
	public String getEventTypeName(){
		return this.eventTypeName;
	}
	
	public void setEventTypeName(String eventTypeName){
		this.eventTypeName = eventTypeName;
	}
	
	public Integer getCaseId(){
		return this.caseId;
	}
	
	public void setCaseId(Integer caseId){
		this.caseId = caseId;
	}
	
	public String getCaseLabel(){
		return this.caseLabel;
	}
	
	public void setCaseLabel(String caseLabel){
		this.caseLabel = caseLabel;
	}
	
	public String getCardNumber(){
		return this.cardNumber;
	}
	
	public void setCardNumber(String cardNumber){
		this.cardNumber = cardNumber;
	}
	
	public String getCardMask(){
		return this.cardMask;
	}
	
	public void setCardMask(String cardMask){
		this.cardMask = cardMask;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
}