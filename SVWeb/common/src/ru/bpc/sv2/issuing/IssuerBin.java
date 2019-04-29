package ru.bpc.sv2.issuing;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class IssuerBin implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String lang;
	private String name;
	private Integer networkId;
	private String networkName;
	
	private Integer instId;
	private String instName;
	
	private String bin;
	
	private String binCurrency;
	private String sttlCurrency;
	
	private Integer panLength;
	
	private Integer cardTypeId;
	private String cardTypeName;
	
	private String country;
	
	private Integer keySchemaId;
	
	public Object getModelId() {
		return getId();
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
	
	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
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

	public String getBin() {
		return bin;
	}

	public void setBin(String bin) {
		this.bin = bin;
	}

	public String getBinCurrency() {
		return binCurrency;
	}

	public void setBinCurrency(String binCurrency) {
		this.binCurrency = binCurrency;
	}

	public String getSttlCurrency() {
		return sttlCurrency;
	}

	public void setSttlCurrency(String sttlCurrency) {
		this.sttlCurrency = sttlCurrency;
	}

	public Integer getPanLength() {
		return panLength;
	}

	public void setPanLength(Integer panLength) {
		this.panLength = panLength;
	}

	public Integer getCardTypeId() {
		return cardTypeId;
	}

	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}

	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	@Override
	public IssuerBin clone() throws CloneNotSupportedException {
		return (IssuerBin) super.clone();
	}

	public Integer getKeySchemaId() {
		return keySchemaId;
	}

	public void setKeySchemaId(Integer keySchemaId) {
		this.keySchemaId = keySchemaId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("bin", getBin());
		result.put("instId", getInstId());
		result.put("networkId", getNetworkId());
		result.put("binCurrency", getBinCurrency());
		result.put("sttlCurrency", getSttlCurrency());
		result.put("panLength", getPanLength());
		result.put("cardTypeId", getCardTypeId());
		result.put("country", getCountry());
		result.put("lang", getLang());
		result.put("name", getName());
		return result;
	}
}
