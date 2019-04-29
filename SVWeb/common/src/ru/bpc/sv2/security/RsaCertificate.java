package ru.bpc.sv2.security;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class RsaCertificate implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private String state;
	private Integer authorityId;
	private Long certifiedKeyId;
	private Long authorityKeyId;
	private String certificate;
	private String reminder;
	private String hash;
	private Date expirDate;
	private Integer trackingNumber;
	private String subjectId;
	private String serialNumber;
	private String visaServiceId;
	
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
	
	public String getState(){
		return this.state;
	}
	
	public void setState(String state){
		this.state = state;
	}
	
	public Integer getAuthorityId(){
		return this.authorityId;
	}
	
	public void setAuthorityId(Integer authorityId){
		this.authorityId = authorityId;
	}
	
	public Long getCertifiedKeyId(){
		return this.certifiedKeyId;
	}
	
	public void setCertifiedKeyId(Long certifiedKeyId){
		this.certifiedKeyId = certifiedKeyId;
	}
	
	public Long getAuthorityKeyId(){
		return this.authorityKeyId;
	}
	
	public void setAuthorityKeyId(Long authorityKeyId){
		this.authorityKeyId = authorityKeyId;
	}
	
	public String getCertificate(){
		return this.certificate;
	}
	
	public void setCertificate(String certificate){
		this.certificate = certificate;
	}
	
	public String getReminder(){
		return this.reminder;
	}
	
	public void setReminder(String reminder){
		this.reminder = reminder;
	}
	
	public String getHash(){
		return this.hash;
	}
	
	public void setHash(String hash){
		this.hash = hash;
	}
	
	public Date getExpirDate(){
		return this.expirDate;
	}
	
	public void setExpirDate(Date expirDate){
		this.expirDate = expirDate;
	}
	
	public Integer getTrackingNumber(){
		return this.trackingNumber;
	}
	
	public void setTrackingNumber(Integer trackingNumber){
		this.trackingNumber = trackingNumber;
	}
	
	public String getSubjectId(){
		return this.subjectId;
	}
	
	public void setSubjectId(String subjectId){
		this.subjectId = subjectId;
	}
	
	public String getSerialNumber(){
		return this.serialNumber;
	}
	
	public void setSerialNumber(String serialNumber){
		this.serialNumber = serialNumber;
	}
	
	public String getVisaServiceId(){
		return this.visaServiceId;
	}
	
	public void setVisaServiceId(String visaServiceId){
		this.visaServiceId = visaServiceId;
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