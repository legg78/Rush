package ru.bpc.sv2.ps.visa;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class VisaAddendum implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long finMessageId;
	private String tcr;
	private String rawData;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getFinMessageId() {
		return finMessageId;
	}

	public void setFinMessageId(Long finMessageId) {
		this.finMessageId = finMessageId;
	}

	public String getTcr() {
		return tcr;
	}

	public void setTcr(String tcr) {
		this.tcr = tcr;
	}

	public String getRawData() {
		return rawData;
	}

	public void setRawData(String rawData) {
		this.rawData = rawData;
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