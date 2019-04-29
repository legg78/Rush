package ru.bpc.sv2.emv;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.issuing.CardInstance;
public class EmvCardInstance extends CardInstance implements Serializable, ModelIdentifiable,Cloneable{
	
	private Integer applSchemeId;
	private String applSchemeName;
	private String applType;
	
	private String cardNumber;
	private String cardMask;
	private String lang;
	private String customerNumber;
	private String custInfo;
	private Long customerId;
	private Date expirDate;
	
	public String getApplType(){	
		return applType;
	}
	public void setApplType(String applType){
		this.applType = applType;
	}
	
	public String getApplSchemeName(){
		return applSchemeName;
	}
	public void setApplSchemeName(String applSchemeName){
		this.applSchemeName = applSchemeName;
	}
	
	public Integer getApplSchemeId(){
		return applSchemeId;
	}
	public void setApplSchemeId(Integer applSchemeId){
		this.applSchemeId = applSchemeId;
	}
	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}
	public String getCardMask() {
		return cardMask;
	}
	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}
	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}
	public String getCustInfo() {
		return custInfo;
	}
	public void setCustInfo(String custInfo) {
		this.custInfo = custInfo;
	}
	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}
	public Date getExpirDate() {
		return expirDate;
	}
	public void setExpirDate(Date expirDate) {
		this.expirDate = expirDate;
	}
	
}
