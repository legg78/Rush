package ru.bpc.sv2.accounts;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AccTypeModifier implements Serializable, ModelIdentifiable{
	
	private Integer id;
	private String accountType;
	private String modId;
	private String modDesc;
	
	public AccTypeModifier(){
	}
	
	public AccTypeModifier(Integer id, String accountType, String modId, String modDesc){
		this.id = id;
		this.accountType = accountType;
		this.modId = modId;
		this.modDesc = modDesc;
	}
	
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}
	
	public String getAccountType() {
		return accountType;
	}
	
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}
	
	public String getModId() {
		return modId;
	}
	
	public void setModId(String modId) {
		this.modId = modId;
	}
	
	public String getModDesc() {
		return modDesc;
	}
	
	public void setModDesc(String modDesc) {
		this.modDesc = modDesc;
	}
	
	@Override
	public Object getModelId() {
		return getId();
	}
}