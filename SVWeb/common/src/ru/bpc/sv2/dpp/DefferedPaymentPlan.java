package ru.bpc.sv2.dpp;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class DefferedPaymentPlan implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long operId;
	private String operType;
	private String operDesc;
	private String merchantName;
	private String merchantCity;
	private String merchantStreet;
	private BigDecimal instalmentAmount;
	private Integer instalmentTotal;
	private Integer instalmentBilled;
	private Date nextInstalmentDate;
	private BigDecimal debtBalance;
	private Long accountId;
	private String accountNumber;
	private Long cardId;
	private String cardMask;
	private Integer productId;
	private Date operDate;
	private BigDecimal operAmount;
	private String operCurrency;
	private BigDecimal dppAmount;
	private BigDecimal interestAmount;
	private String status;
	private Integer instId;
	private Integer splitHash;
	private String lang;
	private String currency;
	
	private Date dateTo;
	private Date dateFrom;
	private String cardNumber;
	private String instName;
	private Long feeId;
	private String accelerationType;
	private Long macrosId;

	private String instalmentAlgorithm;
	private String nominalRate;

	private Long regOperId;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
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
		
	public String getMerchantName(){
		return this.merchantName;
	}
	
	public void setMerchantName(String merchantName){
		this.merchantName = merchantName;
	}
	
	public String getMerchantCity(){
		return this.merchantCity;
	}
	
	public void setMerchantCity(String merchantCity){
		this.merchantCity = merchantCity;
	}
	
	public String getMerchantStreet(){
		return this.merchantStreet;
	}
	
	public void setMerchantStreet(String merchantStreet){
		this.merchantStreet = merchantStreet;
	}
	
	public BigDecimal getInstalmentAmount(){
		return this.instalmentAmount;
	}
	
	public void setInstalmentAmount(BigDecimal instalmentAmount){
		this.instalmentAmount = instalmentAmount;
	}
	
	public Integer getInstalmentTotal(){
		return this.instalmentTotal;
	}
	
	public void setInstalmentTotal(Integer instalmentTotal){
		this.instalmentTotal = instalmentTotal;
	}
	
	public Integer getInstalmentBilled(){
		return this.instalmentBilled;
	}
	
	public void setInstalmentBilled(Integer instalmentBilled){
		this.instalmentBilled = instalmentBilled;
	}
	
	public Date getNextInstalmentDate(){
		return this.nextInstalmentDate;
	}
	
	public void setNextInstalmentDate(Date nextInstalmentDate){
		this.nextInstalmentDate = nextInstalmentDate;
	}
	
	public BigDecimal getDebtBalance(){
		return this.debtBalance;
	}
	
	public void setDebtBalance(BigDecimal debtBalance){
		this.debtBalance = debtBalance;
	}
	
	public Long getAccountId(){
		return this.accountId;
	}
	
	public void setAccountId(Long accountId){
		this.accountId = accountId;
	}
	
	public Long getCardId(){
		return this.cardId;
	}
	
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}
	
	public Integer getProductId(){
		return this.productId;
	}
	
	public void setProductId(Integer productId){
		this.productId = productId;
	}
	
	public Date getOperDate(){
		return this.operDate;
	}
	
	public void setOperDate(Date operDate){
		this.operDate = operDate;
	}
	
	public BigDecimal getOperAmount(){
		return this.operAmount;
	}
	
	public void setOperAmount(BigDecimal operAmount){
		this.operAmount = operAmount;
	}
	
	public String getOperCurrency(){
		return this.operCurrency;
	}
	
	public void setOperCurrency(String operCurrency){
		this.operCurrency = operCurrency;
	}
	
	public BigDecimal getDppAmount(){
		return this.dppAmount;
	}
	
	public void setDppAmount(BigDecimal dppAmount){
		this.dppAmount = dppAmount;
	}
	
	public BigDecimal getInterestAmount(){
		return this.interestAmount;
	}
	
	public void setInterestAmount(BigDecimal interestAmount){
		this.interestAmount = interestAmount;
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
	
	public Integer getSplitHash(){
		return this.splitHash;
	}
	
	public void setSplitHash(Integer splitHash){
		this.splitHash = splitHash;
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

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getAccountNumber() {
		return accountNumber;
	}

	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getOperDesc() {
		return operDesc;
	}

	public void setOperDesc(String operDesc) {
		this.operDesc = operDesc;
	}

	public Long getFeeId() {
		return feeId;
	}

	public void setFeeId(Long feeId) {
		this.feeId = feeId;
	}

	public String getAccelerationType() {
		return accelerationType;
	}

	public void setAccelerationType(String accelerationType) {
		this.accelerationType = accelerationType;
	}

	public Long getMacrosId() {
		return macrosId;
	}

	public void setMacrosId(Long macrosId) {
		this.macrosId = macrosId;
	}

	public String getCardMask() {
		return cardMask;
	}

	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getInstalmentAlgorithm() {
		return instalmentAlgorithm;
	}

	public void setInstalmentAlgorithm(String instalmentAlgorithm) {
		this.instalmentAlgorithm = instalmentAlgorithm;
	}

	public String getNominalRate() {
		return nominalRate;
	}

	public void setNominalRate(String nominalRate) {
		this.nominalRate = nominalRate;
	}

	public Long getRegOperId() {
		return regOperId;
	}

	public void setRegOperId(Long regOperId) {
		this.regOperId = regOperId;
	}

	@Override
	public DefferedPaymentPlan clone() throws CloneNotSupportedException{
		DefferedPaymentPlan out = new DefferedPaymentPlan();
		out.setId(getId());
		out.setOperId(getOperId());
		out.setOperType(getOperType());
		out.setMerchantName(getMerchantName());
		out.setMerchantCity(getMerchantCity());
		out.setMerchantStreet(getMerchantStreet());
		out.setInstalmentAmount(getInstalmentAmount());
		out.setInstalmentTotal(getInstalmentTotal());
		out.setInstalmentBilled(getInstalmentBilled());
		out.setNextInstalmentDate(getNextInstalmentDate());
		out.setDebtBalance(getDebtBalance());
		out.setAccountId(getAccountId());
		out.setCardId(getCardId());
		out.setProductId(getProductId());
		out.setOperDate(getOperDate());
		out.setOperAmount(getOperAmount());
		out.setOperCurrency(getOperCurrency());
		out.setDppAmount(getDppAmount());
		out.setInterestAmount(getInterestAmount());
		out.setStatus(getStatus());
		out.setInstId(getInstId());
		out.setSplitHash(getSplitHash());
		out.setLang(getLang());
		out.setDateTo(getDateTo());
		out.setDateFrom(getDateFrom());
		out.setCardNumber(getCardNumber());
		out.setAccountNumber(getAccountNumber());
		out.setInstName(getInstName());
		out.setOperDesc(getOperDesc());
		out.setFeeId(getFeeId());
		out.setAccelerationType(getAccelerationType());
		out.setMacrosId(getMacrosId());
		out.setCardMask(getCardMask());
		out.setCurrency(getCurrency());
		out.setInstalmentAlgorithm(getInstalmentAlgorithm());
		out.setNominalRate(getNominalRate());
		out.setRegOperId(getRegOperId());
		return out;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("nextInstalmentDate", this.getNextInstalmentDate());
		result.put("accelerationType", this.getAccelerationType());
		result.put("instalmentTotal", this.getInstalmentTotal());
		result.put("instalmentAmount", this.getInstalmentAmount());
		
		return result;
	}
	
}