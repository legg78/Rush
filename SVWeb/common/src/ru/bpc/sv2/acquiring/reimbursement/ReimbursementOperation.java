package ru.bpc.sv2.acquiring.reimbursement;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReimbursementOperation implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long batchId;
	private Integer channelId;
	private Long posBatchId;
	private Date operDate;
	private Date postingDate;
	private Integer sttlDay;
	private Date reimbDate;
	private Long accountId;
	private Integer merchantId;	
	private Double grossAmount;
	private Double serviceCharge;
	private Double taxAmount;
	private Double netAmount;	
	private Integer instId;
	private String instName;
	private Integer splitHash;
	
	//need for filter
	private Date operDateFrom;
	private Date postingDateFrom;
	private Date reimbDateFrom;
	private Date operDateTo;
	private Date postingDateTo;
	private Date reimbDateTo;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getBatchId() {
		return batchId;
	}

	public void setBatchId(Long batchId) {
		this.batchId = batchId;
	}

	public Integer getChannelId() {
		return channelId;
	}

	public void setChannelId(Integer channelId) {
		this.channelId = channelId;
	}

	public Long getPosBatchId() {
		return posBatchId;
	}

	public void setPosBatchId(Long posBatchId) {
		this.posBatchId = posBatchId;
	}

	public Date getOperDate() {
		return operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public Date getPostingDate() {
		return postingDate;
	}

	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}

	public Integer getSttlDay() {
		return sttlDay;
	}

	public void setSttlDay(Integer sttlDay) {
		this.sttlDay = sttlDay;
	}

	public Date getReimbDate() {
		return reimbDate;
	}

	public void setReimbDate(Date reimbDate) {
		this.reimbDate = reimbDate;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Integer getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(Integer merchantId) {
		this.merchantId = merchantId;
	}

	public Double getGrossAmount() {
		return grossAmount;
	}

	public void setGrossAmount(Double grossAmount) {
		this.grossAmount = grossAmount;
	}

	public Double getServiceCharge() {
		return serviceCharge;
	}

	public void setServiceCharge(Double serviceCharge) {
		this.serviceCharge = serviceCharge;
	}

	public Double getTaxAmount() {
		return taxAmount;
	}

	public void setTaxAmount(Double taxAmount) {
		this.taxAmount = taxAmount;
	}

	public Double getNetAmount() {
		return netAmount;
	}

	public void setNetAmount(Double netAmount) {
		this.netAmount = netAmount;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Date getOperDateFrom() {
		return operDateFrom;
	}

	public void setOperDateFrom(Date operDateFrom) {
		this.operDateFrom = operDateFrom;
	}

	public Date getPostingDateFrom() {
		return postingDateFrom;
	}

	public void setPostingDateFrom(Date postingDateFrom) {
		this.postingDateFrom = postingDateFrom;
	}

	public Date getReimbDateFrom() {
		return reimbDateFrom;
	}

	public void setReimbDateFrom(Date reimbDateFrom) {
		this.reimbDateFrom = reimbDateFrom;
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}

	public Date getPostingDateTo() {
		return postingDateTo;
	}

	public void setPostingDateTo(Date postingDateTo) {
		this.postingDateTo = postingDateTo;
	}

	public Date getReimbDateTo() {
		return reimbDateTo;
	}

	public void setReimbDateTo(Date reimbDateTo) {
		this.reimbDateTo = reimbDateTo;
	}
	
}