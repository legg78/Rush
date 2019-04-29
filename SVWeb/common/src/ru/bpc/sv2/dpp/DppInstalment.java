package ru.bpc.sv2.dpp;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class DppInstalment implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long dppId;
	private Integer instalmentNumber;
	private Date instalmentDate;
	private Double instalmentAmount;
	private Double paymentAmount;
	private Double interestAmount;
	private Long macrosId;
	private boolean bill;
	private String accelerationType;
	private Integer splitHash;
	private String currency;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Long getDppId(){
		return this.dppId;
	}
	
	public void setDppId(Long dppId){
		this.dppId = dppId;
	}
	
	public Integer getInstalmentNumber(){
		return this.instalmentNumber;
	}
	
	public void setInstalmentNumber(Integer instalmentNumber){
		this.instalmentNumber = instalmentNumber;
	}
	
	public Date getInstalmentDate(){
		return this.instalmentDate;
	}
	
	public void setInstalmentDate(Date instalmentDate){
		this.instalmentDate = instalmentDate;
	}
	
	public Double getInstalmentAmount(){
		return this.instalmentAmount;
	}
	
	public void setInstalmentAmount(Double instalmentAmount){
		this.instalmentAmount = instalmentAmount;
	}
	
	public Double getPaymentAmount(){
		return this.paymentAmount;
	}
	
	public void setPaymentAmount(Double paymentAmount){
		this.paymentAmount = paymentAmount;
	}
	
	public Double getInterestAmount(){
		return this.interestAmount;
	}
	
	public void setInterestAmount(Double interestAmount){
		this.interestAmount = interestAmount;
	}
	
	public Long getMacrosId(){
		return this.macrosId;
	}
	
	public void setMacrosId(Long macrosId){
		this.macrosId = macrosId;
	}	
	
	public boolean isBill() {
		return bill;
	}

	public void setBill(boolean bill) {
		this.bill = bill;
	}

	public String getAccelerationType(){
		return this.accelerationType;
	}
	
	public void setAccelerationType(String accelerationType){
		this.accelerationType = accelerationType;
	}
	
	public Integer getSplitHash(){
		return this.splitHash;
	}
	
	public void setSplitHash(Integer splitHash){
		this.splitHash = splitHash;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}
	
}