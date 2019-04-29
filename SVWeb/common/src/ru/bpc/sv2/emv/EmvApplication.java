package ru.bpc.sv2.emv;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class EmvApplication implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private String aid;
	private String name;
	private String lang;
	private String authorityName;
	private String idOwner;
	private Long applSchemeId;
	private String applSchemeName;
	private Long modId;
	private String pix;
	private String ownerName;
	
	
	public String getPix() {
		return pix;
	}

	public void setPix(String pix) {
		this.pix = pix;
	}

	public Long getModId() {
		return modId;
	}

	public void setModId(Long modId) {
		this.modId = modId;
	}

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
	
	public String getAid(){
		return this.aid;
	}
	
	public void setAid(String aid){
		this.aid = aid;
	}
		
	public String getName(){
		return this.name;
	}
	
	public void setName(String name){
		this.name = name;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}

	public String getAuthorityName() {
		return authorityName;
	}

	public void setAuthorityName(String authorityName) {
		this.authorityName = authorityName;
	}

	public String getIdOwner() {
		return idOwner;
	}

	public void setIdOwner(String idOwner) {
		this.idOwner = idOwner;
	}

	@Override
	public EmvApplication clone() throws CloneNotSupportedException{
		return (EmvApplication)super.clone();		
	}

	public Long getApplSchemeId() {
		return applSchemeId;
	}

	public void setApplSchemeId(Long applSchemeId) {
		this.applSchemeId = applSchemeId;
	}

	public String getApplSchemeName() {
		return applSchemeName;
	}

	public void setApplSchemeName(String applSchemeName) {
		this.applSchemeName = applSchemeName;
	}

	public String getOwnerName() {
		return ownerName;
	}

	public void setOwnerName(String ownerName) {
		this.ownerName = ownerName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("applSchemeId", this.getApplSchemeId());
		result.put("aid", this.getAid());
		result.put("idOwner", this.getIdOwner());
		result.put("pix", this.getPix());
		result.put("modId", this.getModId());
		
		return result;
	}
	
}