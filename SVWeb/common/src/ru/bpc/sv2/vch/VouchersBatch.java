package ru.bpc.sv2.vch;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class VouchersBatch implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private String status;
	private Double totalAmount;
	private String currency;
	private Integer totalCount;
	private Date regDate;
	private Date procDate;
	private Integer merchantId;
	private Integer terminalId;
	private String statusReason;
	private Integer userId;
	private Integer instId;
	private Integer cardNetworkId;
	private String userName;
	private String instName;
	private String merchantName;
	private String terminalNumber;
	private String networkName;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public String getStatus(){
		return this.status;
	}
	
	public void setStatus(String status){
		this.status = status;
	}
	
	public Double getTotalAmount(){
		return this.totalAmount;
	}
	
	public void setTotalAmount(Double totalAmount){
		this.totalAmount = totalAmount;
	}
	
	public String getCurrency(){
		return this.currency;
	}
	
	public void setCurrency(String currency){
		this.currency = currency;
	}
	
	public Integer getTotalCount(){
		return this.totalCount;
	}
	
	public void setTotalCount(Integer totalCount){
		this.totalCount = totalCount;
	}
	
	public Date getRegDate(){
		return this.regDate;
	}
	
	public void setRegDate(Date regDate){
		this.regDate = regDate;
	}
	
	public Date getProcDate(){
		return this.procDate;
	}
	
	public void setProcDate(Date procDate){
		this.procDate = procDate;
	}
	
	public Integer getMerchantId(){
		return this.merchantId;
	}
	
	public void setMerchantId(Integer merchantId){
		this.merchantId = merchantId;
	}
	
	public Integer getTerminalId(){
		return this.terminalId;
	}
	
	public void setTerminalId(Integer terminalId){
		this.terminalId = terminalId;
	}
	
	public String getStatusReason(){
		return this.statusReason;
	}
	
	public void setStatusReason(String statusReason){
		this.statusReason = statusReason;
	}
	
	public Integer getUserId(){
		return this.userId;
	}
	
	public void setUserId(Integer userId){
		this.userId = userId;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public Integer getCardNetworkId(){
		return this.cardNetworkId;
	}
	
	public void setCardNetworkId(Integer cardNetworkId){
		this.cardNetworkId = cardNetworkId;
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

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}

	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}

	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("status", getStatus());
		result.put("totalAmount", getTotalAmount());
		result.put("currency", getCurrency());
		result.put("totalCount", getTotalCount());
		result.put("merchantId", getMerchantId());
		result.put("terminalId", getTerminalId());
		result.put("instId", getInstId());
		result.put("cardNetworkId", getCardNetworkId());
		result.put("statusReason", getStatusReason());
		result.put("userId", getUserId());
		return result;
	}
}