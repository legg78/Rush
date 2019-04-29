package ru.bpc.sv2.security;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class RsaKey implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long objectId;
	private String entityType;
	private Integer lmkId;
	private String keyType;
	private Integer keyIndex;
	private Date expirDate;
	private String signAlgorithm;
	private Integer modulusLength;
	private String exponent;
	private String publicKey;
	private String privateKey;
	private String publicKeyMac;
	private String standardKeyType;
	private String description;
	private String lang;
	private Integer authorityId;
	private Integer trackingNumber;
	private String subjectId;
	private String visaServiceId;
	private Integer hsmDeviceId;
	private Integer authorityKeyIndex;
	
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
	
	public Long getObjectId(){
		return this.objectId;
	}
	
	public void setObjectId(Long objectId){
		this.objectId = objectId;
	}
	
	public String getEntityType(){
		return this.entityType;
	}
	
	public void setEntityType(String entityType){
		this.entityType = entityType;
	}
	
	public Integer getLmkId(){
		return this.lmkId;
	}
	
	public void setLmkId(Integer lmkId){
		this.lmkId = lmkId;
	}
	
	public String getKeyType(){
		return this.keyType;
	}
	
	public void setKeyType(String keyType){
		this.keyType = keyType;
	}
	
	public Integer getKeyIndex(){
		return this.keyIndex;
	}
	
	public void setKeyIndex(Integer keyIndex){
		this.keyIndex = keyIndex;
	}
	
	public Date getExpirDate(){
		return this.expirDate;
	}
	
	public void setExpirDate(Date expirDate){
		this.expirDate = expirDate;
	}
	
	public String getSignAlgorithm(){
		return this.signAlgorithm;
	}
	
	public void setSignAlgorithm(String signAlgorithm){
		this.signAlgorithm = signAlgorithm;
	}
	
	public Integer getModulusLength(){
		return this.modulusLength;
	}
	
	public void setModulusLength(Integer modulusLength){
		this.modulusLength = modulusLength;
	}
	
	public String getExponent(){
		return this.exponent;
	}
	
	public void setExponent(String exponent){
		this.exponent = exponent;
	}
	
	public String getPublicKey(){
		return this.publicKey;
	}
	
	public void setPublicKey(String publicKey){
		this.publicKey = publicKey;
	}
	
	public String getPrivateKey(){
		return this.privateKey;
	}
	
	public void setPrivateKey(String privateKey){
		this.privateKey = privateKey;
	}
	
	public String getPublicKeyMac(){
		return this.publicKeyMac;
	}
	
	public void setPublicKeyMac(String publicKeyMac){
		this.publicKeyMac = publicKeyMac;
	}
	
	public String getStandardKeyType(){
		return this.standardKeyType;
	}
	
	public void setStandardKeyType(String standardKeyType){
		this.standardKeyType = standardKeyType;
	}
	
	public String getDescription(){
		return this.description;
	}
	
	public void setDescription(String description){
		this.description = description;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}
	
	public Integer getAuthorityId() {
		return authorityId;
	}

	public void setAuthorityId(Integer authorityId) {
		this.authorityId = authorityId;
	}

	public Integer getTrackingNumber() {
		return trackingNumber;
	}

	public void setTrackingNumber(Integer trackingNumber) {
		this.trackingNumber = trackingNumber;
	}

	public String getSubjectId() {
		return subjectId;
	}

	public void setSubjectId(String subjectId) {
		this.subjectId = subjectId;
	}

	public String getVisaServiceId() {
		return visaServiceId;
	}

	public void setVisaServiceId(String visaServiceId) {
		this.visaServiceId = visaServiceId;
	}

	public Integer getHsmDeviceId() {
		return hsmDeviceId;
	}

	public void setHsmDeviceId(Integer hsmDeviceId) {
		this.hsmDeviceId = hsmDeviceId;
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
	
	

	public Integer getAuthorityKeyIndex() {
		return authorityKeyIndex;
	}

	public void setAuthorityKeyIndex(Integer authorityKeyIndex) {
		this.authorityKeyIndex = authorityKeyIndex;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("authorityId", getAuthorityId());
		result.put("objectId", getObjectId());
		result.put("entityType", getEntityType());
		result.put("hsmDeviceId", getHsmDeviceId());
		result.put("keyIndex", getKeyIndex());
		result.put("signAlgorithm", getSignAlgorithm());
		result.put("modulusLength", getModulusLength());
		result.put("exponent", getExponent());
		result.put("expirDate", getExpirDate());
		result.put("trackingNumber", getTrackingNumber());
		result.put("subjectId", getSubjectId());
		result.put("visaServiceId", getVisaServiceId());
		result.put("lang", getLang());
		result.put("description", getDescription());
		return result;
	}
}