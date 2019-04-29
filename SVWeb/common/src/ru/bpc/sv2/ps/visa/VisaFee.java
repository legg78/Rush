package ru.bpc.sv2.ps.visa;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.math.BigDecimal;

public class VisaFee implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long fileId;
	private BigDecimal payFee;
	private String dstBin;
	private String srcBin;
	private String reasonCode;
	private String countryCode;
	private Date eventDate;
	private BigDecimal payAmount;
	private String payCurrency;
	private BigDecimal srcAmount;
	private String srcCurrency;
	private String messageText;
	private String transId;
	private String reimbAttr;
	private Integer dstInstId;
	private Integer srcInstId;
	private String fundingSource;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Long getFileId(){
		return this.fileId;
	}
	
	public void setFileId(Long fileId){
		this.fileId = fileId;
	}
	
	public BigDecimal getPayFee(){
		return this.payFee;
	}
	
	public void setPayFee(BigDecimal payFee){
		this.payFee = payFee;
	}
	
	public String getDstBin(){
		return this.dstBin;
	}
	
	public void setDstBin(String dstBin){
		this.dstBin = dstBin;
	}
	
	public String getSrcBin(){
		return this.srcBin;
	}
	
	public void setSrcBin(String srcBin){
		this.srcBin = srcBin;
	}
	
	public String getReasonCode(){
		return this.reasonCode;
	}
	
	public void setReasonCode(String reasonCode){
		this.reasonCode = reasonCode;
	}
	
	public String getCountryCode(){
		return this.countryCode;
	}
	
	public void setCountryCode(String countryCode){
		this.countryCode = countryCode;
	}
	
	public Date getEventDate(){
		return this.eventDate;
	}
	
	public void setEventDate(Date eventDate){
		this.eventDate = eventDate;
	}
	
	public BigDecimal getPayAmount(){
		return this.payAmount;
	}
	
	public void setPayAmount(BigDecimal payAmount){
		this.payAmount = payAmount;
	}
	
	public String getPayCurrency(){
		return this.payCurrency;
	}
	
	public void setPayCurrency(String payCurrency){
		this.payCurrency = payCurrency;
	}
	
	public BigDecimal getSrcAmount(){
		return this.srcAmount;
	}
	
	public void setSrcAmount(BigDecimal srcAmount){
		this.srcAmount = srcAmount;
	}
	
	public String getSrcCurrency(){
		return this.srcCurrency;
	}
	
	public void setSrcCurrency(String srcCurrency){
		this.srcCurrency = srcCurrency;
	}
	
	public String getMessageText(){
		return this.messageText;
	}
	
	public void setMessageText(String messageText){
		this.messageText = messageText;
	}
	
	public String getTransId(){
		return this.transId;
	}
	
	public void setTransId(String transId){
		this.transId = transId;
	}
	
	public String getReimbAttr(){
		return this.reimbAttr;
	}
	
	public void setReimbAttr(String reimbAttr){
		this.reimbAttr = reimbAttr;
	}
	
	public Integer getDstInstId(){
		return this.dstInstId;
	}
	
	public void setDstInstId(Integer dstInstId){
		this.dstInstId = dstInstId;
	}
	
	public Integer getSrcInstId(){
		return this.srcInstId;
	}
	
	public void setSrcInstId(Integer srcInstId){
		this.srcInstId = srcInstId;
	}
	
	public String getFundingSource(){
		return this.fundingSource;
	}
	
	public void setFundingSource(String fundingSource){
		this.fundingSource = fundingSource;
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
}