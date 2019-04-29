package ru.bpc.sv2.acquiring;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class MCC implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String mcc;
	private String tcc;
	private String mastercardCabType;
	private String dinersCode;
	private String name;
	private String lang;

	public String getMcc() {
		return mcc;
	}

	public void setMcc(String mcc) {
		this.mcc = mcc;
	}

	public String getTcc() {
		return tcc;
	}

	public void setTcc(String tcc) {
		this.tcc = tcc;
	}

	public String getDinersCode() {
		return dinersCode;
	}

	public void setDinersCode(String dinersCode) {
		this.dinersCode = dinersCode;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getMastercardCabType() {
		return mastercardCabType;
	}

	public void setMastercardCabType(String mastercardCabType) {
		this.mastercardCabType = mastercardCabType;
	}

	public Object getModelId() {
		return getId();
	}

	@Override
	public MCC clone() throws CloneNotSupportedException {
		return (MCC) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("mcc", this.getMcc());
		result.put("tcc", this.getTcc());
		result.put("dinersCode", this.getDinersCode());
		result.put("mastercardCabType", this.getMastercardCabType());
		result.put("name", this.getName());
		
		return result;
	}

}
