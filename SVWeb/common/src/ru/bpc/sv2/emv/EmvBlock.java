package ru.bpc.sv2.emv;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class EmvBlock implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private Integer applicationId;
	private String code;
	private Boolean includeInSda;
	private Boolean includeInAfl;
	private Integer transportKeyId;
	private Integer encryptionId;
	private Integer blockOrder;
	private String profile;
	
	private String transportKeyName;
	private String encryptionName;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Integer getApplicationId(){
		return this.applicationId;
	}
	
	public void setApplicationId(Integer applicationId){
		this.applicationId = applicationId;
	}
	
	public String getCode(){
		return this.code;
	}
	
	public void setCode(String code){
		this.code = code;
	}
	
	public Boolean getIncludeInSda(){
		return this.includeInSda;
	}
	
	public void setIncludeInSda(Boolean includeInSda){
		this.includeInSda = includeInSda;
	}
	
	public Boolean getIncludeInAfl(){
		return this.includeInAfl;
	}
	
	public void setIncludeInAfl(Boolean includeInAfl){
		this.includeInAfl = includeInAfl;
	}
	
	public Integer getTransportKeyId(){
		return this.transportKeyId;
	}
	
	public void setTransportKeyId(Integer transportKeyId){
		this.transportKeyId = transportKeyId;
	}
	
	public Integer getEncryptionId(){
		return this.encryptionId;
	}
	
	public void setEncryptionId(Integer encryptionId){
		this.encryptionId = encryptionId;
	}
	
	public Integer getBlockOrder(){
		return this.blockOrder;
	}
	
	public void setBlockOrder(Integer blockOrder){
		this.blockOrder = blockOrder;
	}
	
	public String getProfile(){
		return this.profile;
	}
	
	public void setProfile(String profile){
		this.profile = profile;
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

	public String getTransportKeyName() {
		return transportKeyName;
	}

	public void setTransportKeyName(String transportKeyName) {
		this.transportKeyName = transportKeyName;
	}

	public String getEncryptionName() {
		return encryptionName;
	}

	public void setEncryptionName(String encryptionName) {
		this.encryptionName = encryptionName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("code", this.getCode());
		result.put("includeInSda", this.getIncludeInSda());
		result.put("includeInAfl", this.getIncludeInAfl());
		result.put("transportKeyId", this.getTransportKeyId());
		result.put("encryptionId", this.getEncryptionId());
		result.put("blockOrder", this.getBlockOrder());
		result.put("profile", this.getProfile());
		
		return result;
	}
	
}