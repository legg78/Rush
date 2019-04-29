package ru.bpc.sv2.crp;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class CrpEmployee implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Integer corpCompanyId;
	private Long corpCustomerId;
	private Long corpContractId;
	private Integer depId;
	private String entityType;
	private Long objectId;
	private Long contractId;
	private Long accountId;
	private Integer instId;
	private String employeeName;
	private String accountNumber;
	private String contractNumber;
	
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
	
	public Integer getCorpCompanyId(){
		return this.corpCompanyId;
	}
	
	public void setCorpCompanyId(Integer corpCompanyId){
		this.corpCompanyId = corpCompanyId;
	}
	
	public Long getCorpCustomerId(){
		return this.corpCustomerId;
	}
	
	public void setCorpCustomerId(Long corpCustomerId){
		this.corpCustomerId = corpCustomerId;
	}
	
	public Long getCorpContractId(){
		return this.corpContractId;
	}
	
	public void setCorpContractId(Long corpContractId){
		this.corpContractId = corpContractId;
	}
	
	public Integer getDepId(){
		return this.depId;
	}
	
	public void setDepId(Integer depId){
		this.depId = depId;
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
	
	public Long getContractId(){
		return this.contractId;
	}
	
	public void setContractId(Long contractId){
		this.contractId = contractId;
	}
	
	public Long getAccountId(){
		return this.accountId;
	}
	
	public void setAccountId(Long accountId){
		this.accountId = accountId;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public String getEmployeeName(){
		return this.employeeName;
	}
	
	public void setEmployeeName(String employeeName){
		this.employeeName = employeeName;
	}
	
	public String getAccountNumber(){
		return this.accountNumber;
	}
	
	public void setAccountNumber(String accountNumber){
		this.accountNumber = accountNumber;
	}
	
	public String getContractNumber(){
		return this.contractNumber;
	}
	
	public void setContractNumber(String contractNumber){
		this.contractNumber = contractNumber;
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