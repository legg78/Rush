package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes page.
 */
public class PmoPaymentOrder implements ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;

	private Long id;
	private Long customerId;
	private String entityType;
	private Long objectId;
	private String objectNumber;
	private String objectDesc;
	private Integer purposeId;
	private String purposeName;
	private Long templateId;
	private BigDecimal amount;
	private String currency;
	private Date eventDate;
	private String status;
	private Integer instId;
	private Integer attemptCount;
	private Integer splitHash;
	private String instName;
	private String lang;
	private Boolean isPreparedOrder;
	private Boolean isTemplate;
	private BigDecimal respAmount;

	private String respCode;
	private String customerNumber;
	private String orderNumber;
	private Date expirationDate;

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getOrderNumber() {
		return orderNumber;
	}

	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}

	public Date getExpirationDate() {
		return expirationDate;
	}

	public void setExpirationDate(Date expirationDate) {
		this.expirationDate = expirationDate;
	}
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Long getCustomerId(){
		return this.customerId;
	}
	
	public void setCustomerId(Long customerId){
		this.customerId = customerId;
	}
	
	public String getEntityType(){
		return this.entityType;
	}
	
	public void setEntityType(String entityType){
		this.entityType = entityType;
	}
	
	public Long getObjectId(){
		return this.objectId;
	}
	
	public void setObjectId(Long objectId){
		this.objectId = objectId;
	}

	public String getObjectNumber() {
		return objectNumber;
	}

	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}
	
	public Integer getPurposeId(){
		return this.purposeId;
	}
	
	public void setPurposeId(Integer purposeId){
		this.purposeId = purposeId;
	}
	
	public Long getTemplateId(){
		return this.templateId;
	}
	
	public void setTemplateId(Long templateId){
		this.templateId = templateId;
	}
	
	public BigDecimal getAmount(){
		return this.amount;
	}
	
	public void setAmount(BigDecimal amount){
		this.amount = amount;
	}
	
	public String getCurrency(){
		return this.currency;
	}
	
	public void setCurrency(String currency){
		this.currency = currency;
	}
	
	public Date getEventDate(){
		return this.eventDate;
	}
	
	public void setEventDate(Date eventDate){
		this.eventDate = eventDate;
	}
	
	public String getStatus(){
		return this.status;
	}
	
	public void setStatus(String status){
		this.status = status;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public Integer getAttemptCount(){
		return this.attemptCount;
	}
	
	public void setAttemptCount(Integer attemptCount){
		this.attemptCount = attemptCount;
	}
	
	public Integer getSplitHash(){
		return this.splitHash;
	}
	
	public void setSplitHash(Integer splitHash){
		this.splitHash = splitHash;
	}
	
	public String getPurposeName() {
		return purposeName;
	}

	public void setPurposeName(String purposeName) {
		this.purposeName = purposeName;
	}

	public String getObjectDesc() {
		return objectDesc;
	}

	public void setObjectDesc(String objectDesc) {
		this.objectDesc = objectDesc;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Boolean getIsPreparedOrder() {
		return isPreparedOrder;
	}

	public void setIsPreparedOrder(Boolean isPreparedOrder) {
		this.isPreparedOrder = isPreparedOrder;
	}

	public Boolean getIsTemplate() {
		return isTemplate;
	}

	public void setIsTemplate(Boolean isTemplate) {
		this.isTemplate = isTemplate;
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

	public BigDecimal getRespAmount() {
		return respAmount;
	}

	public void setRespAmount(BigDecimal respAmount) {
		this.respAmount = respAmount;
	}
}
